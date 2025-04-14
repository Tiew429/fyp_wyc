import 'package:flutter/material.dart';

class MyDescription extends StatefulWidget {
  final String text;

  const MyDescription({
    super.key,
    required this.text,
  });

  @override
  State<MyDescription> createState() => _MyDescriptionState();
}

class _MyDescriptionState extends State<MyDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 20,
          ),
          maxLines: _expanded ? null : 2,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (widget.text.split('\n').length > 2 || _textExceedsMaxLines(context))
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _expanded ? "View Less" : "View More",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _textExceedsMaxLines(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, 
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 20,
        ),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 40);
    return textPainter.didExceedMaxLines;
  }
}
