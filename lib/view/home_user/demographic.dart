import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/local_user_event.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:go_router/go_router.dart';

class DemographicPage extends StatefulWidget {
  final User user;

  const DemographicPage({
    super.key,
    required this.user,
  });

  @override
  State<DemographicPage> createState() => _DemographicPageState();
}

class _DemographicPageState extends State<DemographicPage> {
  late User user;
  String? ageGroup;
  String? gender;
  String? occupation;
  String? cookingFrequency;
  String? usuallyPlanMeals;
  String? comfortableUsingMobileOrWebApp;
  String? helpfulOfAppSuggestRecipesBasedOnIngredients;
  String? howOftenToStruggleToDecideWhatToCook;
  String? haveYouThrownAwayFoodBeforeExpired;
  String? howLikelyToUseAppToFindRecipes;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  bool validation() {
    // Check if any field is null or empty
    if (ageGroup == null || ageGroup!.isEmpty) {
      MySnackBar.showSnackBar('Please select your age group');
      return false;
    }
    
    if (gender == null || gender!.isEmpty) {
      MySnackBar.showSnackBar('Please select your gender');
      return false;
    }
    
    if (occupation == null || occupation!.isEmpty) {
      MySnackBar.showSnackBar('Please select your occupation');
      return false;
    }
    
    if (cookingFrequency == null || cookingFrequency!.isEmpty) {
      MySnackBar.showSnackBar('Please select how often you cook');
      return false;
    }
    
    if (usuallyPlanMeals == null || usuallyPlanMeals!.isEmpty) {
      MySnackBar.showSnackBar('Please select if you usually plan your meals in advance');
      return false;
    }
    
    if (comfortableUsingMobileOrWebApp == null || comfortableUsingMobileOrWebApp!.isEmpty) {
      MySnackBar.showSnackBar('Please select your comfort level using mobile or web applications');
      return false;
    }
    
    if (helpfulOfAppSuggestRecipesBasedOnIngredients == null || helpfulOfAppSuggestRecipesBasedOnIngredients!.isEmpty) {
      MySnackBar.showSnackBar('Please select if you would find it helpful for an app to suggest recipes');
      return false;
    }
    
    if (howOftenToStruggleToDecideWhatToCook == null || howOftenToStruggleToDecideWhatToCook!.isEmpty) {
      MySnackBar.showSnackBar('Please select how often you struggle to decide what to cook');
      return false;
    }
    
    if (haveYouThrownAwayFoodBeforeExpired == null || haveYouThrownAwayFoodBeforeExpired!.isEmpty) {
      MySnackBar.showSnackBar('Please select if you have thrown away food');
      return false;
    }
    
    if (howLikelyToUseAppToFindRecipes == null || howLikelyToUseAppToFindRecipes!.isEmpty) {
      MySnackBar.showSnackBar('Please select how likely you are to use an app to find recipes');
      return false;
    }
    
    // All fields are filled
    return true;
  }

  Future<void> _onSubmit() async {
    // Validate all fields are selected
    if (!validation()) {
      return;
    }
    
    final response = await LocalUserStore.updateDemographic(
      ageGroup!, 
      gender!, 
      occupation!, 
      cookingFrequency!, 
      usuallyPlanMeals!, 
      comfortableUsingMobileOrWebApp!, 
      helpfulOfAppSuggestRecipesBasedOnIngredients!, 
      howOftenToStruggleToDecideWhatToCook!, 
      haveYouThrownAwayFoodBeforeExpired!, 
      howLikelyToUseAppToFindRecipes!
    );
    MySnackBar.showSnackBar(response['message']);
    
    // navigate to dashboard page
    navigatorKey.currentContext!.go('/${ViewData.dashboard.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Welcome header
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Age group section
              const Text(
                'What is your age group?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('below 12', ageGroup == 'below 12', () {
                    setState(() => ageGroup = 'below 12');
                  }),
                  _buildSelectionButton('12 - 17', ageGroup == '12 - 17', () {
                    setState(() => ageGroup = '12 - 17');
                  }),
                  _buildSelectionButton('18 - 25', ageGroup == '18 - 25', () {
                    setState(() => ageGroup = '18 - 25');
                  }),
                  _buildSelectionButton('26 - 35', ageGroup == '26 - 35', () {
                    setState(() => ageGroup = '26 - 35');
                  }),
                  _buildSelectionButton('36 - above', ageGroup == '36 - above', () {
                    setState(() => ageGroup = '36 - above');
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // Gender section
              const Text(
                'What is your gender?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('Male', gender == 'Male', () {
                    setState(() => gender = 'Male');
                  }),
                  _buildSelectionButton('Female', gender == 'Female', () {
                    setState(() => gender = 'Female');
                  }),
                  _buildSelectionButton('Prefer not to say', gender == 'Prefer not to say', () {
                    setState(() => gender = 'Prefer not to say');
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // Occupation section
              const Text(
                'What is your Current Occupation?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('Student', occupation == 'Student', () {
                    setState(() => occupation = 'Student');
                  }),
                  _buildSelectionButton('Working Professional', occupation == 'Working Professional', () {
                    setState(() => occupation = 'Working Professional');
                  }),
                  _buildSelectionButton('Freelancer', occupation == 'Freelancer', () {
                    setState(() => occupation = 'Freelancer');
                  }),
                  _buildSelectionButton('Homemaker', occupation == 'Homemaker', () {
                    setState(() => occupation = 'Homemaker');
                  }),
                  _buildSelectionButton('Other', occupation == 'Other', () {
                    setState(() => occupation = 'Other');
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // Cooking frequency section
              const Text(
                'How often do you cook at home?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('Every day', cookingFrequency == 'Every day', () {
                    setState(() => cookingFrequency = 'Every day');
                  }),
                  _buildSelectionButton('A few times a week', cookingFrequency == 'A few times a week', () {
                    setState(() => cookingFrequency = 'A few times a week');
                  }),
                  _buildSelectionButton('Occasionally', cookingFrequency == 'Occasionally', () {
                    setState(() => cookingFrequency = 'Occasionally');
                  }),
                  _buildSelectionButton('Rarely', cookingFrequency == 'Rarely', () {
                    setState(() => cookingFrequency = 'Rarely');
                  }),
                  _buildSelectionButton('Never', cookingFrequency == 'Never', () {
                    setState(() => cookingFrequency = 'Never');
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // Meal planning section
              const Text(
                'Do you usually plan your meals in advance?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('Yes', usuallyPlanMeals == 'Yes', () {
                    setState(() => usuallyPlanMeals = 'Yes');
                  }),
                  _buildSelectionButton('No', usuallyPlanMeals == 'No', () {
                    setState(() => usuallyPlanMeals = 'No');
                  }),
                  _buildSelectionButton('Sometimes', usuallyPlanMeals == 'Sometimes', () {
                    setState(() => usuallyPlanMeals = 'Sometimes');
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // Mobile app comfort section
              const Text(
                'How comfortable are you with using mobile or web applications?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('Very comfortable', comfortableUsingMobileOrWebApp == 'Very comfortable', () {
                    setState(() => comfortableUsingMobileOrWebApp = 'Very comfortable');
                  }),
                  _buildSelectionButton('Somewhat comfortable', comfortableUsingMobileOrWebApp == 'Somewhat comfortable', () {
                    setState(() => comfortableUsingMobileOrWebApp = 'Somewhat comfortable');
                  }),
                  _buildSelectionButton('Not very comfortable', comfortableUsingMobileOrWebApp == 'Not very comfortable', () {
                    setState(() => comfortableUsingMobileOrWebApp = 'Not very comfortable');
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // App suggestions section
              const Text(
                'Would you find it helpful if an app could suggest recipes based on the ingredients you already have?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('Yes', helpfulOfAppSuggestRecipesBasedOnIngredients == 'Yes', () {
                    setState(() => helpfulOfAppSuggestRecipesBasedOnIngredients = 'Yes');
                  }),
                  _buildSelectionButton('No', helpfulOfAppSuggestRecipesBasedOnIngredients == 'No', () {
                    setState(() => helpfulOfAppSuggestRecipesBasedOnIngredients = 'No');
                  }),
                  _buildSelectionButton('Maybe', helpfulOfAppSuggestRecipesBasedOnIngredients == 'Maybe', () {
                    setState(() => helpfulOfAppSuggestRecipesBasedOnIngredients = 'Maybe');
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // Struggle to decide what to cook section
              const Text(
                'How often do you struggle to decide what to cook with the ingredients you have at home?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('Very often', howOftenToStruggleToDecideWhatToCook == 'Very often', () {
                    setState(() => howOftenToStruggleToDecideWhatToCook = 'Very often');
                  }),
                  _buildSelectionButton('Sometimes', howOftenToStruggleToDecideWhatToCook == 'Sometimes', () {
                    setState(() => howOftenToStruggleToDecideWhatToCook = 'Sometimes');
                  }),
                  _buildSelectionButton('Rarely', howOftenToStruggleToDecideWhatToCook == 'Rarely', () {
                    setState(() => howOftenToStruggleToDecideWhatToCook = 'Rarely');
                  }),
                  _buildSelectionButton('Never', howOftenToStruggleToDecideWhatToCook == 'Never', () {
                    setState(() => howOftenToStruggleToDecideWhatToCook = 'Never');
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // Food waste section
              const Text(
                'Have you ever thrown away food because you didn\'t know how to use the ingredients before they expired?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('Yes, frequently', haveYouThrownAwayFoodBeforeExpired == 'Yes, frequently', () {
                    setState(() => haveYouThrownAwayFoodBeforeExpired = 'Yes, frequently');
                  }),
                  _buildSelectionButton('Occasionally', haveYouThrownAwayFoodBeforeExpired == 'Occasionally', () {
                    setState(() => haveYouThrownAwayFoodBeforeExpired = 'Occasionally');
                  }),
                  _buildSelectionButton('Rarely', haveYouThrownAwayFoodBeforeExpired == 'Rarely', () {
                    setState(() => haveYouThrownAwayFoodBeforeExpired = 'Rarely');
                  }),
                  _buildSelectionButton('Never', haveYouThrownAwayFoodBeforeExpired == 'Never', () {
                    setState(() => haveYouThrownAwayFoodBeforeExpired = 'Never');
                  }),
                ],
              ),
              const SizedBox(height: 30),
              
              // App usage likelihood section
              const Text(
                'How likely are you to use an app that can recognize ingredients through photos and suggest recipes?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSelectionButton('Very likely', howLikelyToUseAppToFindRecipes == 'Very likely', () {
                    setState(() => howLikelyToUseAppToFindRecipes = 'Very likely');
                  }),
                  _buildSelectionButton('Likely', howLikelyToUseAppToFindRecipes == 'Likely', () {
                    setState(() => howLikelyToUseAppToFindRecipes = 'Likely');
                  }),
                  _buildSelectionButton('Neutral', howLikelyToUseAppToFindRecipes == 'Neutral', () {
                    setState(() => howLikelyToUseAppToFindRecipes = 'Neutral');
                  }),
                  _buildSelectionButton('Unlikely', howLikelyToUseAppToFindRecipes == 'Unlikely', () {
                    setState(() => howLikelyToUseAppToFindRecipes = 'Unlikely');
                  }),
                  _buildSelectionButton('Very unlikely', howLikelyToUseAppToFindRecipes == 'Very unlikely', () {
                    setState(() => howLikelyToUseAppToFindRecipes = 'Very unlikely');
                  }),
                ],
              ),
              const SizedBox(height: 40),
              
              // Submit button
              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD9797),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB2F2D5) : const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}