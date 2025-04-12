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
    return Ingredient(
      ingredientName: json['ingredientName'],
      amount: json['amount'],
      unit: Unit.values[json['unit']],
    );
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
  tsp,
  tbsp;

  String get unitName => name;
}