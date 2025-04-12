class Ingredient {
  String ingredientID;
  String ingredientName;
  String description;
  String imageUrl;
  double amount;
  Unit unit;

  Ingredient({
    required this.ingredientID,
    required this.ingredientName,
    required this.description,
    required this.imageUrl,
    this.amount = 0,
    this.unit = Unit.none,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredientID: json['ingredientID'],
      ingredientName: json['ingredientName'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      amount: json['amount'],
      unit: Unit.values[json['unit']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientID': ingredientID,
      'ingredientName': ingredientName,
      'description': description,
      'imageUrl': imageUrl,
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