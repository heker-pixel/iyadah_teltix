import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_provider.dart';
import './movies/movies_page.dart';
import '../../comps/animate_route.dart';
import './users/user_page.dart';
import 'package:iyadah_teltix/build_page.dart';
import './transaction/transaction_page.dart';
import './banner/banner_page.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    String? username = appProvider.username;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade900, // Set app bar background color
        title: Row(
          children: [
            SizedBox(width: 10),
            Text(
              'Hi, $username',
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logo.png',
              width: 40, // Adjust the width as needed
              height: 40, // Adjust the height as needed
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Set body background color to white
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // General
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'General',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  'Explore general information',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 7),
                NavigationCard(
                  title: 'Overview',
                  icon: Icons.analytics,
                  onTap: () {
                    // Handle navigation to Overview
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Content',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage content',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 7),
                NavigationCard(
                  title: 'Movies',
                  icon: Icons.movie,
                  onTap: () {
                    Navigator.of(context).push(animatedDart(
                      Offset(1.0, 0.0),
                      MoviesPage(),
                    ));
                  },
                ),
                NavigationCard(
                  title: 'Banner',
                  icon: Icons.image,
                  onTap: () {
                    Navigator.of(context).push(animatedDart(
                      Offset(1.0, 0.0),
                      BannerPage(),
                    ));
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            // User n Activity
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User n Activity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  'Track user activity and transaction activity',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 7),
                NavigationCard(
                  title: 'Users',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.of(context).push(animatedDart(
                      Offset(1.0, 0.0),
                      UserPage(),
                    ));
                  },
                ),
                NavigationCard(
                  title: 'Transaction',
                  icon: Icons.credit_card,
                  onTap: () {
                    Navigator.of(context).push(animatedDart(
                      Offset(1.0, 0.0),
                      TransactionPage(),
                    ));
                  },
                ),
                SizedBox(height: 10),
                BackButtonCard(), // Add the back button here
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  NavigationCard(
      {required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(
            8), // Optional: Adjust border radius as needed
        border: Border.all(
          color: Colors.grey.withOpacity(0.5), // Border color and opacity
          width: 1, // Border width
        ),
      ),
      child: ListTile(
        leading: Icon(icon, size: 36),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}

class BackButtonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900, // Background color
        borderRadius: BorderRadius.circular(8), // Border radius
      ),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(animatedDart(
            Offset(1.0, 0.0),
            buildPage(),
          ));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Back',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
