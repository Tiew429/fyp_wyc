class DataTypeConverter {
  static List<String> convertToStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  static Map<String, double> parseRatingMap(dynamic ratingData) {
    Map<String, double> result = {};
    
    if (ratingData == null) {
      return result;
    }
    
    if (ratingData is Map) {
      ratingData.forEach((key, value) {
        if (key is String) {
          if (value is double) {
            result[key] = value;
          } else if (value is int) {
            result[key] = value.toDouble();
          }
        }
      });
    }
    
    return result;
  }
}
