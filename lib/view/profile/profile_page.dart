import 'package:clarity/view/login/login_screen.dart';
import 'package:clarity/view/profile/legal_documents_page.dart';
import 'package:clarity/view/signin/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:clarity/custom/custom_logout_button.dart';
import 'package:clarity/custom/customtilelist.dart';
import 'package:clarity/view/profile/my_account_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoggedIn = true;

  @override
  void initState() {
    super.initState();
  }

  void _logout(BuildContext context) {
    // Clear global user info
    setState(() {
      isLoggedIn = false;
    });

    // Navigate to login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: EdgeInsets.all(16.0),

              decoration: BoxDecoration(
                color: Color.fromRGBO(59, 59, 122, 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscription',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        'Free',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Color(0xFFD3D3E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Upgrade'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                CustomListTile(
                  title: 'My Account',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyAccountPage()),
                    );
                  },
                ),
                CustomListTile(title: 'Notifications', onTap: () {}),
                CustomListTile(title: 'Goals and Programs', onTap: () {}),
                CustomListTile(title: 'Subscription Management', onTap: () {}),

                Divider(),
                ListTile(
                  title: Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(51, 51, 109, 1),
                    ),
                  ),
                ),
                CustomListTile(
                  title: 'FAQ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LegalDocumentsPage(type: DocumentType.faq),
                      ),
                    );
                  },
                ),

                CustomListTile(
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LegalDocumentsPage(
                          type: DocumentType.privacyPolicy,
                        ),
                      ),
                    );
                  },
                ),
                CustomListTile(
                  title: 'Terms and Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LegalDocumentsPage(
                          type: DocumentType.termsAndConditions,
                        ),
                      ),
                    );
                  },
                ),
                CustomLogoutButton(
                  title: 'Log out',
                  onPressed: () {
                    _logout(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
