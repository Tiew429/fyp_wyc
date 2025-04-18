class Ingredient {
  String ingredientName;
  double amount;
  Unit unit;

  Ingredient({
    required this.ingredientName,
    this.amount = 0,
    this.unit = Unit.ml,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    try {
      Unit parsedUnit = Unit.g;
      if (json['unit'] != null) {
        if (json['unit'] is String) {
          try {
            final unitString = json['unit'].toString().toLowerCase();
            parsedUnit = Unit.values.firstWhere(
              (u) => u.name.toLowerCase() == unitString,
              orElse: () => Unit.g,
            );
          } catch (_) {
            parsedUnit = Unit.g;
          }
        } else if (json['unit'] is int) {
          final unitIndex = json['unit'] as int;
          if (unitIndex >= 0 && unitIndex < Unit.values.length) {
            parsedUnit = Unit.values[unitIndex];
          }
        }
      }
      
      return Ingredient(
        ingredientName: json['ingredientName'] ?? '',
        amount: json['amount'] is double 
            ? json['amount'] 
            : json['amount'] is int 
                ? (json['amount'] as int).toDouble() 
                : 0.0,
        unit: parsedUnit,
      );
    } catch (e) {
      return Ingredient(
        ingredientName: json['ingredientName'] ?? 'Unknown',
        amount: 0,
        unit: Unit.g,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientName': ingredientName,
      'amount': amount,
      'unit': unit.name,
    };
  }
}

enum Unit {
  ml,
  g,
  l,
  kg,
  pc,
  tsp, // teaspoon
  tbsp, // tablespoon
  cup;

  String get unitName => name;
  
  String get description {
    switch (this) {
      case Unit.ml:
        return 'Milliliter';
      case Unit.g:
        return 'Gram';
      case Unit.l:
        return 'Liter';
      case Unit.kg:
        return 'Kilogram';
      case Unit.pc:
        return 'Piece';
      case Unit.tsp:
        return 'Teaspoon';
      case Unit.tbsp:
        return 'Tablespoon';
      case Unit.cup:
        return 'Cup';
    }
  }
}
