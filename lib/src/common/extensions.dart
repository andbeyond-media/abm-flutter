
extension DynamicExtension on dynamic {
  int? toIntOrNull() {
    try {
      return int.parse(toString());
    } catch (e) {
      return null;
    }
  }
}
