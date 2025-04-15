import 'package:flutter/material.dart';

class MyRecipeBox extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int cookTime;
  final bool isSaved;
  final VoidCallback? onSave;
  final VoidCallback onTap;
  final bool showSaveButton;

  const MyRecipeBox({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.cookTime,
    this.isSaved = false,
    this.onSave,
    required this.onTap,
    this.showSaveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFF00BFA6),
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Loading image...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant, color: Colors.grey, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (showSaveButton)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: onSave,
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('Food •  >  $cookTime mins'),
            ],
          ),
        ],
      ),
    );
  }
}
