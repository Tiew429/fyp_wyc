class Ingredient {
  String ingredientID;
  String ingredientName;
  double amount;
  Unit unit;

  Ingredient({
    required this.ingredientID,
    required this.ingredientName,
    this.amount = 0,
    this.unit = Unit.none,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientID: json['ingredientID'],
      ingredientName: json['ingredientName'],
      amount: json['amount'],
      unit: Unit.values[json['unit']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientID': ingredientID,
      'ingredientName': ingredientName,
      'amount': amount,
      'unit': unit.name,
    };
  }
}

enum Unit {
  none, // determine if the unit is not set
  ml,
  g,
  l,
  kg,
  pc,
  tsp,
  tbsp;

  String get unitName => name;
}