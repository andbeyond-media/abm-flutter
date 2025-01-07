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
