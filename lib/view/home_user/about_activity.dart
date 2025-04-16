import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/local_user_event.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:go_router/go_router.dart';

class AboutActivityPage extends StatefulWidget {
  final User user;

  const AboutActivityPage({
    super.key,
    required this.user,
  });

  @override
  State<AboutActivityPage> createState() => _AboutActivityPageState();
}

class _AboutActivityPageState extends State<AboutActivityPage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('About and Activity'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildUserSection(),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 64.0, left: 16.0, right: 16.0),
              child: _buildActivitySection(),
            ),
            SizedBox(height: 16.0),
            _buildLogOutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 205, 230, 173),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10.0),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 32.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            _buildActivityItem('Viewed Recipes History', () => navigatorKey.currentContext!.push('/${ViewData.history.path}', extra: {
              'user': user,
            }), null),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 173, 216, 230),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10.0),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 32.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            _buildActivityItem('About Us', () {}, null),
            _buildActivityItem('Contact Us', () {}, null),
            _buildActivityItem('Terms of Service', () {}, null),
            _buildActivityItem('Privacy Policy', () {}, null),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String text, VoidCallback onPressed, Color? color) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(),
          child: Row(
            children: [
              Text(text, 
                style: TextStyle(
                  color: color ?? Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogOutSection() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 192, 203),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10.0),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          children: [
            _buildActivityItem('Log Out', _onLogOutClicked, Colors.red),
          ],
        ),
      ),
    );
  }

  void _onLogOutClicked() async {
    // display a dialog to confirm the logout
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Log Out',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to log out?'),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildLogOutDialogButton('Cancel', () => Navigator.pop(context)),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: _buildLogOutDialogButton('Yes', () async {
                    await LocalUserStore.logoutUser();
                    navigatorKey.currentContext!.go('/${ViewData.auth.path}');
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogOutDialogButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(),
      child: TextButton(
        onPressed: onPressed,
        onHover: (value) {},
        onLongPress: () {},
        child: Text(text),
      ),
    );
  }
}