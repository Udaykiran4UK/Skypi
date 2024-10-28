import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProjectPostScreen extends StatefulWidget {
  @override
  _ProjectPostScreenState createState() => _ProjectPostScreenState();
}

class _ProjectPostScreenState extends State<ProjectPostScreen> {
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _projectDescriptionController = TextEditingController();
  final TextEditingController _newSkillController = TextEditingController();
  final TextEditingController _newRoleController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _customCityController = TextEditingController();
  final TextEditingController _customDurationController = TextEditingController(); // For custom duration
  final TextEditingController _emailController = TextEditingController(); // For email
  final TextEditingController _phoneController = TextEditingController(); // For phone number

  String _selectedDuration = '1 month'; // Initial value for dropdown
  bool _isCustomDuration = false; // Whether custom duration is selected

  String _selectedExperienceLevel = 'Beginner';
  int _timeCommitment = 1;
  String _selectedCollaborationStyle = 'Real-time';
  List<String> _selectedSkills = [];
  List<String> _selectedRoles = [];

  List<String> _skills = ['React', 'Node.js', 'UI/UX Design', 'DevOps', 'Python'];
  List<String> _roles = ['Frontend Developer', 'Backend Developer', 'UI Designer', 'Server Manager'];
  final List<String> _experienceLevels = ['Beginner', 'Intermediate', 'Expert'];
  final List<String> _collaborationStyles = ['Real-time', 'Asynchronous', 'Scheduled Check-ins'];

  String _organizerType = 'Private/Self';
  bool _isCompanySelected = false;

  String _selectedWorkType = 'Work from Home';
  String? _selectedCity;
  final List<String> _cities = ['Hyderabad', 'Mumbai', 'Bangalore', 'Chennai', 'Delhi', 'Others'];
  bool _isOtherCitySelected = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'skypi-8a884.appspot.com');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post a New Project',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _projectTitleController,
              decoration: InputDecoration(
                labelText: 'Project Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _projectDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Project Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            _buildDurationDropdown(), // Replace with duration dropdown
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Skills Needed', style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _addNewSkillDialog(),
                ),
              ],
            ),
            _buildMultiSelectField(_skills, _selectedSkills),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Roles Available', style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _addNewRoleDialog(),
                ),
              ],
            ),
            _buildMultiSelectField(_roles, _selectedRoles),
            SizedBox(height: 16),
            _buildDropdownField('Required Experience Level', _experienceLevels, _selectedExperienceLevel, (value) {
              setState(() {
                _selectedExperienceLevel = value!;
              });
            }),
            SizedBox(height: 16),
            ListTile(
              title: Text('Expected Time Commitment (hours/week)'),
              subtitle: Slider(
                value: _timeCommitment.toDouble(),
                min: 1,
                max: 40,
                divisions: 39,
                label: _timeCommitment.toString(),
                onChanged: (double value) {
                  setState(() {
                    _timeCommitment = value.toInt();
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            _buildDropdownField('Preferred Collaboration Style', _collaborationStyles, _selectedCollaborationStyle, (value) {
              setState(() {
                _selectedCollaborationStyle = value!;
              });
            }),
            SizedBox(height: 16),
            _buildOrganizerTypeDropdown(),
            SizedBox(height: 16),
            if (_isCompanySelected)
              TextField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: _isCompanySelected ? 16 : 0),
            // Email and Phone number fields
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            _buildWorkTypeDropdown(),
            if (_selectedWorkType == 'On-site') ...[
              _buildCityDropdown(),
              if (_isOtherCitySelected) _buildCustomCityInput(),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _postProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Post Project',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Duration Dropdown
  Widget _buildDurationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Duration', style: TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: _selectedDuration,
          isExpanded: true,
          items: ['1 month', '3 months', '6 months', '12 months', 'Custom'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedDuration = value!;
              _isCustomDuration = value == 'Custom';
              _customDurationController.clear(); // Reset custom duration input
            });
          },
        ),
        if (_isCustomDuration)
          TextField(
            controller: _customDurationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter Custom Duration (in months)',
              border: OutlineInputBorder(),
            ),
          ),
      ],
    );
  }

  Widget _buildMultiSelectField(List<String> options, List<String> selectedValues) {
    return Wrap(
      spacing: 8.0,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: Colors.green,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                selectedValues.add(option);
              } else {
                selectedValues.remove(option);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildOrganizerTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Organizer Type', style: TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: _organizerType,
          isExpanded: true,
          items: ['Private/Self', 'Company'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _organizerType = value!;
              _isCompanySelected = value == 'Company';
            });
          },
        ),
      ],
    );
  }

  Widget _buildWorkTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Work Type', style: TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: _selectedWorkType,
          isExpanded: true,
          items: ['Work from Home', 'On-site'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedWorkType = value!;
              _selectedCity = null; // Reset city when changing work type
              _isOtherCitySelected = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('City', style: TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          hint: Text('Select a city'),
          items: _cities.map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedCity = value!;
              _isOtherCitySelected = value == 'Others';
            });
          },
        ),
      ],
    );
  }

  Widget _buildCustomCityInput() {
    return TextField(
      controller: _customCityController,
      decoration: InputDecoration(
        labelText: 'Enter Custom City',
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _postProject() async {
    try {
      final projectData = {
        'title': _projectTitleController.text,
        'description': _projectDescriptionController.text,
        'skills': _selectedSkills,
        'roles': _selectedRoles,
        'experienceLevel': _selectedExperienceLevel,
        'timeCommitment': _timeCommitment,
        'collaborationStyle': _selectedCollaborationStyle,
        'organizerType': _organizerType,
        'companyName': _isCompanySelected ? _companyNameController.text : null,
        'duration': _isCustomDuration ? _customDurationController.text : _selectedDuration,
        'workType': _selectedWorkType,
        'city': _selectedWorkType == 'On-site'
            ? (_isOtherCitySelected ? _customCityController.text : _selectedCity)
            : null,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'isHiring': 'yes',

      };

      await firestore.collection('projects').add(projectData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Project posted successfully!'),
        backgroundColor: Colors.green,
      ));

      // Clear the form after posting
      _projectTitleController.clear();
      _projectDescriptionController.clear();
      _selectedSkills.clear();
      _selectedRoles.clear();
      _emailController.clear();
      _phoneController.clear();
      _customDurationController.clear();
      _companyNameController.clear();
      _customCityController.clear();
      setState(() {
        _selectedDuration = '1 month';
        _isCustomDuration = false;
        _isCompanySelected = false;
        _selectedWorkType = 'Work from Home';
        _selectedCity = null;
        _isOtherCitySelected = false;
        _timeCommitment = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error posting project: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Dialog to add new skill
  Future<void> _addNewSkillDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Skill'),
          content: TextField(
            controller: _newSkillController,
            decoration: InputDecoration(labelText: 'Enter Skill'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_newSkillController.text.isNotEmpty) {
                  setState(() {
                    _skills.add(_newSkillController.text);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Dialog to add new role
  Future<void> _addNewRoleDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Role'),
          content: TextField(
            controller: _newRoleController,
            decoration: InputDecoration(labelText: 'Enter Role'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_newRoleController.text.isNotEmpty) {
                  setState(() {
                    _roles.add(_newRoleController.text);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
