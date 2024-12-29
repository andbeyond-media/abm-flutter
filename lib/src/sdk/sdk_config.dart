class SdkConfig {
  SdkConfig.fromJson(dynamic json) {
    affiliatedId = json['aff'];
    reFetch = json['refetch'];
    homeCountry = json['home_country'];
    countryStatus = json['country_status'] != null
        ? CountryStatus.fromJson(json['country_status'])
        : null;
    events = json['events'] != null ? Events.fromJson(json['events']) : null;
    infoConfig =
        json['info'] != null ? InfoConfig.fromJson(json['info']) : null;
    geoEdge =
        json['geoedge'] != null ? Geoedge.fromJson(json['geoedge']) : null;
    retryConfig = json['retry_config'] != null
        ? RetryConfig.fromJson(json['retry_config'])
        : null;
    tracking = json['tracking'] != null
        ? TrackingConfig.fromJson(json['tracking'])
        : null;
    unfilledTimerConfig = json['unfilled_config'] != null
        ? UnfilledConfig.fromJson(json['unfilled_config'])
        : null;
    hbFormat = json['hb_format'];
    prebid = json['prebid'] != null ? Prebid.fromJson(json['prebid']) : null;
    aps = json['aps'] != null ? Aps.fromJson(json['aps']) : null;
    openRtb =
        json['open_rtb'] != null ? OpenRtb.fromJson(json['open_rtb']) : null;
    silentInterstitialConfig = json['silent_interstitial_config'] != null
        ? SilentInterstitialConfig.fromJson(json['silent_interstitial_config'])
        : null;
    pubmatic = json['pubmatic'] != null
        ? OpenWrapConfig.fromJson(json['pubmatic'])
        : null;
    blockedRegions = json['region_block'] != null
        ? Regions.fromJson(json['region_block'])
        : null;
    networkBlock = json['network_block'];
    difference = json['diff'];
    networkId = json['network'];
    networkCode = json['networkcode'];
    global = json['global'];
    activeRefreshInterval = json['active'];
    instantRefresh = json['instant_refresh'];
    seemlessRefresh = json['seemless_refresh'];
    seemlessRefreshFallback = json['seemless_refresh_fallback'];
    passiveRefreshInterval = json['passive'];
    factor = json['factor'];
    visibleFactor = json['active_factor'];
    minView = json['min_view'];
    minViewRtb = json['min_view_rtb'];
    forceImpression = json['force_impression'];
    detectDetach = json['detect_detach'];
    if (json['config'] != null) {
      refreshConfig = [];
      json['config'].forEach((v) {
        refreshConfig?.add(RefreshConfig.fromJson(v));
      });
    }
    if (json['supported_sizes'] != null) {
      supportedSizes = [];
      json['supported_sizes'].forEach((v) {
        supportedSizes?.add(ABMSize.fromJson(v));
      });
    }
    if (json['block'] != null) {
      block = [];
      json['block'].forEach((v) {
        block?.add(v.cast<String>());
      });
    }
    heldUnits = json['halt'] != null ? json['halt'].cast<String>() : [];
    if (json['regional_halts'] != null) {
      regionalHalts = [];
      json['regional_halts'].forEach((v) {
        regionalHalts?.add(Regions.fromJson(v));
      });
    }
    if (json['section_regional_halts'] != null) {
      sectionRegionalHalt = [];
      json['section_regional_halts'].forEach((v) {
        sectionRegionalHalt?.add(Regions.fromJson(v));
      });
    }
    hijackConfig =
        json['hijack'] != null ? LoadConfigs.fromJson(json['hijack']) : null;
    unfilledConfig = json['unfilled'] != null
        ? LoadConfigs.fromJson(json['unfilled'])
        : null;
    fallback =
        json['fallback'] != null ? Fallback.fromJson(json['fallback']) : null;
    nativeFallback = json['native_fallback'];
  }

  num? affiliatedId;
  int? reFetch;
  String? homeCountry;
  CountryStatus? countryStatus;
  Events? events;
  InfoConfig? infoConfig;
  Geoedge? geoEdge;
  RetryConfig? retryConfig;
  TrackingConfig? tracking;
  UnfilledConfig? unfilledTimerConfig;
  String? hbFormat;
  Prebid? prebid;
  Aps? aps;
  OpenRtb? openRtb;
  SilentInterstitialConfig? silentInterstitialConfig;
  OpenWrapConfig? pubmatic;
  Regions? blockedRegions;
  String? networkBlock;
  num? difference;
  String? networkId;
  String? networkCode;
  num? global;
  num? activeRefreshInterval;
  num? instantRefresh;
  num? seemlessRefresh;
  num? seemlessRefreshFallback;
  num? passiveRefreshInterval;
  num? factor;
  num? visibleFactor;
  num? minView;
  num? minViewRtb;
  num? forceImpression;
  num? detectDetach;
  List<RefreshConfig>? refreshConfig;
  List<List<String>>? block;
  List<String>? heldUnits;
  List<Regions>? regionalHalts;
  List<Regions>? sectionRegionalHalt;
  LoadConfigs? hijackConfig;
  LoadConfigs? unfilledConfig;
  List<ABMSize>? supportedSizes;
  Fallback? fallback;
  num? nativeFallback;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['aff'] = affiliatedId;
    map['refetch'] = reFetch;
    map['home_country'] = homeCountry;
    if (countryStatus != null) {
      map['country_status'] = countryStatus?.toJson();
    }
    if (events != null) {
      map['events'] = events?.toJson();
    }
    if (infoConfig != null) {
      map['info'] = infoConfig?.toJson();
    }
    if (geoEdge != null) {
      map['geoedge'] = geoEdge?.toJson();
    }
    if (retryConfig != null) {
      map['retry_config'] = retryConfig?.toJson();
    }
    if (tracking != null) {
      map['tracking'] = tracking?.toJson();
    }
    if (unfilledTimerConfig != null) {
      map['unfilled_config'] = unfilledTimerConfig?.toJson();
    }
    map['hb_format'] = hbFormat;
    if (prebid != null) {
      map['prebid'] = prebid?.toJson();
    }
    if (aps != null) {
      map['aps'] = aps?.toJson();
    }
    if (openRtb != null) {
      map['open_rtb'] = openRtb?.toJson();
    }
    if (silentInterstitialConfig != null) {
      map['silent_interstitial_config'] = silentInterstitialConfig?.toJson();
    }
    if (pubmatic != null) {
      map['pubmatic'] = pubmatic?.toJson();
    }
    if (blockedRegions != null) {
      map['region_block'] = blockedRegions?.toJson();
    }
    map['network_block'] = networkBlock;
    map['diff'] = difference;
    map['network'] = networkId;
    map['networkcode'] = networkCode;
    map['global'] = global;
    map['active'] = activeRefreshInterval;
    map['instant_refresh'] = instantRefresh;
    map['seemless_refresh'] = seemlessRefresh;
    map['seemless_refresh_fallback'] = seemlessRefreshFallback;
    map['passive'] = passiveRefreshInterval;
    map['factor'] = factor;
    map['active_factor'] = visibleFactor;
    map['min_view'] = minView;
    map['min_view_rtb'] = minViewRtb;
    map['force_impression'] = forceImpression;
    map['detect_detach'] = detectDetach;
    if (refreshConfig != null) {
      map['config'] = refreshConfig?.map((v) => v.toJson()).toList();
    }
    if (supportedSizes != null) {
      map['supported_sizes'] = supportedSizes?.map((v) => v.toJson()).toList();
    }
    map['block'] = block;
    map['halt'] = heldUnits;
    if (regionalHalts != null) {
      map['regional_halts'] = regionalHalts?.map((v) => v.toJson()).toList();
    }
    if (sectionRegionalHalt != null) {
      map['section_regional_halts'] =
          sectionRegionalHalt?.map((v) => v.toJson()).toList();
    }
    if (hijackConfig != null) {
      map['hijack'] = hijackConfig?.toJson();
    }
    if (unfilledConfig != null) {
      map['unfilled'] = unfilledConfig?.toJson();
    }
    if (fallback != null) {
      map['fallback'] = fallback?.toJson();
    }
    map['native_fallback'] = nativeFallback;
    return map;
  }

  List<String> getBlockList() {
    List<String> tempList = [];
    block?.forEach((subBlockList) {
      for (var item in subBlockList) {
        tempList.add(item);
      }
    });
    return tempList;
  }
}

class Fallback {
  Fallback.fromJson(dynamic json) {
    firstlook = json['firstlook'];
    other = json['other'];
    if (json['banners'] != null) {
      banners = [];
      json['banners'].forEach((v) {
        banners?.add(FallbackBanner.fromJson(v));
      });
    }
  }

  num? firstlook;
  num? other;
  List<FallbackBanner>? banners;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['firstlook'] = firstlook;
    map['other'] = other;
    if (banners != null) {
      map['banners'] = banners?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class FallbackBanner {
  FallbackBanner.fromJson(dynamic json) {
    width = json['width'];
    height = json['height'];
    type = json['type'];
    image = json['image'];
    script = json['script'];
    url = json['url'];
    _tag = json['tag'];
  }

  String? width;
  String? height;
  String? type;
  String? image;
  String? script;
  String? url;
  String? _tag;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['width'] = width;
    map['height'] = height;
    map['image'] = image;
    map['url'] = url;
    return map;
  }

  String? getScriptSource() {
    if (_tag == null || _tag?.isEmpty == true) {
      return null;
    } else {
      return "<SCRIPT language='JavaScript1.1' SRC='$_tag' attributionsrc ></SCRIPT>";
    }
  }
}

class LoadConfig {
  LoadConfig.fromJson(dynamic json) {
    status = json['status'];
    per = json['per'];
    number = json['number'];
    regionWise = json['region_wise'];
    if (json['region_wise_per'] != null) {
      regionalPercentage = [];
      json['region_wise_per'].forEach((v) {
        regionalPercentage?.add(Regions.fromJson(v));
      });
    }
  }

  num? status;
  num? per;
  num? number;
  num? regionWise;
  List<Regions>? regionalPercentage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['per'] = per;
    map['number'] = number;
    map['region_wise'] = regionWise;
    if (regionalPercentage != null) {
      map['region_wise_per'] =
          regionalPercentage?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class LoadConfigs {
  LoadConfigs.fromJson(dynamic json) {
    banner =
        json['BANNER'] != null ? LoadConfig.fromJson(json['BANNER']) : null;
    inter = json['INTERSTITIAL'] != null
        ? LoadConfig.fromJson(json['INTERSTITIAL'])
        : null;
    reward = json['REWARDEDINTERSTITIAL'] != null
        ? LoadConfig.fromJson(json['REWARDEDINTERSTITIAL'])
        : null;
    rewardVideos =
        json['REWARDED'] != null ? LoadConfig.fromJson(json['REWARDED']) : null;
    native =
        json['NATIVE'] != null ? LoadConfig.fromJson(json['NATIVE']) : null;
    appOpen =
        json['APPOPEN'] != null ? LoadConfig.fromJson(json['APPOPEN']) : null;
    newUnit =
        json['newunit'] != null ? LoadConfig.fromJson(json['newunit']) : null;
    adaptive =
        json['ADAPTIVE'] != null ? LoadConfig.fromJson(json['ADAPTIVE']) : null;
    inline =
        json['INLINE'] != null ? LoadConfig.fromJson(json['INLINE']) : null;
    inread =
        json['INREAD'] != null ? LoadConfig.fromJson(json['INREAD']) : null;
    sticky =
        json['STICKY'] != null ? LoadConfig.fromJson(json['STICKY']) : null;
    other = json['ALL'] != null
        ? LoadConfig.fromJson(json['ALL'])
        : (json['all'] != null ? LoadConfig.fromJson(json['all']) : null);
  }

  LoadConfig? banner;
  LoadConfig? inter;
  LoadConfig? reward;
  LoadConfig? rewardVideos;
  LoadConfig? native;
  LoadConfig? appOpen;
  LoadConfig? newUnit;
  LoadConfig? adaptive;
  LoadConfig? inline;
  LoadConfig? inread;
  LoadConfig? sticky;
  LoadConfig? other;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (banner != null) {
      map['BANNER'] = banner?.toJson();
    }
    if (inter != null) {
      map['INTERSTITIAL'] = inter?.toJson();
    }
    if (reward != null) {
      map['REWARDEDINTERSTITIAL'] = reward?.toJson();
    }
    if (rewardVideos != null) {
      map['REWARDED'] = rewardVideos?.toJson();
    }
    if (native != null) {
      map['NATIVE'] = native?.toJson();
    }
    if (appOpen != null) {
      map['APPOPEN'] = appOpen?.toJson();
    }
    if (newUnit != null) {
      map['newunit'] = newUnit?.toJson();
    }
    if (adaptive != null) {
      map['ADAPTIVE'] = adaptive?.toJson();
    }
    if (inline != null) {
      map['INLINE'] = inline?.toJson();
    }
    if (inread != null) {
      map['INREAD'] = inread?.toJson();
    }
    if (sticky != null) {
      map['STICKY'] = sticky?.toJson();
    }
    if (other != null) {
      map['ALL'] = other?.toJson();
    }
    return map;
  }
}

class RefreshConfig {
  RefreshConfig.fromJson(dynamic json) {
    type = json['type'];
    nameType = json['name_type'];
    format = json['format'];
    if (json['sizes'] != null) {
      sizes = [];
      json['sizes'].forEach((v) {
        sizes?.add(ABMSize.fromJson(v));
      });
    }
    follow = json['follow'];
    position = json['pos'];
    placement = json['placement'] != null
        ? Placement.fromJson(json['placement'])
        : null;
    specific = json['specific'];
    expiry = json['expiry'];
  }

  String? type;
  String? nameType;
  String? format;
  List<ABMSize>? sizes;
  num? follow;
  num? position;
  Placement? placement;
  String? specific;
  num? expiry;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['name_type'] = nameType;
    map['format'] = format;
    if (sizes != null) {
      map['sizes'] = sizes?.map((v) => v.toJson()).toList();
    }
    map['follow'] = follow;
    map['pos'] = position;
    if (placement != null) {
      map['placement'] = placement?.toJson();
    }
    map['specific'] = specific;
    map['expiry'] = expiry;
    return map;
  }
}

class Placement {
  Placement.fromJson(dynamic json) {
    firstlook = json['firstlook'];
    other = json['other'];
  }

  num? firstlook;
  num? other;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['firstlook'] = firstlook;
    map['other'] = other;
    return map;
  }
}

class ABMSize {
  ABMSize.fromJson(dynamic json) {
    width = json['width'];
    height = json['height'];
    if (json['sizes'] != null) {
      sizes = [];
      json['sizes'].forEach((v) {
        sizes?.add(ABMSize.fromJson(v));
      });
    }
  }

  dynamic width;
  dynamic height;
  List<ABMSize>? sizes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['width'] = width;
    map['height'] = height;
    if (sizes != null) {
      map['sizes'] = sizes?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  String? toSizes() {
    return sizes?.join(',');
  }

  @override
  String toString() {
    return "$width x $height";
  }
}

class Regions {
  Regions(
      {this.cities,
      this.states,
      this.countries,
      this.mode,
      this.units,
      this.sections,
      this.percentage});

  Regions.fromJson(dynamic json) {
    cities = json['cities'];
    states = json['states'];
    countries = json['countries'];
    mode = json['mode'];
    units = json['units'] != null ? json['units'].cast<String>() : [];
    sections = json['sections'] != null ? json['sections'].cast<String>() : [];
    percentage = json["percentage"];
  }

  String? cities;
  String? states;
  String? countries;
  String? mode;
  List<String>? units;
  List<String>? sections;
  int? percentage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['cities'] = cities;
    map['states'] = states;
    map['countries'] = countries;
    map['mode'] = mode;
    map['units'] = units;
    map['sections'] = sections;
    map['percentage'] = percentage;
    return map;
  }

  List<String> getCities() {
    return (cities?.split(',') ?? [])
        .where((it) => it.trim().isNotEmpty)
        .map((it) => it.trim())
        .toList();
  }

  List<String> getStates() {
    return (states?.split(',') ?? [])
        .where((it) => it.trim().isNotEmpty)
        .map((it) => it.trim())
        .toList();
  }

  List<String> getCountries() {
    return (countries?.split(',') ?? [])
        .where((it) => it.trim().isNotEmpty)
        .map((it) => it.trim())
        .toList();
  }
}

class OpenWrapConfig {
  OpenWrapConfig.fromJson(dynamic json) {
    playstoreUrl = json['playstore_url'];
  }

  String? playstoreUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['playstore_url'] = playstoreUrl;
    return map;
  }
}

class SilentInterstitialConfig {
  SilentInterstitialConfig.fromJson(dynamic json) {
    active = json['active'];
    adunit = json['adunit'];
    custom = json['custom'];
    timer = json['timer'];
    closeDelay = json['close_delay'];
    loadFrequency = json['load_frequency'];
    regions =
        json['regions'] != null ? Regions.fromJson(json['regions']) : null;
    if (json['sizes'] != null) {
      sizes = [];
      json['sizes'].forEach((v) {
        sizes?.add(ABMSize.fromJson(v));
      });
    }
  }

  num? active;
  String? adunit;
  num? custom;
  num? timer;
  num? closeDelay;
  num? loadFrequency;
  Regions? regions;
  List<ABMSize>? sizes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['active'] = active;
    map['adunit'] = adunit;
    map['custom'] = custom;
    map['timer'] = timer;
    map['close_delay'] = closeDelay;
    map['load_frequency'] = loadFrequency;
    if (regions != null) {
      map['regions'] = regions?.toJson();
    }
    if (sizes != null) {
      map['sizes'] = sizes?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class OpenRtb {
  OpenRtb.fromJson(dynamic json) {
    percentage = json['percentage'];
    interPercentage = json['inter_percentage'];
    timeout = json['timeout'];
    tagid = json['tagid'];
    pubid = json['pubid'];
    geocode = json['geocode'];
    url = json['url'];
    if (json['headers'] != null) {
      headers = [];
      json['headers'].forEach((v) {
        headers?.add(Headers.fromJson(v));
      });
    }
    request = json['request'];
  }

  num? percentage;
  num? interPercentage;
  num? timeout;
  String? tagid;
  String? pubid;
  num? geocode;
  String? url;
  List<Headers>? headers;
  String? request;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['percentage'] = percentage;
    map['inter_percentage'] = interPercentage;
    map['timeout'] = timeout;
    map['tagid'] = tagid;
    map['pubid'] = pubid;
    map['geocode'] = geocode;
    map['url'] = url;
    if (headers != null) {
      map['headers'] = headers?.map((v) => v.toJson()).toList();
    }
    map['request'] = request;
    return map;
  }
}

class Headers {
  Headers.fromJson(dynamic json) {
    key = json['key'];
    value = json['value'];
  }

  String? key;
  String? value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['key'] = key;
    map['value'] = value;
    return map;
  }
}

class Aps {
  Aps.fromJson(dynamic json) {
    firstlook = json['firstlook'];
    other = json['other'];
    retry = json['retry'];
    timeout = json['timeout'];
    delay = json['delay'];
    appKey = json['app_key'];
    location = json['location'];
    mraidSupportedVersions = json['mraid_supported_versions'] != null
        ? json['mraid_supported_versions'].cast<String>()
        : [];
    omidPartnerName = json['omid_partner_name'];
    omidPartnerVersion = json['omid_partner_version'];
    if (json['slots'] != null) {
      slots = [];
      json['slots'].forEach((v) {
        slots?.add(Slots.fromJson(v));
      });
    }
    whitelistedFormats = json['whitelisted_formats'] != null
        ? json['whitelisted_formats'].cast<String>()
        : [];
  }

  num? firstlook;
  num? other;
  num? retry;
  num? timeout;
  num? delay;
  String? appKey;
  num? location;
  List<String>? mraidSupportedVersions;
  String? omidPartnerName;
  String? omidPartnerVersion;
  List<Slots>? slots;
  List<String>? whitelistedFormats;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['firstlook'] = firstlook;
    map['other'] = other;
    map['retry'] = retry;
    map['timeout'] = timeout;
    map['delay'] = delay;
    map['app_key'] = appKey;
    map['location'] = location;
    map['mraid_supported_versions'] = mraidSupportedVersions;
    map['omid_partner_name'] = omidPartnerName;
    map['omid_partner_version'] = omidPartnerVersion;
    if (slots != null) {
      map['slots'] = slots?.map((v) => v.toJson()).toList();
    }
    map['whitelisted_formats'] = whitelistedFormats;
    return map;
  }
}

class Slots {
  Slots.fromJson(dynamic json) {
    width = json['width'];
    height = json['height'];
    slotId = json['slot_id'];
  }

  String? width;
  String? height;
  String? slotId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['width'] = width;
    map['height'] = height;
    map['slot_id'] = slotId;
    return map;
  }
}

class Prebid {
  Prebid.fromJson(dynamic json) {
    firstlook = json['firstlook'];
    other = json['other'];
    retry = json['retry'];
    host = json['host'];
    accountid = json['accountid'];
    timeout = json['timeout'];
    debug = json['debug'];
    bundleName = json['bundle_name'];
    location = json['location'];
    gdpr = json['gdpr'];
    domain = json['domain'];
    storeUrl = json['store_url'];
    omidPartnerName = json['omid_partner_name'];
    schain = json['schain'];
    omitPartnerVersion = json['omit_partner_version'];
    if (json['key_values'] != null) {
      keyValues = [];
      json['key_values'].forEach((v) {
        keyValues?.add(KeyValues.fromJson(v));
      });
    }
    bannerApiParameters = json['banner_api_parameters'] != null
        ? json['banner_api_parameters'].cast<num>()
        : [];
    whitelistedFormats = json['whitelisted_formats'] != null
        ? json['whitelisted_formats'].cast<String>()
        : [];
  }

  num? firstlook;
  num? other;
  num? retry;
  String? host;
  num? accountid;
  num? timeout;
  num? debug;
  String? bundleName;
  num? location;
  num? gdpr;
  String? domain;
  String? storeUrl;
  String? omidPartnerName;
  String? schain;
  String? omitPartnerVersion;
  List<KeyValues>? keyValues;
  List<num>? bannerApiParameters;
  List<String>? whitelistedFormats;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['firstlook'] = firstlook;
    map['other'] = other;
    map['retry'] = retry;
    map['host'] = host;
    map['accountid'] = accountid;
    map['timeout'] = timeout;
    map['debug'] = debug;
    map['bundle_name'] = bundleName;
    map['location'] = location;
    map['gdpr'] = gdpr;
    map['domain'] = domain;
    map['store_url'] = storeUrl;
    map['omid_partner_name'] = omidPartnerName;
    map['schain'] = schain;
    map['omit_partner_version'] = omitPartnerVersion;
    if (keyValues != null) {
      map['key_values'] = keyValues?.map((v) => v.toJson()).toList();
    }
    map['banner_api_parameters'] = bannerApiParameters;
    map['whitelisted_formats'] = whitelistedFormats;
    return map;
  }
}

class KeyValues {
  KeyValues.fromJson(dynamic json) {
    key = json['key'];
    value = json['value'];
  }

  String? key;
  String? value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['key'] = key;
    map['value'] = value;
    return map;
  }
}

class UnfilledConfig {
  UnfilledConfig.fromJson(dynamic json) {
    time = json['time'];
    unit = json['unit'];
  }

  num? time;
  String? unit;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['time'] = time;
    map['unit'] = unit;
    return map;
  }
}

class TrackingConfig {
  TrackingConfig.fromJson(dynamic json) {
    percentage = json['percentage'];
    script = json['script'];
  }

  num? percentage;
  String? script;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['percentage'] = percentage;
    map['script'] = script;
    return map;
  }
}

class RetryConfig {
  RetryConfig();

  RetryConfig.fromJson(dynamic json) {
    retries = json['retries'];
    retryInterval = json['retry_interval'];
    networks = json['networks'];
    adUnits = json['alternate_units'] != null
        ? json['alternate_units'].cast<String>()
        : [];
  }

  num? retries;
  num? retryInterval;
  String? networks;
  List<String>? adUnits;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['retries'] = retries;
    map['retry_interval'] = retryInterval;
    map['networks'] = networks;
    map['alternate_units'] = adUnits;
    return map;
  }
}

class Geoedge {
  Geoedge.fromJson(dynamic json) {
    firstlook = json['firstlook'];
    other = json['other'];
    creativeId = json['creative_id'];
    reasons = json['reasons'];
    apiKey = json['api_key'];
    whitelistedRegions =
        json['whitelist'] != null ? Regions.fromJson(json['whitelist']) : null;
  }

  num? firstlook;
  num? other;
  String? creativeId;
  String? reasons;
  String? apiKey;
  Regions? whitelistedRegions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['firstlook'] = firstlook;
    map['other'] = other;
    map['creative_id'] = creativeId;
    map['reasons'] = reasons;
    map['api_key'] = apiKey;
    if (whitelistedRegions != null) {
      map['whitelist'] = whitelistedRegions?.toJson();
    }
    return map;
  }
}

class InfoConfig {
  InfoConfig.fromJson(dynamic json) {
    normalInfo = json['normal_info'];
    specialTag = json['special_tag'];
    refreshCallbacks = json['refresh_callbacks'];
  }

  num? normalInfo;
  String? specialTag;
  num? refreshCallbacks;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['normal_info'] = normalInfo;
    map['special_tag'] = specialTag;
    map['refresh_callbacks'] = refreshCallbacks;
    return map;
  }
}

class Events {
  Events.fromJson(dynamic json) {
    self = json['self'];
    other = json['other'];
    oom = json['oom'];
  }

  num? self;
  num? other;
  num? oom;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['self'] = self;
    map['other'] = other;
    map['oom'] = oom;
    return map;
  }
}

class CountryStatus {
  CountryStatus.fromJson(dynamic json) {
    active = json['active'];
    url = json['url'];
  }

  num? active;
  String? url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['active'] = active;
    map['url'] = url;
    return map;
  }
}

class CountryModel {
  final String? countryCode;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? zip;
  final String? ip;

  CountryModel({
    this.countryCode,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.zip,
    this.ip,
  });

  factory CountryModel.fromJson(dynamic json) {
    return CountryModel(
      countryCode: json['countryCode'] ?? json['country'] as String?,
      latitude: json['latitude'] ?? json['lat'] as double?,
      longitude: json['longitude'] ?? json['lon'] as double?,
      city: json['city'] as String?,
      state: json['regionCode'] ?? json['state'] as String?,
      zip: json['zip'] ?? json['postalCode'] as String?,
      ip: json['ip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'zip': zip,
      'ip': ip,
    };
  }
}
