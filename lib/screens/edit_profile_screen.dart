import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  EditProfileScreen({
    required this.onProfileUpdated,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  final picker = ImagePicker();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String selectedGender = '';
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load current user data from Firestore
  Future<void> _loadUserProfile() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    setState(() {
      _usernameController.text = userDoc['username'] ?? '';
      _bioController.text = userDoc['bio'] ?? '';
      _emailController.text = userDoc['email'] ?? '';
      selectedGender = userDoc['gender'] ?? '';
      _genderController.text = selectedGender;
      _birthDateController.text = userDoc['birthDate'] ?? '';
      _locationController.text = userDoc['location'] ?? '';
      _profileImageUrl = userDoc['imageUrl'];
    });
  }

  // Function to handle profile picture options
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Show options to upload image
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Open camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Upload from gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete photo'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _image = null; // Remove the image
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show calendar picker for date of birth
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  // Show gender selection options
  void _showGenderSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              title: Text("Male"),
              leading: Radio(
                value: "Male",
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value.toString();
                    _genderController.text = selectedGender;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            ListTile(
              title: Text("Female"),
              leading: Radio(
                value: "Female",
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value.toString();
                    _genderController.text = selectedGender;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            ListTile(
              title: Text("Prefer not to say"),
              leading: Radio(
                value: "Prefer not to say",
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value.toString();
                    _genderController.text = selectedGender;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to upload image to Firebase Storage in 'users' folder
  Future<String?> _uploadImage(File image) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Using instanceFor with the specific bucket
      FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'skypi-8a884.appspot.com');
      Reference ref = storage.ref().child('users').child('$userId/profile_picture.jpg');

      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  // Function to save profile changes to Firestore
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String? imageUrl;

    if (_image != null) {
      imageUrl = await _uploadImage(_image!);  // Upload image and get the download URL
    }

    try {
      // Update Firestore user document with new data
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': _usernameController.text,
        'bio': _bioController.text,
        'email': _emailController.text,
        'gender': selectedGender,
        'birthDate': _birthDateController.text,
        'location': _locationController.text,
        'imageUrl': imageUrl ?? _profileImageUrl, // Use new image URL or keep the old one
      });

      setState(() {
        _isLoading = false;
      });

      widget.onProfileUpdated(); // Notify parent widget of profile update
      Navigator.pop(context);    // Return to the previous screen
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Edit Profile', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.green)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _showImagePickerOptions, // Show options for profile picture
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (_profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null),
                  child: (_image == null && _profileImageUrl == null)
                      ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.green,
                  )
                      : null,
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _showImagePickerOptions,
                child: Text('Change photo',
                    style: TextStyle(color: Colors.green)),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(_usernameController, 'Username'),
            _buildTextField(_bioController, 'Bio'),
            _buildTextField(_emailController, 'E-mail'),
            GestureDetector(
              onTap: _showGenderSelection,
              child: AbsorbPointer(
                child: _buildTextField(_genderController, 'Gender'),
              ),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(_birthDateController, 'Birth date'),
              ),
            ),
            _buildTextField(_locationController, 'Location'),
            SizedBox(height: 40),
            Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Changes',style: TextStyle(color: Colors.green) ,),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for creating text fields
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
