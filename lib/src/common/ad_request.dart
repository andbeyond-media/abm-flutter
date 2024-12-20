import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdLoadRequest {
  late AdManagerAdRequest _adRequest;
  bool _requestBuilt = false;

  AdManagerAdRequest getAdRequest() {
    if (_requestBuilt) {
      return _adRequest;
    } else {
      return const AdManagerAdRequest(
          customTargeting: {"ABM_Load": "Yes", "Flutter": "Yes"});
    }
  }

  AdLoadRequest build(
      {List<String>? keywords,
      String? contentUrl,
      List<String>? neighboringContentUrls,
      Map<String, String>? customTargeting,
      Map<String, List<String>>? customTargetingLists,
      bool? nonPersonalizedAds,
      int? httpTimeoutMillis,
      String? publisherProvidedId,
      String? mediationExtrasIdentifier,
      Map<String, String>? extras,
      List<MediationExtras>? mediationExtras}) {
    _requestBuilt = true;
    var defaultTargeting = {"ABM_Load": "Yes"};
    if (customTargeting != null) {
      defaultTargeting.addAll(customTargeting);
    }
    _adRequest = AdManagerAdRequest(
        keywords: keywords,
        contentUrl: contentUrl,
        neighboringContentUrls: neighboringContentUrls,
        customTargeting: defaultTargeting,
        customTargetingLists: customTargetingLists,
        nonPersonalizedAds: nonPersonalizedAds,
        httpTimeoutMillis: httpTimeoutMillis,
        publisherProvidedId: publisherProvidedId,
        mediationExtrasIdentifier: mediationExtrasIdentifier,
        extras: extras,
        mediationExtras: mediationExtras);
    return this;
  }
}
