import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../sdk/SDKConfig.dart';

class BannerConfig {
  num? instantRefresh;
  String customUnitName = "";
  bool isNewUnit = false;
  String publisherAdUnit = "";
  List<AdSize> adSizes = [];
  num position = 0;
  RetryConfig? retryConfig;
  LoadConfig? newUnit;
  LoadConfig? hijack;
  LoadConfig? unFilled;
  Placement? placement;
  num difference = 0;
  num activeRefreshInterval = 0;
  num passiveRefreshInterval = 0;
  num factor = 0;
  num visibleFactor = 0;
  num minView = 0;
  num minViewRtb = 0;
  num refreshCount = 0;
  bool? isVisible;
  num isVisibleFor = 0;
  num? lastRefreshAt = DateTime.now().millisecondsSinceEpoch;
  num? lastActiveOpportunity = DateTime.now().millisecondsSinceEpoch;
  num? lastPassiveOpportunity = DateTime.now().millisecondsSinceEpoch;
  String? format;
  Fallback? fallback;
  Geoedge? geoEdge;
  num? nativeFallback;

  bool isNewUnitApplied() {
    return isNewUnit && newUnit?.status == 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'instantRefresh': instantRefresh,
      'customUnitName': customUnitName,
      'isNewUnit': isNewUnit,
      'publisherAdUnit': publisherAdUnit,
      'adSizes':
          adSizes.map((e) => {'width': e.width, 'height': e.height}).toList(),
      'position': position,
      'retryConfig': retryConfig?.toJson(),
      'newUnit': newUnit?.toJson(),
      'hijack': hijack?.toJson(),
      'unFilled': unFilled?.toJson(),
      'placement': placement?.toJson(),
      'difference': difference,
      'activeRefreshInterval': activeRefreshInterval,
      'passiveRefreshInterval': passiveRefreshInterval,
      'factor': factor,
      'visibleFactor': visibleFactor,
      'minView': minView,
      'minViewRtb': minViewRtb,
      'refreshCount': refreshCount,
      'isVisible': isVisible,
      'isVisibleFor': isVisibleFor,
      'lastRefreshAt': lastRefreshAt,
      'lastActiveOpportunity': lastActiveOpportunity,
      'lastPassiveOpportunity': lastPassiveOpportunity,
      'format': format,
      'fallback': fallback?.toJson(),
      'geoEdge': geoEdge?.toJson(),
      'nativeFallback': nativeFallback,
    };
  }
}
