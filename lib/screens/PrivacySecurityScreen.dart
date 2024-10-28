import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Privacy & Security', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.green)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SKYPI Privacy and Security Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'At SKYPI, we prioritize the protection of our users\' data and adhere to the highest industry standards. This policy outlines our commitment to safeguarding user information.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('1. Data Collection and Use'),
            _buildBulletText('SKYPI collects personal and technical data, including:'),
            _buildBulletText('• User profiles (name, email)'),
            _buildBulletText('• Task submissions and solutions'),
            _buildBulletText('• Progress tracking and analytics'),
            _buildBulletText('We use this data to:'),
            _buildBulletText('• Provide personalized learning experiences'),
            _buildBulletText('• Offer tailored feedback and assessments'),
            _buildBulletText('• Enhance platform performance and security'),
            _buildBulletText('• Communicate updates and support'),
            SizedBox(height: 16.0),
            _buildSectionTitle('2. Data Storage and Protection'),
            _buildBulletText('We implement robust security measures to protect user data, including:'),
            _buildBulletText('• Encryption: AES-256 encryption for data at rest and in transit'),
            _buildBulletText('• Secure Servers: Utilization of secure servers with regular backups'),
            _buildBulletText('• Access Controls: Multi-factor authentication and role-based permissions'),
            _buildBulletText('• Regular Audits: Ongoing security audits and penetration testing'),
            SizedBox(height: 16.0),
            _buildSectionTitle('3. User Rights and Consent'),
            _buildBulletText('Users have the right to:'),
            _buildBulletText('• Access and update their personal data'),
            _buildBulletText('• Withdraw consent for data processing'),
            _buildBulletText('• Request data deletion (subject to applicable laws)'),
            _buildBulletText('• Opt-out of promotional communications'),
            SizedBox(height: 16.0),
            _buildSectionTitle('4. Data Sharing and Disclosure'),
            _buildBulletText('SKYPI does not share user data with third parties, except:'),
            _buildBulletText('• With user consent'),
            _buildBulletText('• To comply with legal obligations'),
            _buildBulletText('• With trusted service providers (e.g., email services)'),
            SizedBox(height: 16.0),
            _buildSectionTitle('5. Security Measures'),
            _buildBulletText('We employ the following security practices:'),
            _buildBulletText('• Firewall protection and intrusion detection systems'),
            _buildBulletText('• Regular software updates and patches'),
            _buildBulletText('• Secure coding practices following OWASP guidelines'),
            _buildBulletText('• Incident response and disaster recovery plans'),
            SizedBox(height: 16.0),
            _buildSectionTitle('6. Compliance and Certification'),
            _buildBulletText('SKYPI adheres to relevant regulations and best practices, including:'),
            _buildBulletText('• General Data Protection Regulation (GDPR)'),
            _buildBulletText('• Children\'s Online Privacy Protection Act (COPPA)'),
            SizedBox(height: 16.0),
            _buildSectionTitle('7. Policy Updates'),
            _buildBulletText('This policy may be updated. Changes will be effective immediately upon posting. By using SKYPI, users acknowledge acceptance of this Privacy and Security Policy.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
