import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skypi/screens/Help_And_Support_screen.dart';
import 'package:skypi/screens/about_screen.dart';
import 'package:skypi/screens/notification_screen.dart';
import 'PrivacySecurityScreen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'application_screen.dart'; // Import ApplicationScreen

class SettingsScreen extends StatefulWidget {
  final String userId;

  SettingsScreen({required this.userId});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String currentUsername;
  late String currentBio;
  late String userEmail; // Variable to store email

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      if (userDoc.exists) {
        setState(() {
          currentUsername = userDoc['username'] ?? 'No username';
          currentBio = userDoc['bio'] ?? 'No bio';
          userEmail = userDoc['email'] ?? 'No email'; // Fetch the email
        });
      }
    } catch (e) {
      print('Failed to load user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add Your Details in Edit Profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          _buildSettingsOption(
            context,
            icon: Icons.info_outline,
            iconColor: Colors.green,
            text: 'About',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
          _buildSettingsOption(
            context,
            icon: Icons.assignment,
            iconColor: Colors.green,
            text: 'Applications', // New option for Applications
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ApplicationScreen(
                    userEmail: userEmail
                )), // Navigate to ApplicationScreen
              );
            },
          ),
          _buildSettingsOption(
            context,
            icon: Icons.edit,
            text: 'Edit profile',
            iconColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    onProfileUpdated: _updateProfile,
                  ),
                ),
              );
            },
          ),
          _buildSettingsOption(
            context,
            icon: Icons.lock,
            iconColor: Colors.green,
            text: 'Privacy & Security',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacySecurityScreen()),
              );
            },
          ),
          _buildSettingsOption(
            context,
            icon: Icons.join_inner,
            iconColor: Colors.green,
            text: 'Projects',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostsScreen()),
              );
            },
          ),
          _buildSettingsOption(
            context,
            icon: Icons.help_outline,
            iconColor: Colors.green,
            text: 'Help and Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpAndSupportScreen()),
              );
            },
          ),
          Divider(),
          _buildSettingsOption(
            context,
            icon: Icons.logout,
            text: 'Logout',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context,
      {required IconData icon,
        required String text,
        required Function() onTap,
        Color iconColor = Colors.green,
        Color textColor = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.green, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _updateProfile() async {
    // Refresh user profile data from Firestore after profile update
    await _loadUserProfile();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
  }
}
