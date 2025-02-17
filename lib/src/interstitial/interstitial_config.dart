import '../sdk/sdk_config.dart';

class InterstitialConfig {
  String customUnitName = "";
  bool isNewUnit = false;
  num position = 0;
  RetryConfig? retryConfig;
  LoadConfig? newUnit;
  LoadConfig? hijack;
  LoadConfig? unFilled;
  Placement? placement;
  String? format;

  bool isNewUnitApplied() => isNewUnit && newUnit?.status == 1;

  Map<String, dynamic> toJson() {
    return {
      'customUnitName': customUnitName,
      'isNewUnit': isNewUnit,
      'position': position,
      'retryConfig': retryConfig?.toJson(),
      'newUnit': newUnit?.toJson(),
      'hijack': hijack?.toJson(),
      'unFilled': unFilled?.toJson(),
      'placement': placement?.toJson(),
      'format': format,
    };
  }
}

class SilentInterstitialConfig {
  SilentInterstitialConfig();

  int? active;
  String? adunit;
  int? rewarded;
  int? timer;
  int? loadFrequency;
  Regions? regions;

  SilentInterstitialConfig.fromJson(dynamic json) {
    active = json['flutter_active'];
    adunit = json['adunit'];
    rewarded = json['rewarded'];
    timer = json['timer'];
    loadFrequency = json['load_frequency'];
    regions =
        json['regions'] != null ? Regions.fromJson(json['regions']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['flutter_active'] = active;
    map['adunit'] = adunit;
    map['rewarded'] = rewarded;
    map['timer'] = timer;
    map['load_frequency'] = loadFrequency;
    if (regions != null) {
      map['regions'] = regions?.toJson();
    }
    return map;
  }
}
