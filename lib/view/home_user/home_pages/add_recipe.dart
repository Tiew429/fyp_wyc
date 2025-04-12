import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/model/ingredient.dart';
import 'package:fyp_wyc/utils/my_button.dart';
import 'package:fyp_wyc/utils/my_text_field.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;
  bool _isLoadingImage = false;
  List<Ingredient> _ingredients = [];

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
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
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
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedImage = await ImageFunctions.cropImage(pickedFile);
      setState(() {
        _image = croppedImage;
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _submitRecipe() async {}

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
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
        controller: _titleController,
        hintText: 'Enter recipe name',
        borderDisplay: false,
        backgroundColor: const Color.fromARGB(255, 236, 237, 248),
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
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Theme.of(context).primaryColor,
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
      ),
    );
  }

  Widget _buildIngredients(Size screenSize) {
    return Container();
  }

  Widget _buildIngredientItem() {
    return SizedBox();
  }

  Widget _plusButton() {
    return Container();
  }

  Widget _buildCookingInstructions(Size screenSize) {
    return Container();
  }

  Widget _buildTimeAndDifficulty(Size screenSize) {
    return Container();
  }

  Widget _buildTags(Size screenSize) {
    return Container();
  }

  Widget _buildSubmitButton(Size screenSize) {
    return MyButton(
      onPressed: _submitRecipe,
      text: 'Submit',
    );
  }
}
