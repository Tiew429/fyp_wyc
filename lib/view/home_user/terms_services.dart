import 'package:flutter/material.dart';

class TermsServicesPage extends StatelessWidget {
  const TermsServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service for Ingredient Recognition & Recipe Generation App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: February 21, 2025',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Snap2Cook, your personal assistant for ingredient recognition and recipe generation! By using our app, you agree to the following terms and conditions. Please read them carefully.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing or using the Snap2Cook app, you agree to comply with and be bound by these Terms of Service and our Privacy Policy. If you do not agree with these terms, please do not use our app.',
            ),
            _buildSection(
              '2. Description of Services',
              'Snap2Cook provides a platform that allows users to recognize ingredients through image recognition and generate recipes based on the recognized ingredients. We may offer additional features, updates, and services at our discretion.',
            ),
            _buildSection(
              '3. Account Registration',
              'To access certain features of the app, you may need to create an account. You agree to provide accurate and complete information when registering for an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
            ),
            _buildSection(
              '4. Use of the App',
              'You agree to use Snap2Cook only for lawful purposes and in accordance with these Terms of Service. You agree not to use the app to:\n\n'
              '• Engage in any illegal activity or violate any laws.\n\n'
              '• Upload or share content that is harmful, offensive, or violates intellectual property rights.\n\n'
              '• Interfere with or disrupt the functionality of the app.',
            ),
            _buildSection(
              '5. User-Generated Content',
              'You may upload images or share content through the app. By doing so, you retain ownership of your content, but you grant us a license to use, store, and display it in connection with providing our services. You are responsible for ensuring that your content does not violate any third-party rights.',
            ),
            _buildSection(
              '6. Privacy and Data Collection',
              'We collect personal information and usage data as described in our Privacy Policy. By using the app, you consent to the collection and use of your data as outlined.',
            ),
            _buildSection(
              '7. Intellectual Property',
              'All content, features, and functionality of the app are owned by Snap2Cook and are protected by copyright, trademark, and other intellectual property laws. You may not copy, modify, distribute, or create derivative works of any content from the app without our express permission.',
            ),
            _buildSection(
              '8. Termination',
              'We reserve the right to suspend or terminate your account or access to the app at our discretion, without notice, for any reason, including if you violate these Terms of Service. Upon termination, you must immediately cease using the app.',
            ),
            _buildSection(
              '9. Limitation of Liability',
              'To the fullest extent permitted by law, Snap2Cook and its affiliates will not be liable for any indirect, incidental, special, or consequential damages, including loss of data, profits, or use of the app. Our liability is limited to the maximum extent permitted by applicable law.',
            ),
            _buildSection(
              '10. Disclaimers',
              'The app is provided "as is" and "as available" without warranties of any kind, either express or implied, including but not limited to implied warranties of merchantability or fitness for a particular purpose. We do not guarantee the accuracy, reliability, or availability of the app.',
            ),
            _buildSection(
              '11. Modifications to the Terms',
              'We may update these Terms of Service from time to time. Any changes will be posted on this page with an updated effective date. Your continued use of the app after any changes to the Terms of Service will constitute your acceptance of the updated terms.',
            ),
            _buildSection(
              '12. Governing Law',
              'These Terms of Service are governed by and construed in accordance with the laws of Malaysia, without regard to its conflict of law principles. Any disputes will be resolved in the courts of Malaysia.',
            ),
            _buildSection(
              '13. Contact Information',
              'If you have any questions or concerns regarding these Terms of Service, please contact us at:\n\n'
              'Snap2Cook\n'
              'Email: support@snap2cook.app\n'
              'Website: https://www.snap2cook.app',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}