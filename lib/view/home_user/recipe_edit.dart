import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_wyc/event/recipe_event.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/ingredient.dart';
import 'package:fyp_wyc/model/recipe.dart';
import 'package:image_picker/image_picker.dart';

class RecipeEditPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeEditPage({
    super.key, 
    required this.recipe,
  });

  @override
  State<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  late Recipe recipe;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;
  bool _isLoadingImage = false;
  bool _isLoading = false;
  bool _hasChanges = false;

  // Controllers
  late TextEditingController _recipeNameController;
  late TextEditingController _descriptionController;
  
  // Recipe data
  List<Ingredient> _ingredients = [];
  List<String> _steps = [];
  List<Tag> _tags = [];
  int _timeToCookInMinute = 0;
  double _difficulty = 0.0;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    
    // Initialize controllers with recipe data
    _recipeNameController = TextEditingController(text: recipe.recipeName);
    _descriptionController = TextEditingController(text: recipe.description);
    
    // Initialize recipe data
    _ingredients = List.from(recipe.ingredients);
    _steps = List.from(recipe.steps);
    _tags = List.from(recipe.tags);
    _timeToCookInMinute = recipe.timeToCookInMinute;
    _difficulty = recipe.difficulty;
  }

  void _canSave() {
    setState(() {
      _hasChanges = _recipeNameController.text != recipe.recipeName ||
                   _descriptionController.text != recipe.description ||
                   _image != null ||
                   !_areIngredientsEqual(_ingredients, recipe.ingredients) ||
                   !_areStepsEqual(_steps, recipe.steps) ||
                   !_areTagsEqual(_tags, recipe.tags) ||
                   _timeToCookInMinute != recipe.timeToCookInMinute ||
                   _difficulty != (recipe.difficulty);
    });
  }

  bool _areIngredientsEqual(List<Ingredient> a, List<Ingredient> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].ingredientName != b[i].ingredientName ||
          a[i].amount != b[i].amount ||
          a[i].unit != b[i].unit) {
        return false;
      }
    }
    return true;
  }

  bool _areStepsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _areTagsEqual(List<Tag> a, List<Tag> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _onSaveTap() async {
    if (!_validateRecipe()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated recipe
      Recipe updatedRecipe = Recipe(
        recipeID: recipe.recipeID,
        recipeName: _recipeNameController.text,
        description: _descriptionController.text,
        imageUrl: recipe.imageUrl,
        authorEmail: recipe.authorEmail,
        timeToCookInMinute: _timeToCookInMinute,
        difficulty: _difficulty,
        steps: _steps,
        ingredients: _ingredients,
        tags: _tags,
        rating: recipe.rating,
        viewCount: recipe.viewCount,
        savedCount: recipe.savedCount,
      );

      // Save updated recipe
      final response = await RecipeStore.updateRecipe(updatedRecipe, _image != null);
      
      setState(() {
        _isLoading = false;
      });

      MySnackBar.showSnackBar(response['message']);

      if (response['success']) {
        navigatorKey.currentState!.pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      MySnackBar.showSnackBar("Error updating recipe: $e");
    }
  }

  bool _validateRecipe() {
    // Validate recipe name
    if (_recipeNameController.text.isEmpty) {
      MySnackBar.showSnackBar("Recipe name cannot be empty");
      return false;
    }

    // Validate description
    if (_descriptionController.text.isEmpty) {
      MySnackBar.showSnackBar("Recipe description cannot be empty");
      return false;
    }

    // Validate ingredients
    if (_ingredients.isEmpty) {
      MySnackBar.showSnackBar("Recipe must have at least one ingredient");
      return false;
    }

    // Validate steps
    if (_steps.isEmpty) {
      MySnackBar.showSnackBar("Recipe must have at least one step");
      return false;
    }

    // Validate tags
    if (_tags.isEmpty) {
      MySnackBar.showSnackBar("Recipe must have at least one tag");
      return false;
    }

    // Validate cooking time
    if (_timeToCookInMinute <= 0) {
      MySnackBar.showSnackBar("Cooking time must be greater than 0");
      return false;
    }

    return true;
  }

  Future<void> _onEditImageTap() async {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: 120, // Height for exactly two ListTiles
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
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
      _canSave();
    } else {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _pickImage() async {
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
      _canSave();
    } else {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Recipe'),
        actions: [
          if (_hasChanges)
            IconButton(
              onPressed: _isLoading ? null : _onSaveTap,
              icon: _isLoading 
                ? SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(),
                  )
                : Icon(Icons.check),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              SizedBox(height: 20),
              _buildRecipeNameSection(),
              SizedBox(height: 20),
              _buildDescriptionSection(),
              SizedBox(height: 20),
              _buildTimeAndDifficultySection(),
              SizedBox(height: 20),
              _buildIngredientsSection(),
              SizedBox(height: 20),
              _buildInstructionsSection(),
              SizedBox(height: 20),
              _buildTagsSection(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, Icon icon) {
    return MaterialButton(
      onPressed: onPressed,  
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.grey.shade200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icon,
          SizedBox(width: 8),
          Text(text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: GestureDetector(
        onTap: _onEditImageTap,
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15),
          ),
          child: _isLoadingImage 
            ? Center(child: CircularProgressIndicator())
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _image != null
                      ? Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          recipe.imageUrl,
                          fit: BoxFit.cover,
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
                              child: Icon(Icons.image_not_supported, size: 50),
                            );
                          },
                        ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildRecipeNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipe Name',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _recipeNameController,
          decoration: InputDecoration(
            hintText: 'Enter recipe name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          onChanged: (value) => _canSave(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Enter recipe description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          maxLines: 5,
          onChanged: (value) => _canSave(),
        ),
      ],
    );
  }

  Widget _buildTimeAndDifficultySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cooking Time & Difficulty',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cooking Time (minutes): $_timeToCookInMinute',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Slider(
                value: _timeToCookInMinute.toDouble(),
                min: 0,
                max: 180,
                divisions: 36,
                label: _timeToCookInMinute.toString(),
                onChanged: (value) {
                  setState(() {
                    _timeToCookInMinute = value.toInt();
                  });
                  _canSave();
                },
              ),
              SizedBox(height: 16),
              Text(
                'Difficulty Level: ${_difficulty.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Slider(
                value: _difficulty,
                min: 0,
                max: 5,
                divisions: 10,
                label: _difficulty.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _difficulty = value;
                  });
                  _canSave();
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
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildActionButton('Add', () => _showAddIngredientDialog(context), Icon(Icons.add)),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _ingredients.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No ingredients added yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _ingredients.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_ingredients[index].ingredientName),
                      subtitle: Text('${_ingredients[index].amount} ${_ingredients[index].unit.name}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditIngredientDialog(context, index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _ingredients.removeAt(index);
                              });
                              _canSave();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddIngredientDialog(BuildContext context) {
    final TextEditingController ingredientNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController(text: "1.0");
    double amount = 1.0;
    Unit unit = Unit.g;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ingredientNameController,
                  decoration: InputDecoration(
                    labelText: 'Ingredient Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
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
                            amountController.text = amount.toStringAsFixed(1);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 65,
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            try {
                              final newAmount = double.parse(value);
                              if (newAmount >= 0.1 && newAmount <= 1000) {
                                setDialogState(() {
                                  amount = newAmount;
                                });
                              }
                            } catch (e) {
                              // Invalid input, ignore
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
              onPressed: () {
                if (ingredientNameController.text.trim().isNotEmpty) {
                  setState(() {
                    _ingredients.add(
                      Ingredient(
                        ingredientName: ingredientNameController.text.trim(),
                        amount: amount,
                        unit: unit,
                      ),
                    );
                  });
                  _canSave();
                  Navigator.pop(context);
                } else {
                  MySnackBar.showSnackBar('Ingredient name cannot be empty');
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIngredientDialog(BuildContext context, int index) {
    final ingredient = _ingredients[index];
    final TextEditingController ingredientNameController = TextEditingController(text: ingredient.ingredientName);
    final TextEditingController amountController = TextEditingController(text: ingredient.amount.toStringAsFixed(1));
    double amount = ingredient.amount;
    Unit unit = ingredient.unit;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ingredientNameController,
                  decoration: InputDecoration(
                    labelText: 'Ingredient Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
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
                            amountController.text = amount.toStringAsFixed(1);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 65,
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            try {
                              final newAmount = double.parse(value);
                              if (newAmount >= 0.1 && newAmount <= 1000) {
                                setDialogState(() {
                                  amount = newAmount;
                                });
                              }
                            } catch (e) {
                              // Invalid input, ignore
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
              onPressed: () {
                if (ingredientNameController.text.trim().isNotEmpty) {
                  setState(() {
                    _ingredients[index] = Ingredient(
                      ingredientName: ingredientNameController.text.trim(),
                      amount: amount,
                      unit: unit,
                    );
                  });
                  _canSave();
                  Navigator.pop(context);
                } else {
                  MySnackBar.showSnackBar('Ingredient name cannot be empty');
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildActionButton('Add', () => _showAddInstructionDialog(context), Icon(Icons.add)),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _steps.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No instructions added yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : ReorderableListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _steps.removeAt(oldIndex);
                      _steps.insert(newIndex, item);
                      _canSave();
                    });
                  },
                  children: List.generate(
                    _steps.length,
                    (index) => Card(
                      key: ValueKey('step_$index'),
                      elevation: 0,
                      margin: EdgeInsets.symmetric(vertical: 2),
                      color: Colors.grey.shade100,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 4, 38, 40),
                          child: Text('${index + 1}', 
                            style: TextStyle(color: Colors.white)
                          ),
                        ),
                        title: Text(_steps[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditInstructionDialog(context, index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _steps.removeAt(index);
                                });
                                _canSave();
                              },
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.drag_handle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddInstructionDialog(BuildContext context) {
    final TextEditingController instructionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Instruction'),
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
            onPressed: () {
              if (instructionController.text.trim().isNotEmpty) {
                setState(() {
                  _steps.add(instructionController.text.trim());
                });
                _canSave();
                Navigator.pop(context);
              } else {
                MySnackBar.showSnackBar('Instruction cannot be empty');
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditInstructionDialog(BuildContext context, int index) {
    final TextEditingController instructionController = TextEditingController(text: _steps[index]);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Instruction'),
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
            onPressed: () {
              if (instructionController.text.trim().isNotEmpty) {
                setState(() {
                  _steps[index] = instructionController.text.trim();
                });
                _canSave();
                Navigator.pop(context);
              } else {
                MySnackBar.showSnackBar('Instruction cannot be empty');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildActionButton('Add', () => _showAddTagDialog(context), Icon(Icons.add)),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _tags.isEmpty
              ? Center(
                  child: Text(
                    'No tags added yet',
                    style: TextStyle(
                      color: Colors.grey.shade600,
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
                      _canSave();
                    },
                  )).toList(),
                ),
        ),
      ],
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
                    children: Tag.values.where((tag) => !_tags.contains(tag)).map((tag) => GestureDetector(
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
                onPressed: () {
                  if (selectedTags.isNotEmpty) {
                    setState(() {
                      _tags.addAll(selectedTags);
                    });
                    _canSave();
                    Navigator.pop(context);
                  } else {
                    MySnackBar.showSnackBar('Please select at least one tag');
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
