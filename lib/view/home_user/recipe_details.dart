import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/local_user_event.dart';
import 'package:fyp_wyc/event/online_user_event.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/ingredient.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_avatar.dart';
import 'package:fyp_wyc/utils/my_button.dart';
import 'package:fyp_wyc/utils/my_description.dart';
import 'package:go_router/go_router.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe;
  final User? user;
  final bool? isAdmin;

  const RecipeDetailsPage({
    super.key,
    required this.recipe,
    this.user,
    this.isAdmin = false,
  });

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> with SingleTickerProviderStateMixin {
  late Recipe recipe;
  Image? image;
  User? user;
  bool isSaved = false;
  late DraggableScrollableController _scrollController;
  bool isIngredientsSelected = true;
  User? creator;
  bool isCreator = false;
  double averageRating = 0.0;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.isAdmin ?? false;

    recipe = widget.recipe;
    user = widget.user;
    isSaved = user?.savedRecipes.contains(recipe.recipeID) ?? false;
    image = _buildRecipeImage();
    _scrollController = DraggableScrollableController();
    OnlineUserStore.getOnlineUser(recipe.authorEmail).then((user) {
      if (user != null && mounted) {
        setState(() {
          creator = user;
        });
      }
    });

    // check if user is creator
    isCreator = user?.email == recipe.authorEmail;

    // calculate average rating
    double totalRating = 0.0;
    for (var rating in recipe.rating.values) {
      totalRating += rating;
    }
    averageRating = recipe.rating.isEmpty ? 0.0 : totalRating / recipe.rating.length;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onSaveTap() async {
    // save or unsave recipe
    if (isSaved) {
      await RecipeStore.unsaveRecipe(recipe.recipeID);
      setState(() {
        isSaved = false;
      });
    } else {
      await RecipeStore.saveRecipe(recipe.recipeID);
      setState(() {
        isSaved = true;
      });
    }
  }

  Future<void> _onEditTap() async {
    navigatorKey.currentContext!.push(
      '/${ViewData.recipeEdit.path}',
      extra: {
        'recipe': recipe,
      },
    );
  }

  Future<void> _onAuthorTap() async {
    if (creator != null) {
      navigatorKey.currentContext!.push(
        '/${ViewData.author.path}',
        extra: {'author': creator},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          image!,
          _buildRecipeBottomSheet(screenSize),
          _buildExitButton(),
          if (!isAdmin) _buildSaveButton(),
          if (isCreator || isAdmin) _buildEditButton(),
        ],
      ),
    );
  }

  Widget _buildExitButton() {
    return Positioned(
      top: 20,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildButton(
          () => navigatorKey.currentState!.pop(),
          Icon(Icons.arrow_back),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Positioned(
      top: 20,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildButton(
          () => _onSaveTap(),
          isSaved ? Icon(
            Icons.favorite,
            color: Colors.red,
          ) : Icon(Icons.favorite_border),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return Positioned(
      top: isAdmin ? 20 : 80,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildButton(
          () => _onEditTap(),
          Icon(Icons.edit),
        ),
      ),
    );
  }

  Widget _buildButton(VoidCallback onPressed, Icon icon) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: icon,
      ),
    );
  }

  Image? _buildRecipeImage() {
    return Image.network(recipe.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text('Error loading image'),
        );
      },
    );
  }

  Widget _buildRecipeBottomSheet(Size screenSize) {
    final imageHeight = image?.height?.toDouble() ?? screenSize.height * 0.4;
    final minFraction = 1 - (imageHeight / screenSize.height);
    final maxFraction = 0.90;
    final halfFraction = minFraction + (maxFraction - minFraction) / 2;
    
    return DraggableScrollableSheet(
      initialChildSize: minFraction,
      minChildSize: minFraction,
      maxChildSize: maxFraction,
      snapSizes: [minFraction, halfFraction, maxFraction],
      snap: true,
      controller: _scrollController,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // draggable handle
              SliverToBoxAdapter(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(minFraction, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              // recipe title, time to cook, rating
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // recipe name
                      Text(
                        recipe.recipeName,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          // time to cook
                          Icon(Icons.access_time),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("${recipe.timeToCookInMinute} Min",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Spacer(),
                          // rating
                          Icon(Icons.star,
                            color: const Color.fromARGB(255, 255, 215, 84),
                            size: 25,
                          ),
                          SizedBox(width: 5),
                          Text("$averageRating",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // recipe content
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTagsSection(),
                      _buildViewAndSavedCountSection(),
                      // description
                      MyDescription(
                        text: recipe.description,
                      ),
                      _buildIngredientsAndInstructionsSelectionTab(screenSize),
                      isIngredientsSelected ? _buildIngredientsSection() : _buildInstructionsSection(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),
                      _buildAuthorSection(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Divider(),
                      ),
                      _buildRatingSection(recipe.rating),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagsSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Wrap(
        spacing: 15,
        runSpacing: 15,
        children: recipe.tags.map((tag) => _buildTagsItem(tag)).toList(),
      ),
    );
  }

  Widget _buildTagsItem(Tag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(tag.name.substring(0, 1).toUpperCase() + tag.name.substring(1), 
        style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildViewAndSavedCountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("View and Saved Count",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.visibility),
              SizedBox(width: 10),
              Text("${recipe.viewCount}"),
              SizedBox(width: 30),
              Icon(Icons.favorite),
              SizedBox(width: 10),
              Text("${recipe.savedCount}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsAndInstructionsSelectionTab(Size screenSize) {
    void onIngredientsTap() {
      setState(() {
        isIngredientsSelected = true;
      });
    }

    void onInstructionsTap() {
      setState(() {
        isIngredientsSelected = false;
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        height: screenSize.height * 0.075,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSelectionTab("Ingredients", onIngredientsTap, isIngredientsSelected, screenSize),
            _buildSelectionTab("Instructions", onInstructionsTap, !isIngredientsSelected, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionTab(String text, VoidCallback onTap, bool isSelected, Size screenSize) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: screenSize.width * 0.45,
        height: screenSize.height * 0.065,
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(255, 4, 38, 40) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: TextStyle(
              color: isSelected ? Colors.white : Color.fromARGB(255, 4, 38, 40),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    final ingredients = recipe.ingredients;
    final ingredientsCount = ingredients.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ingredients",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text('$ingredientsCount Items',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 10),
        ...ingredients.map((ingredient) => _buildIngredientItem(ingredient)),
      ],
    );
  }

  Widget _buildIngredientItem(Ingredient ingredient) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(ingredient.ingredientName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text('${ingredient.amount} ${ingredient.unit.name}',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Instructions",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text("${recipe.steps.length} steps",
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 10),
        ...recipe.steps.asMap().entries.map((entry) => 
          _buildInstructionItem(entry.value, entry.key)
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String instruction, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 4, 38, 40),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection() {
    return GestureDetector(
      onTap: () async => await _onAuthorTap(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Creator",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              MyAvatar(
                image: OnlineUserStore.currentUserAvatar,
                radius: 35,
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(creator?.username ?? "Unknown",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(creator?.aboutMe ?? "No description",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(Map<String, double> rating) {
    double? originalUserRating = user != null ? rating[user!.email] : 0.0;
    double userRating = originalUserRating ?? 0.0;
    bool isRated = user != null || (originalUserRating != 0.0);
    bool isRating = (userRating != 0.0);
    bool isLoading = false;

    Future<void> onRatingSubmit() async {
      setState(() {
        isLoading = true;
      });
      await LocalUserStore.submitRecipeRating(recipe.recipeID, userRating);
      // show success message
      MySnackBar.showSnackBar("Rating submitted!");
      setState(() {
        isLoading = false;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Rating",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStarRating(userRating.toInt(), isRated),
          ],
        ),
        SizedBox(height: 10),
        if (!isRated)
          !isRating ? Text(
            "Tap on a star to rate this recipe",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ) : MyButton(
            onPressed: () => onRatingSubmit(),
            text: "Submit Rating",
            isLoading: isLoading,
          ),
      ],
    );
  }

  Widget _buildStarRating(int currentRating, bool isRated) {
    return Row(
      children: List.generate(5, (index) => IconButton(
        onPressed: () {
          if (!isRated) {
            setState(() {
              final newRating = (index + 1).toDouble();
              if (user != null) {
                recipe.rating[user!.email] = newRating;
              } else {
                MySnackBar.showSnackBar("Please login to rate this recipe");
              }
            });
          }
        },
        icon: Icon(Icons.star,
          size: 30,
          color: index < currentRating ? Colors.amber : Colors.grey.shade300,
        ),
      )),
    );
  }
}
