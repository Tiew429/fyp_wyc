import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last updated: March 1, 2025',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'At Snap2Cook, we are committed to protecting your privacy. This Privacy Policy outlines the types of personal information we collect, how we use it, and the steps we take to ensure your information is secure while using our Ingredient Recognition and Recipe Generation app.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information We Collect',
              'We collect the following types of information when you use our app:\n\n'
              '• Personal Information: We may collect personal information such as your name and email address if you create an account, sign in, or contact us for support.\n\n'
              '• Device Information: We may collect information about the device you use, including the type, operating system, and unique device identifiers.\n\n'
              '• Usage Data: We collect data on how you interact with the app, including features you use, searches, and interactions with recipes.',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use the collected information for the following purposes:\n\n'
              '• Providing Services: To process your requests, recognize ingredients, and generate personalized recipes based on the ingredients you input.\n\n'
              '• Improvement: To improve our app by analyzing usage data and feedback.\n\n'
              '• Communication: To send you updates, new features, and promotions (if you\'ve opted in for notifications).',
            ),
            _buildSection(
              '3. Data Security',
              'We take appropriate measures to protect your data from unauthorized access, alteration, disclosure, or destruction. However, no data transmission over the internet or method of electronic storage can be guaranteed to be 100% secure.',
            ),
            _buildSection(
              '4. Third-Party Services',
              'Our app may contain links to third-party services (such as social media platforms or analytics services). We are not responsible for the privacy practices of these third parties. Please review their privacy policies before using their services.',
            ),
            _buildSection(
              '5. Data Retention',
              'We retain your personal information for as long as needed to provide our services or as required by law. You can delete your account at any time by contacting us.',
            ),
            _buildSection(
              '6. Your Rights',
              'Depending on your location, you may have certain rights regarding your personal data, including the right to access, update, or delete your information. If you wish to exercise these rights, please contact us at support@snap2cook.app.',
            ),
            _buildSection(
              '7. Children\'s Privacy',
              'Our app is not intended for use by children under the age of 13. We do not knowingly collect personal information from children. If you believe we have inadvertently collected such information, please contact us, and we will take steps to remove it.',
            ),
            _buildSection(
              '8. Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated effective date. We encourage you to review this policy periodically.',
            ),
            _buildSection(
              '9. Contact Us',
              'If you have any questions or concerns about this Privacy Policy, please contact us at:\n\n'
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