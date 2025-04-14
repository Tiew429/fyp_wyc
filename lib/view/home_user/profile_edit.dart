import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_wyc/event/user_event.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  final User user;

  const ProfileEditPage({
    super.key,
    required this.user,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late User currentUser;

  bool isSaveEnabled = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imageFile;
  final _displayNameController = TextEditingController();
  final _aboutMeController = TextEditingController();
  late String _gender;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    _displayNameController.text = currentUser.username;
    _aboutMeController.text = currentUser.aboutMe;
    _gender = currentUser.gender;
  }

  void _onChangeSaveable() {
    isSaveEnabled = _imageFile != null || 
      currentUser.username != _displayNameController.text || 
      currentUser.aboutMe != _aboutMeController.text || 
      currentUser.gender != _gender;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImageFunctions.pickImage(_imagePicker);
    if (pickedFile != null) {
      final croppedImage = await ImageFunctions.cropImage(pickedFile);
      setState(() {
        _imageFile = croppedImage;
        _onChangeSaveable();
      });
    }
  }

  Future<void> _saveUser() async {
    setState(() {
      isLoading = true;
    });

    String email = currentUser.email;
    String newName = _displayNameController.text;
    String newAboutMe = _aboutMeController.text;

    final response = await UserStore.updateUser(email, _imageFile?.path, newName, newAboutMe, _gender);

    if (response['success']) {
      setState(() {
        currentUser.username = newName;
        currentUser.aboutMe = newAboutMe;
        currentUser.gender = _gender;
        isLoading = false;
      });
      MySnackBar.showSnackBar(response['message']);
      navigatorKey.currentContext!.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: isSaveEnabled ? () => _saveUser() : null,
            child: Text('Save',
              style: TextStyle(
                color: isSaveEnabled ? Color(0xFF00BFA6) : Colors.grey[700],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAvatarWithCameraSection(screenSize),
                      _buildDisplayNameSection(screenSize),
                      _buildAboutMeSection(screenSize),
                      _buildGenderSection(screenSize),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00BFA6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithCameraSection(Size screenSize) {
    return Stack(
      children: [
        MyAvatar(
          radius: screenSize.width * 0.13,
          image: _imageFile != null ? Image.file(File(_imageFile!.path)) : UserStore.currentUserAvatar,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async => await _pickImage(),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 152, 189, 252),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.camera_alt_outlined,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayNameSection(Size scrennSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionName('Display Name'),
        SizedBox(
          width: scrennSize.width * 0.8,
          child: TextField(
            controller: _displayNameController,
            onChanged: (String value) {
              setState(() {
                _onChangeSaveable();
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter your display name',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutMeSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionName('About Me'),
        SizedBox(
          width: screenSize.width * 0.8,
          child: TextField(
            controller: _aboutMeController,
            onChanged: (String value) {
              setState(() {
                _onChangeSaveable();
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter your about me',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSection(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionName('Gender'),
        // build the gender dropdown
        SizedBox(
          width: screenSize.width * 0.8,
          child: DropdownButton<String>(
            value: _gender.isEmpty ? null : _gender,
            hint: Text('Select gender'),
            onChanged: (String? newValue) {
              setState(() {
                _gender = newValue ?? '';
                _onChangeSaveable();
              });
            },
            items: ['Male', 'Female', 'Not to say'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionName(String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        name,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
