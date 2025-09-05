import 'package:clarity/main.dart';
import 'package:clarity/theme.dart';
import 'package:clarity/view/login/login_screen.dart';
import 'package:clarity/view/profile/legal_documents_page.dart';
import 'package:flutter/material.dart';
import 'package:clarity/custom/custom_logout_button.dart';
import 'package:clarity/custom/customtilelist.dart';
import 'package:clarity/view/profile/my_account_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoggedIn = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    final appState = MyApp.of(context);
    if (appState != null) _isDarkMode = appState.isDarkMode;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                      Text(
                        'Free',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Color.fromARGB(255, 157, 157, 190),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0.r),
                      ),
                    ),
                    child: Text(
                      'Upgrade',
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
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
                CustomListTile(title: 'Subscription Management', onTap: () {}),

                Divider(),

                Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: ThemeHelper.textTitle(context),
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
                  title: 'Log Out',
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false, // user must tap a button
                      builder: (ctx) => AlertDialog(
                        title: Center(
                          child: const Text(
                            "Confirm Logout",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Are you sure you want to log out?",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                              ),
                            ),

                            Divider(),
                          ],
                        ),
                        actionsPadding: EdgeInsets.zero,
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Cancel
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.blue,

                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(true), // Confirm
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.red,

                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );

                    if (!mounted) return;

                    if (shouldLogout == true) {
                      _logout(context); // perform logout
                    }
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
