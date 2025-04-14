import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/ingredient.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_button.dart';
import 'package:fyp_wyc/utils/my_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddRecipePage extends StatefulWidget {
  final User? user;

  const AddRecipePage({
    super.key,
    this.user,
  });

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  late User? user;
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;
  bool _isLoadingImage = false;
  final List<Ingredient> _ingredients = [];
  final List<String> _cookingInstructions = [];
  int _timeInMinuteToCook = 0;
  double _difficultyToCook = 0.0;
  final List<Tag> _tags = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: 120, // Height for exactly two ListTiles
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min, // Use minimum space needed
        children: [
          ListTile(
            title: Text('Take Photo'),
            onTap: _takePhoto,
          ),
          Divider(height: 1, thickness: 1),
          ListTile(
            title: Text('Pick Image'),
            onTap: _pickImage,
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    // close the bottom sheet
    Navigator.pop(context);
    setState(() {
      _isLoadingImage = true;
    });
    final pickedFile = await ImageFunctions.takePhoto(_imagePicker);
    if (pickedFile != null) {
      final croppedImage = await ImageFunctions.cropImage(pickedFile);
      setState(() {
        _image = croppedImage;
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _pickImage() async {
    // close the bottom sheet
    Navigator.pop(context);
    setState(() {
      _isLoadingImage = true;
    });
    final pickedFile = await ImageFunctions.pickImage(_imagePicker);
    if (pickedFile != null) {
      final croppedImage = await ImageFunctions.cropImage(pickedFile);
      setState(() {
        _image = croppedImage;
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _addIngredient(String ingredientName, double amount, Unit unit) async {
    if (ingredientName.isNotEmpty) {
      // check if ingredient with same name already exists
      final String newIngredientName = ingredientName.trim().toLowerCase();
      final bool ingredientExists = _ingredients.any(
        (existing) => existing.ingredientName.toLowerCase() == newIngredientName
      );
      
      if (ingredientExists) {
        // show error message if ingredient already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This ingredient already exists in your recipe'),
            backgroundColor: Colors.red.shade700,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // add the new ingredient
        setState(() {
          _ingredients.add(
            Ingredient(
              ingredientName: ingredientName,
              amount: amount,
              unit: unit,
            ),
          );
        });
        Navigator.pop(context);
      }
    }
  }

  Future<void> _addCookingInstruction(String instruction) async {
    if (instruction.isNotEmpty) {
      setState(() {
        _cookingInstructions.add(instruction);
      });
      Navigator.pop(context);
    }
  }

  Future<void> _addTags(List<Tag> tags) async {
    setState(() {
      // check if tag already exists
      for (Tag tag in tags) {
        bool tagExists = _tags.contains(tag);
        
        if (!tagExists) {
          _tags.add(tag);
        }
      }
    });
    Navigator.pop(context);
  }

  bool _validation() {
    // first validate the form fields
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    
    // validate cover image
    if (_image == null) {
      MySnackBar.showSnackBar('Please add a cover image for your recipe');
      return false;
    }
    
    // validate ingredients list
    if (_ingredients.isEmpty) {
      MySnackBar.showSnackBar('Please add at least one ingredient to your recipe');
      return false;
    }
    
    // validate cooking instructions
    if (_cookingInstructions.isEmpty) {
      MySnackBar.showSnackBar('Please add at least one cooking instruction');
      return false;
    }
    
    // validate time
    if (_timeInMinuteToCook <= 0) {
      MySnackBar.showSnackBar('Please set a cooking time greater than zero');
      return false;
    }
    
    // validate difficulty
    if (_difficultyToCook <= 0) {
      MySnackBar.showSnackBar('Please set a difficulty level greater than zero');
      return false;
    }
    
    // validate tags
    if (_tags.isEmpty) {
      MySnackBar.showSnackBar('Please add at least one tag to your recipe');
      return false;
    }

    return true;
  }

  Future<void> _submitRecipe() async {
    if (!_validation()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String recipeName = _recipeNameController.text;
    String description = _descriptionController.text;
    String imageUrl = _image!.path;
    List<Tag> tags = _tags;
    List<Ingredient> ingredients = _ingredients;
    List<String> cookingInstructions = _cookingInstructions;

    // create recipe
    Recipe recipe = Recipe(
      recipeID: '',
      recipeName: recipeName,
      description: description,
      imageUrl: imageUrl,
      tags: tags,
      ingredients: ingredients,
      steps: cookingInstructions,
      authorEmail: user!.email,
      timeToCookInMinute: _timeInMinuteToCook,
      difficulty: _difficultyToCook,
    );

    final response = await RecipeStore.addRecipe(recipe);

    setState(() {
      _isLoading = false;
    });

    MySnackBar.showSnackBar(response['message']);

    if (response['success']) {
      // clear the form fields
      _recipeNameController.clear();
      _descriptionController.clear();
      _ingredients.clear();
      _cookingInstructions.clear();
      _tags.clear();
      _image = null;
      _timeInMinuteToCook = 0;
      _difficultyToCook = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return user == null ? _buildNoLogInUserPage(screenSize) : _buildLogInUserPage(screenSize);
  }

  Widget _buildNoLogInUserPage(Size screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You are not logged in',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Log in to access add recipes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              navigatorKey.currentContext!.push('/${ViewData.auth.path}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 26, 218, 128),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Login / Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildLogInUserPage(Size screenSize) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Recipe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // recipe title
            _buildTitle('Recipe Name'),
            _buildRecipeName(screenSize),
            // cover image
            _buildTitle('Add Cover Image'),
            _buildCoverImageContainer(screenSize),
            // description
            _buildTitle('Recipe Description'),
            _buildDescriptionTextField(screenSize),
            // ingredients
            _buildTitle('Recipe Ingredients'),
            _buildIngredients(screenSize),
            // cooking instructions
            _buildTitle('Cooking Instructions'),
            _buildCookingInstructions(screenSize),
            // time and difficulty
            _buildTitle('Time and Difficulty'),
            _buildTimeAndDifficulty(screenSize),
            // tags
            _buildTitle('Tags'),
            _buildTags(screenSize),
            // submit button
            _buildSubmitButton(screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecipeName(Size screenSize) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: MyTextField(
        controller: _recipeNameController,
        hintText: 'Enter recipe name',
        borderDisplay: false,
        backgroundColor: const Color.fromARGB(255, 236, 237, 248),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Recipe name is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCoverImageContainer(Size screenSize) {
    return Container(
      width: screenSize.width * 0.7,
      height: screenSize.height * 0.2,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 237, 248),
        borderRadius: BorderRadius.circular(25),
      ),
      child: GestureDetector(
        onTap: () => _isLoadingImage ? null : _openBottomSheet(),
        child: _image == null 
            ? Center(
                child: _isLoadingImage
                    ? const CircularProgressIndicator()
                    : Icon(
                        Icons.camera_alt,
                        size: screenSize.width * 0.25,
                        color: Colors.grey[600],
                      ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  children: [
                    Image.file(
                      File(_image!.path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: _openBottomSheet,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDescriptionTextField(Size screenSize) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: MyTextField(
        controller: _descriptionController,
        hintText: 'Enter recipe description',
        borderDisplay: false,
        backgroundColor: const Color.fromARGB(255, 236, 237, 248),
        maxLines: 5,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Recipe description is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildIngredients(Size screenSize) {
    return Column(
      children: [
        Container(
          width: screenSize.width * 0.7,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 236, 237, 248),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // list of ingredients
              _ingredients.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'No ingredients added yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : Column(
                      children: _ingredients
                          .map((ingredient) => _buildIngredientItem(ingredient))
                          .toList(),
                    ),
              SizedBox(height: 15),
              // add ingredient button
              Center(
                child: _plusButton(
                  "Add Ingredient", 
                  () => _showAddIngredientDialog(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(Ingredient ingredient) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${ingredient.ingredientName} (${ingredient.amount} ${ingredient.unit.name})',
              style: TextStyle(fontSize: 16),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _ingredients.remove(ingredient);
              });
            },
            child: Icon(Icons.close, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCookingInstructions(Size screenSize) {
    return Column(
      children: [
        Container(
          width: screenSize.width * 0.7,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 236, 237, 248),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // list of instructions
              _cookingInstructions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'No cooking instructions added yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : Column(
                      children: _cookingInstructions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final instruction = entry.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                margin: EdgeInsets.only(right: 10, top: 2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF00BFA6),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  instruction,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _cookingInstructions.removeAt(index);
                                  });
                                },
                                child: Icon(Icons.close, color: Colors.red, size: 20),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 15),
              // add instruction button
              Center(
                child: _plusButton(
                  "Add Instruction", 
                  () => _showAddInstructionDialog(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAndDifficulty(Size screenSize) {
    return Container(
      width: screenSize.width * 0.7,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 237, 248),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cooking time
          Text(
            'Cooking Time (minutes): $_timeInMinuteToCook',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Slider(
            value: _timeInMinuteToCook.toDouble(),
            min: 0,
            max: 180,
            divisions: 36,
            label: _timeInMinuteToCook.toString(),
            onChanged: (value) {
              setState(() {
                _timeInMinuteToCook = value.toInt();
              });
            },
          ),
          SizedBox(height: 20),
          // difficulty
          Text(
            'Difficulty Level: ${_difficultyToCook.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Slider(
            value: _difficultyToCook,
            min: 0,
            max: 5,
            divisions: 10,
            label: _difficultyToCook.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _difficultyToCook = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Easy'),
              Text('Medium'),
              Text('Hard'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTags(Size screenSize) {
    return Column(
      children: [
        Container(
          width: screenSize.width * 0.7,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 236, 237, 248),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // display selected tags
              _tags.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'No tags added yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) => Chip(
                        label: Text(tag.name),
                        backgroundColor: Color(0xFF00BFA6).withValues(alpha: 0.2),
                        deleteIcon: Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                      )).toList(),
                    ),
              SizedBox(height: 15),
              // add tag button
              Center(
                child: _plusButton(
                  "Add Tag", 
                  () => _showAddTagDialog(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: MyButton(
        onPressed: () async => await _submitRecipe(),
        isLoading: _isLoading,
        text: 'Submit',
      ),
    );
  }

  Widget _plusButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Color(0xFF00BFA6)),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF00BFA6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInstructionDialog(BuildContext context) {
    final TextEditingController instructionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Cooking Instruction'),
        content: TextField(
          controller: instructionController,
          decoration: InputDecoration(
            labelText: 'Instruction',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _addCookingInstruction(instructionController.text);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddIngredientDialog(BuildContext context) {
    final TextEditingController ingredientNameController = TextEditingController();
    double amount = 1.0;
    Unit unit = Unit.g; // Default unit
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ingredient name
                TextField(
                  controller: ingredientNameController,
                  decoration: InputDecoration(
                    labelText: 'Ingredient Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // amount
                Row(
                  children: [
                    Text('Amount: '),
                    Expanded(
                      child: Slider(
                        value: amount,
                        min: 0.1,
                        max: 1000,
                        divisions: 99,
                        label: amount.toStringAsFixed(1),
                        onChanged: (value) {
                          setDialogState(() {
                            amount = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 65,
                      child: GestureDetector(
                        onTap: () {
                          // show a dialog to enter a numeric value directly
                          showDialog(
                            context: context,
                            builder: (context) {
                              final TextEditingController amountController = TextEditingController(
                                text: amount.toString()
                              );
                              return AlertDialog(
                                title: Text('Enter Amount'),
                                content: TextField(
                                  controller: amountController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter a number or fraction (e.g., 1.5 or 3/4)',
                                  ),
                                  onChanged: (value) {
                                    // parse the value as a decimal number
                                    // check if the input contains a fraction (e.g., "3/4")
                                    if (value.contains('/')) {
                                      final parts = value.split('/');
                                      if (parts.length == 2) {
                                        final numerator = double.parse(parts[0].trim());
                                        final denominator = double.parse(parts[1].trim());
                                        if (denominator != 0) {
                                          // convert fraction to decimal
                                          final decimal = numerator / denominator;
                                          amountController.text = decimal.toString();
                                        }
                                      }
                                    } else {
                                      // just validate it's a valid number
                                      double.parse(value);
                                    }
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // try to parse the entered value
                                      try {
                                        double newAmount = double.parse(amountController.text);
                                        if (newAmount > 0) {
                                          // update the amount value
                                          setDialogState(() {
                                            amount = newAmount > 1000 ? 1000 : newAmount;
                                          });
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        // invalid number, show an error message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Please enter a valid number')),
                                        );
                                      }
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            amount.toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF00BFA6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // unit selection
                DropdownButtonFormField<Unit>(
                  value: unit,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: Unit.values.map((Unit unitValue) {
                    return DropdownMenuItem<Unit>(
                      value: unitValue,
                      child: Text(unitValue.name),
                    );
                  }).toList(),
                  onChanged: (Unit? newValue) {
                    if (newValue != null) {
                      setDialogState(() {
                        unit = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: ()  async {
                await _addIngredient(ingredientNameController.text.trim().toLowerCase(), amount, unit);
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    // Set to track selected tags in this dialog
    final Set<Tag> selectedTags = <Tag>{};
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Select Tags'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Tags:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  selectedTags.isEmpty
                      ? Text(
                          'No tags selected',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedTags.map((tag) => Chip(
                            label: Text(tag.name),
                            backgroundColor: Color(0xFF00BFA6).withValues(alpha: 0.2),
                            deleteIcon: Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setDialogState(() {
                                selectedTags.remove(tag);
                              });
                            },
                          )).toList(),
                        ),
                  SizedBox(height: 16),
                  Text(
                    'Available Tags:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Tag.values.map((tag) => GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          if (selectedTags.contains(tag)) {
                            selectedTags.remove(tag);
                          } else {
                            selectedTags.add(tag);
                          }
                        });
                      },
                      child: Chip(
                        label: Text(tag.name),
                        backgroundColor: selectedTags.contains(tag) 
                            ? Color(0xFF00BFA6).withValues(alpha: 0.2)
                            : _tags.contains(tag)
                                ? Color(0xFF00BFA6).withValues(alpha: 0.1) 
                                : Colors.grey[200],
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (selectedTags.isNotEmpty) {
                    await _addTags(selectedTags.toList());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select at least one tag'),
                        backgroundColor: Colors.red.shade700,
                      ),
                    );
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}
