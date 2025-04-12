class Comment {
  String commentID;
  String message;
  String createdAt; // store datetime as iso8601 string
  String commentBy; // user id of the commenter
  String recipeID;

  Comment({
    required this.commentID,
    required this.message,
    required this.createdAt,
    required this.commentBy,
    required this.recipeID,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentID: json['commentID'],
      message: json['message'],
      createdAt: json['createdAt'],
      commentBy: json['commentBy'],
      recipeID: json['recipeID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentID': commentID,
      'message': message,
      'createdAt': createdAt,
      'commentBy': commentBy,
      'recipeID': recipeID,
    };
  }
}