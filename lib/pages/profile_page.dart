import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_provider.dart';
import 'screens/login_screen.dart';
import 'private/dashboard_page.dart';
import '../comps/animate_route.dart';
import '../utils/db_connect.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (appProvider.username != null && appProvider.userEmail != null)
                GoldCard(
                  username: appProvider.username!,
                  email: appProvider.userEmail!,
                ),
              SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {
                  _showModifyUsernameModal(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Change Username"),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (appProvider.userLevel == 'user') // Show only for admin users
                CardWithBorder(
                  icon: Icons.dashboard,
                  text: 'Dashboard',
                  onTap: () {
                    Navigator.of(context).push(animatedDart(
                      Offset(-1.0, 0.0),
                      DashboardPage(),
                    ));
                  },
                ),
              CardWithBorder(
                icon: Icons.info,
                text: 'About Us',
              ),
              CardWithBorder(
                icon: Icons.help,
                text: 'FAQ',
              ),
              CardWithBorder(
                icon: Icons.privacy_tip,
                text: 'Privacy Policy',
              ),
              CardWithBorder(
                icon: Icons.rule,
                text: 'Terms and Conditions',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  appProvider.logout();
                  Navigator.of(context).pushReplacement(animatedDart(
                    Offset(-1.0, 0.0),
                    LoginScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Icon(Icons.navigate_next, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModifyUsernameModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ModifyUsernameModal(),
        );
      },
    );
  }
}

class GoldCard extends StatelessWidget {
  final String username;
  final String email;

  const GoldCard({
    Key? key,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/profile.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$username',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            '$email',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class CardWithBorder extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  CardWithBorder({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListTile(
            leading: Icon(icon),
            title: Text(text),
            trailing: Icon(Icons.navigate_next),
            onTap: onTap,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class ModifyUsernameModal extends StatefulWidget {
  @override
  _ModifyUsernameModalState createState() => _ModifyUsernameModalState();
}

class _ModifyUsernameModalState extends State<ModifyUsernameModal> {
  final TextEditingController _newUsernameController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Change Username',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _newUsernameController,
            decoration: InputDecoration(
              labelText: 'New Username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity, // Make button fill container width
            child: ElevatedButton(
              onPressed: () {
                _modifyUsername(context);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.yellow.shade700),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: Text('Save'),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  void _modifyUsername(BuildContext context) async {
    String newUsername = _newUsernameController.text.trim();

    if (newUsername.isEmpty) {
      setState(() {
        _errorMessage = 'Username cannot be empty.';
      });
      return;
    }

    // Check if the new username is unique
    bool isUnique = await _checkUniqueUsername(newUsername);

    if (isUnique) {
      // Get the user's email from the AppProvider
      String? userEmail =
          Provider.of<AppProvider>(context, listen: false).userEmail;

      // Update the database with the new username
      int rowsAffected = await DBConnect()
          .update('users', {'username': newUsername}, 'email = ?', [userEmail]);

      if (rowsAffected > 0) {
        // Update the state with the new username using the provider
        Provider.of<AppProvider>(context, listen: false)
            .updateUsername(newUsername);
        Navigator.pop(context); // Close the bottom sheet
        // Show success message or navigate back
        // You can customize this based on your app's flow
      } else {
        setState(() {
          _errorMessage = 'Failed to update username. Please try again.';
        });
      }
    } else {
      setState(() {
        _errorMessage =
            'Username already exists. Please choose a different one.';
      });
    }
  }

  Future<bool> _checkUniqueUsername(String newUsername) async {
    // Query the database to check if the username already exists
    List<Map<String, dynamic>> results =
        await DBConnect().query('users', 'username = ?', [newUsername]);
    return results.isEmpty;
  }
}
