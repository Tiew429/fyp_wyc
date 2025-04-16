import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:go_router/go_router.dart';

class HistoryPage extends StatefulWidget {
  final List<Recipe> recipeList;
  final User user;

  const HistoryPage({
    super.key,
    required this.recipeList,
    required this.user,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<Recipe> recipeList;
  late User user;
  late Map<String, List<Recipe>> groupedHistoryList;

  @override
  void initState() {
    super.initState();
    recipeList = widget.recipeList;
    user = widget.user;
    
    // Create a list of recipe-datetime pairs
    List<MapEntry<Recipe, DateTime>> historyEntries = [];
    user.recipeHistory.forEach((recipeID, dateTimeStr) {
      try {
        // Find the corresponding recipe
        Recipe recipe = recipeList.firstWhere((r) => r.recipeID == recipeID);
        // Parse the datetime string
        DateTime viewDate = DateTime.parse(dateTimeStr);
        historyEntries.add(MapEntry(recipe, viewDate));
      } catch (e) {
        // Skip if recipe not found or datetime invalid
      }
    });
    
    // Sort by datetime (newest first)
    historyEntries.sort((a, b) => b.value.compareTo(a.value));
    
    // Group by date (ignoring time)
    groupedHistoryList = {};
    for (var entry in historyEntries) {
      String dateKey = _formatDateKey(entry.value);
      if (!groupedHistoryList.containsKey(dateKey)) {
        groupedHistoryList[dateKey] = [];
      }
      groupedHistoryList[dateKey]!.add(entry.key);
    }
  }
  
  // Format date for display and grouping
  String _formatDateKey(DateTime date) {
    // Add 8 hours to convert to local time
    DateTime localDate = date.add(Duration(hours: 8));
    return "${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";
  }
  
  // Format date for display
  String _formatDateForDisplay(String dateKey) {
    DateTime date = DateTime.parse(dateKey);
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "Today";
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return "Yesterday";
    } else {
      // Format as "Day Month Year" (e.g., "25 May 2023")
      List<String> months = ["January", "February", "March", "April", "May", "June", 
                           "July", "August", "September", "October", "November", "December"];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    }
  }

  Future<void> _onRecipeTap(Recipe recipe) async {
    // select recipe
    RecipeStore.setRecipe(recipe);

    // add to recipe history
    await RecipeStore.addRecipeToHistory(recipe.recipeID);

    // navigate to recipe details page
    navigatorKey.currentContext!.push(
      '/${ViewData.recipeDetails.path}',
      extra: {
        'recipe': recipe,
        'user': user,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: groupedHistoryList.isEmpty
          ? Center(
              child: Text(
                'No history yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: groupedHistoryList.keys.length * 2, // Date headers + recipe groups
              itemBuilder: (context, index) {
                // Even indices are date headers, odd indices are recipe lists
                if (index % 2 == 0) {
                  // Date header
                  String dateKey = groupedHistoryList.keys.elementAt(index ~/ 2);
                  return _buildDateHeader(dateKey);
                } else {
                  // Recipe list for the date
                  String dateKey = groupedHistoryList.keys.elementAt(index ~/ 2);
                  List<Recipe> recipes = groupedHistoryList[dateKey]!;
                  return Column(
                    children: recipes.map((recipe) => _buildHistoryItem(recipe, dateKey)).toList(),
                  );
                }
              },
            ),
    );
  }

  Widget _buildDateHeader(String dateKey) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      alignment: Alignment.centerLeft,
      child: Text(
        _formatDateForDisplay(dateKey),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Recipe recipe, String dateKey) {
    String viewTimeStr = "";
    try {
      DateTime viewTime = DateTime.parse(user.recipeHistory[recipe.recipeID]!).add(Duration(hours: 8));
      viewTimeStr = "${viewTime.hour.toString().padLeft(2, '0')}:${viewTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      // Use empty string if time parsing fails
    }

    return GestureDetector(
      onTap: () async => await _onRecipeTap(recipe),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5.0,
              offset: Offset(0, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                recipe.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    recipe.description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Viewed at: $viewTimeStr',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}