import 'package:flutter/material.dart';

class HelpAndSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Help and Support', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.green)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequently Asked Questions (FAQs)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _faqItem('1. What is SKYPI?',
                  'SKYPI is a pioneering platform designed to enhance technical skills through daily tasks, personalized feedback, and expert assessments.'),
              _faqItem('2. How do I create an account?',
                  'To create an account, simply download the app, click on "Sign Up," and fill in the required information.'),
              _faqItem('3. How can I submit my tasks?',
                  'You can submit your tasks directly through the app. Go to the "Upload Tasks" section, select your task, and follow the submission instructions.'),
              const SizedBox(height: 20),
              const Text(
                'Contact Us',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('If you need further assistance, please reach out to our support team:'),
              Text('Email: skypi.help@gamil.com'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(answer),
        ],
      ),
    );
  }
}
