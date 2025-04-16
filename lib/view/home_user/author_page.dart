import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_avatar.dart';
import 'package:fyp_wyc/utils/my_recipe_box.dart';
import 'package:go_router/go_router.dart';

class AuthorPage extends StatefulWidget {
  final User? user;
  final User author;
  final List<Recipe> recipeList;

  const AuthorPage({
    super.key,
    required this.user,
    required this.author,
    required this.recipeList,
  });

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> with SingleTickerProviderStateMixin {
  User? user;
  late User author;
  Image? authorAvatar;
  late List<Recipe> recipeList;
  late List<Recipe> recipesAddedByAuthor; // arranged by date added
  late List<Recipe> recipesSavedByAuthor; // arranged by date saved
  bool isAddedTab = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    author = widget.author;
    recipeList = widget.recipeList;
    
    // Get recipes added by author
    recipesAddedByAuthor = recipeList
        .where((recipe) => recipe.authorEmail == author.email)
        .toList();
    
    // Get recipes saved by author
    recipesSavedByAuthor = recipeList
        .where((recipe) => author.savedRecipes.contains(recipe.recipeID))
        .toList();
    
    // Load author avatar if available
    if (author.avatarUrl.isNotEmpty) {
      authorAvatar = ImageFunctions.getAvatarInFuture(author.avatarUrl);
    }
    
    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        isAddedTab = _tabController.index == 0;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        'isAdmin': false,
      },
    );
  }

  String _formatJoinDate(String dateTimeIso) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeIso).add(Duration(hours: 8));
      List<String> months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];
      return "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}";
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Author Profile"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAuthorHeader(),
            _buildAuthorBio(),
            _buildContactInfo(),
            _buildRecipesTabs(),
            _buildRecipesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Color(0xFF00BFA6).withOpacity(0.1),
      child: Row(
        children: [
          MyAvatar(
            radius: 40,
            image: authorAvatar,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      author.username,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Gender icon if available
                    if (author.gender.isNotEmpty)
                      Icon(
                        author.gender.toLowerCase() == 'male' 
                            ? Icons.male 
                            : author.gender.toLowerCase() == 'female'
                                ? Icons.female
                                : Icons.person,
                        color: author.gender.toLowerCase() == 'male'
                            ? Colors.blue
                            : author.gender.toLowerCase() == 'female'
                                ? Colors.pink
                                : Colors.grey,
                      ),
                  ],
                ),
                SizedBox(height: 4),
                // Age range if available
                if (author.ageRange.isNotEmpty)
                  Text(
                    "Age: ${author.ageRange}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                SizedBox(height: 4),
                // Join date
                Text(
                  "Joined on ${_formatJoinDate(author.createdAt)}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorBio() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00BFA6),
            ),
          ),
          SizedBox(height: 8),
          Text(
            author.aboutMe.isNotEmpty ? author.aboutMe : "No bio available",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00BFA6),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.email, size: 20, color: Colors.grey.shade700),
              SizedBox(width: 12),
              Text(
                author.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone, size: 20, color: Colors.grey.shade700),
              SizedBox(width: 12),
              Text(
                author.phone.isNotEmpty ? author.phone : "Not provided",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesTabs() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Color(0xFF00BFA6),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFF00BFA6),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu),
                SizedBox(width: 8),
                Text("Added (${recipesAddedByAuthor.length})"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite),
                SizedBox(width: 8),
                Text("Saved (${recipesSavedByAuthor.length})"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList() {
    List<Recipe> currentRecipes = isAddedTab ? recipesAddedByAuthor : recipesSavedByAuthor;
    
    return Container(
      height: 500, // Fixed height for grid view in SingleChildScrollView
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: currentRecipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAddedTab ? Icons.restaurant_menu : Icons.favorite,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    isAddedTab
                        ? "No recipes added by this author yet"
                        : "No saved recipes by this author",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: currentRecipes.length,
              itemBuilder: (context, index) {
                return MyRecipeBox(
                  imageUrl: currentRecipes[index].imageUrl,
                  title: currentRecipes[index].recipeName,
                  cookTime: currentRecipes[index].timeToCookInMinute,
                  isSaved: author.savedRecipes.contains(currentRecipes[index].recipeID),
                  showSaveButton: false,
                  onTap: () => _onRecipeTap(currentRecipes[index]),
                );
              },
            ),
    );
  }
}
