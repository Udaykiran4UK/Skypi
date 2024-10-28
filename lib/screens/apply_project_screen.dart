import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ApplyProjectScreen extends StatefulWidget {
  final String receiverEmail; // Add a parameter for receiver email
  final String receiverPhone; // Add a parameter for receiver phone number
  final String projectName; // Add a parameter for project name
  final List<String> skills; // Add a parameter for skills
  final List<String> roles; // Add a parameter for roles

  ApplyProjectScreen({
    required this.receiverEmail,
    required this.receiverPhone,
    required this.projectName,
    required this.skills,
    required this.roles,
  }); // Constructor to accept receiver email, phone number, project name, skills, and roles

  @override
  _ApplyProjectScreenState createState() => _ApplyProjectScreenState();
}

class _ApplyProjectScreenState extends State<ApplyProjectScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController(); // Portfolio URL controller
  final TextEditingController _receiverEmailController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();

  String? _cvFileName;
  File? _cvFile;
  String? _selectedRequirement; // Variable to hold the selected requirement
  String? _selectedRole; // Variable to hold the selected role

  final FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'skypi-8a884.appspot.com'); // Use the specified storage bucket

  @override
  void initState() {
    super.initState();
    _receiverEmailController.text = widget.receiverEmail; // Set receiver email from widget
    _receiverPhoneController.text = widget.receiverPhone; // Set receiver phone from widget
    _projectNameController.text = widget.projectName; // Set project name from widget
  }

  Future<void> _applyForProject() async {
    if (_cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload your CV.')),
      );
      return;
    }

    try {
      // Upload CV to Firebase Storage
      String filePathCV = 'project_applications/${_cvFileName}';
      TaskSnapshot cvSnapshot = await storage.ref(filePathCV).putFile(_cvFile!);
      String cvDownloadUrl = await cvSnapshot.ref.getDownloadURL();

      // Store application details in Firestore
      await FirebaseFirestore.instance.collection('project_applications').add({
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'portfolio': _portfolioController.text, // Store portfolio URL (no file)
        'receiverEmail': _receiverEmailController.text,
        'receiverPhone': _receiverPhoneController.text,
        'projectName': _projectNameController.text,
        'selectedSkill': _selectedRequirement,
        'selectedRole': _selectedRole,
        'cvUrl': cvDownloadUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submitted successfully!')),
      );

      // Clear fields after submission
      _fullNameController.clear();
      _emailController.clear();
      _portfolioController.clear();
      _receiverEmailController.clear();
      _receiverPhoneController.clear();
      _projectNameController.clear();
      setState(() {
        _cvFile = null;
        _cvFileName = null;
        _selectedRequirement = null;
        _selectedRole = null;
      });
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting application: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply For Role', style: TextStyle(
            fontSize: 24,fontWeight: FontWeight.bold,
            color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Your Name', _fullNameController),
            const SizedBox(height: 20),
            _buildTextField('Name of the Project', _projectNameController),
            const SizedBox(height: 20),
            _buildTextField('Your Email Address', _emailController),
            SizedBox(height: 20),
            _buildUploadFileButton(),
            SizedBox(height: 20),
            _buildTextField('Receiver Email', _receiverEmailController),
            SizedBox(height: 20),
            _buildTextField('Receiver Phone Number', _receiverPhoneController), // New receiver phone number field
            SizedBox(height: 20),
            _buildDropdownField('Your Skills', widget.skills, (value) {
              setState(() {
                _selectedRequirement = value; // Update selected requirement
              });
            }),
            SizedBox(height: 20),
            _buildDropdownField('Your Role', widget.roles, (value) {
              setState(() {
                _selectedRole = value; // Update selected role
              });
            }),
            SizedBox(height: 20),
            _buildTextField('Website, Blog, or Portfolio URL', _portfolioController, hintText: 'https://.....'), // Input for website or blog
            SizedBox(height: 20),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hintText ?? label, // Use provided hintText or the label as default
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: label == 'Your Skills' ? _selectedRequirement : _selectedRole,
          onChanged: onChanged,
          items: items.toSet().map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null ? 'Please select a $label' : null,
        ),
      ],
    );
  }

  Widget _buildUploadFileButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload CV', style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        InkWell(
          onTap: () async {
            // Handle file upload using file_picker
            final result = await FilePicker.platform.pickFiles(
              allowedExtensions: ['pdf', 'jpg', 'png'], // Specify allowed file types
              type: FileType.custom, // Allow custom file types
            );

            if (result != null && result.files.isNotEmpty) {
              setState(() {
                _cvFileName = result.files.first.name; // Set the name of the file
                _cvFile = File(result.files.first.path!); // Store the file
              });
            }
          },
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: _cvFileName == null
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Upload File', style: TextStyle(color: Colors.grey)),
                ],
              )
                  : Text('$_cvFileName', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _applyForProject, // Call apply method
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        minimumSize: Size(double.infinity, 50),
      ),
      child: const Text(
        'Apply',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
