import 'package:clarity/theme.dart';
import 'package:clarity/view/login/auth.dart';
import 'package:clarity/view/login/login_screen.dart';
import 'package:clarity/view/profile/legal_documents_page.dart';
import 'package:clarity/view/subscription/SubscriptionManagementView.dart';
import 'package:flutter/material.dart';
import 'package:clarity/custom/custom_logout_button.dart';
import 'package:clarity/custom/customtilelist.dart';
import 'package:clarity/view/profile/my_account_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_ui_flutter/paywall_result.dart';
import '../subscription/SubscriptionManagement.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SubscriptionManagement subscription = SubscriptionManagement();

  // bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // final appState = MyApp.of(context);
    // if (appState != null) _isDarkMode = appState.isDarkMode;
    // subscription.fetchPackages();
  }

  void _logout(BuildContext context) {
    // Clear global user info
    setState(() {
      AuthService().signOut();
    });

    // Navigate to login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    onPressed: () async {
                      final subscriptionManager = SubscriptionManagement();

                      // Present the paywall
                      final result = await subscriptionManager.presentPaywall();

                      if (result == PaywallResult.purchased) {
                        // User completed purchase
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Purchase successful!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Color.fromARGB(255, 157, 157, 190),
                      overlayColor:
                          Colors.transparent, // 👈 removes ripple/animation
                      splashFactory: NoSplash.splashFactory,
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
            CustomListTile(
              title: 'My Account',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyAccountPage()),
                );
              },
            ),
            CustomListTile(title: 'Subscription Management', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubscriptionManagementView()),
              );
            }),
            Divider(),
            Text(
              'Support',
              style: TextStyle(
                fontSize: 18.sp,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Center(
                      child: Text(
                        "Confirm Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    content: const Text(
                      "Are you sure you want to log out?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
                    ),
                    actionsPadding: EdgeInsets.zero,
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(false), // Cancel
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

                if (shouldLogout == true) {
                  _logout(context); // Call your logout logic
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
