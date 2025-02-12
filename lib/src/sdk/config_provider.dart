import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../andbeyondmedia.dart';
import 'logger.dart';
import 'sdk_config.dart';

/// Class to handle config related things
class ConfigProvider {
  ConfigProvider._();

  static final ConfigProvider _instance = ConfigProvider._().._init();

  ///Creating static instance
  static ConfigProvider get instance => _instance;

  SdkConfig? _cachedConfig;
  CountryModel? _cachedCountryInfo;
  String _packageName = "";

  void _init() {}

  ///Saving package name for later use
  void savePackageName(String packageName) {
    _packageName = packageName;
  }

  ///used to fetch config
  void fetchConfig() async {
    _loadConfig();
  }

  void _loadConfig() async {
    AndBeyondMedia.instance.controller.add(1);
    SdkConfig? config;
    try {
      log("Loading Config for $_packageName");
      final response = await http.get(Uri.parse(URLs()._getUrl(_packageName)));
      if (response.statusCode == 200) {
        config = SdkConfig.fromJson(jsonDecode(response.body));
        _setConfig(config);
        _storeConfig(config);
        log("Config loaded successfully.");
      } else {
        config = await _readConfig();
        _setConfig(config);
        log("Failed softly to load config.");
      }
    } on Exception catch (e) {
      config = await _readConfig();
      _setConfig(config);
      log("Failed hard to load config.${e.toString()}");
    }
    var countryFetchStatus = config?.countryStatus;
    if (countryFetchStatus?.active == 1 &&
        countryFetchStatus?.url?.isNotEmpty == true) {
      _fetchDetectedCountry(countryFetchStatus?.url, config);
    } else {
      AndBeyondMedia.instance.countryInfoController.add(2);
    }

    AndBeyondMedia.instance.configFetched(config);
  }

  void _setConfig(SdkConfig? config) {
    _cachedConfig = config;
  }

  ///used to provide cached config
  SdkConfig? getConfig() {
    if (_cachedConfig == null) {
      _readConfig().then((config) {
        _cachedConfig = config;
      });
    }
    return _cachedConfig;
  }

  Future<String> _getConfigFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/abm_config_file.txt').path;
  }

  void _storeConfig(SdkConfig config) async {
    final file = File(await _getConfigFilePath());
    await file.writeAsString(jsonEncode(config.toJson()));
  }

  Future<SdkConfig?> _readConfig() async {
    final file = File(await _getConfigFilePath());
    if (await file.exists()) {
      var configString = await file.readAsString();
      return SdkConfig.fromJson(jsonDecode(configString));
    } else {
      return null;
    }
  }

  void _fetchDetectedCountry(String? url, SdkConfig? config) async {
    AndBeyondMedia.instance.countryInfoController.add(1);
    CountryModel? countryModel;
    try {
      final response = url?.contains("apiip") == true
          ? await http.get(Uri.parse(URLs()._getApIpUrl(url!)))
          : await http.get(Uri.parse(URLs()._getMaxmindUrl(url!)));

      if (response.statusCode == 200) {
        countryModel = CountryModel.fromJson(jsonDecode(response.body));
        _setCountryInfo(countryModel);
        _storeCountryInfo(countryModel);
      } else {
        countryModel = await _readCountryInfo();
        _setCountryInfo(countryModel);
      }
    } on Exception catch (_) {
      countryModel = await _readCountryInfo();
      _setCountryInfo(countryModel);
    }
    AndBeyondMedia.instance.countryInfoController.add(2);
    AndBeyondMedia.instance.geoDetected(countryModel, config?.silentInterstitialConfig);
  }

  void _setCountryInfo(CountryModel? info) {
    _cachedCountryInfo = info;
  }

  ///Used to provide geo information
  CountryModel? getCountryInfo() {
    if (_cachedCountryInfo == null) {
      _readCountryInfo().then((config) {
        _cachedCountryInfo = config;
      });
    }
    return _cachedCountryInfo;
  }

  Future<String> _getCountryInfoFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/country_info_file.txt').path;
  }

  void _storeCountryInfo(CountryModel info) async {
    final file = File(await _getCountryInfoFilePath());
    await file.writeAsString(jsonEncode(info.toJson()));
  }

  Future<CountryModel?> _readCountryInfo() async {
    final file = File(await _getCountryInfoFilePath());
    if (await file.exists()) {
      var infoString = await file.readAsString();
      return CountryModel.fromJson(jsonDecode(infoString));
    } else {
      return null;
    }
  }
}

///class to have the necessary urls
class URLs {
  final String _baseURL = "https://rtbcdn.andbeyond.media/";

  String _getUrl(String packageName) {
    return "${_baseURL}appconfig_$packageName.js";
  }

  String _getMaxmindUrl(String baseUrl) {
    return baseUrl;
  }

  String _getApIpUrl(String baseUrl) {
    var queryParams = {
      "accessKey": "7ef45bac-167a-4aa8-8c99-bc8a28f80bc5",
      "fields": "countryCode,latitude,longitude,city,regionCode,ip,postalCode"
    };
    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$baseUrl?$queryString';
  }
}
