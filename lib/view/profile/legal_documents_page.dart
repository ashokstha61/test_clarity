import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum DocumentType { termsAndConditions, privacyPolicy, faq }

class LegalDocumentsPage extends StatelessWidget {
  final DocumentType type;

  const LegalDocumentsPage({super.key, required this.type});

  String _getTitle() {
    switch (type) {
      case DocumentType.termsAndConditions:
        return "Terms & Conditions";
      case DocumentType.privacyPolicy:
        return "Privacy Policy";
      case DocumentType.faq:
        return "FAQs";
    }
  }

  String _getDocumentText() {
    switch (type) {
      case DocumentType.termsAndConditions:
        return '''
TERMS AND CONDITIONS FOR SLEEPHORIA

1. ACCEPTANCE OF TERMS
By accessing or using the Sleephoria mobile application ("App") developed by Meekha Tech Pvt Ltd ("Company"), you agree to be bound by these Terms and Conditions.

2. LICENSE GRANT
The Company grants you a limited, non-exclusive, non-transferable license to use the App for personal, non-commercial purposes.

3. USER RESPONSIBILITIES
You agree not to:
- Reverse engineer or attempt to extract source code
- Use the App for any illegal purpose
- Disrupt the App's functionality

4. SUBSCRIPTIONS
Sleephoria may offer auto-renewing subscriptions. Payment will be charged to your iTunes account at confirmation of purchase.

5. DISCLAIMER
The App is provided "as is" without warranties of any kind. The Company does not guarantee that the App will meet your requirements.

6. LIMITATION OF LIABILITY
Meekha Tech Pvt Ltd shall not be liable for any indirect, incidental damages arising from use of the App.

7. CHANGES TO TERMS
We reserve the right to modify these terms at any time. Continued use constitutes acceptance of modified terms.

Contact: admin@meekha.co
''';

      case DocumentType.privacyPolicy:
        return '''
PRIVACY POLICY FOR SLEEPHORIA

1. INFORMATION WE COLLECT
Sleephoria ("App") by Meekha Tech Pvt Ltd ("Company") may collect:
- Usage data (app interactions)
- Device information (model, OS version)
- Subscription purchase history

2. HOW WE USE INFORMATION
We use collected information to:
- Provide and improve the App
- Process subscriptions
- Analyze usage patterns
- Respond to customer support requests

3. DATA SHARING
We do not sell your personal data. We may share information with:
- Service providers (analytics, payment processing)
- When required by law

4. DATA SECURITY
We implement industry-standard measures to protect your data, but no method is 100% secure.

5. CHILDREN'S PRIVACY
The App is not intended for children under 13. We do not knowingly collect data from children.

6. CHANGES TO THIS POLICY
We may update this policy periodically. We will notify users of significant changes.

7. YOUR RIGHTS
Depending on your jurisdiction, you may have rights to:
- Access your data
- Request deletion
- Opt-out of data collection

8. CONTACT US
For privacy-related inquiries:
Email: admin@meekha.co
Address: Meekha Tech Pvt Ltd, Thamel
''';

      case DocumentType.faq:
        return '''
Q1: What is Sleephoria?
A: Sleephoria is a relaxing sleep sound app developed by Meekha Tech Pvt Ltd that helps you sleep better using ambient sounds.

Q2: Is Sleephoria free?
A: Yes, Sleephoria offers a free version with limited sounds. You can unlock all premium content with a subscription.

Q3: Can I use Sleephoria offline?
A: Yes, once sounds are downloaded, you can listen to them offline.

Q4: How do I contact support?
A: You can reach us at admin@meekha.co or via the Contact Us section in the app.

Q5: Can I mix multiple sounds together?
A: Yes! Sleephoria lets you layer and adjust volumes of multiple ambient sounds simultaneously in the Sound Mixer.

Q6: How do I enable dark mode?
A: Go to 'Profile Tab' → Go to 'My Account' → Enable Dark Mode using the toggle. The app will remember your preference.

Q7: How do I save my Mixed Sounds?
A: Go to Sound Mixing Screen → Tap 'Save Mix' Button on the bottom right and it will be saved in the Favorites tab.

Q8: Can I set a timer to stop sounds automatically?
A: Yes, use the Sleep Timer feature from the Sound Mixer screen to stop playback after a chosen duration.
''';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _getDocumentText(),
          style: TextStyle(fontSize: 16.sp, height: 1.5),
        ),
      ),
    );
  }
}
