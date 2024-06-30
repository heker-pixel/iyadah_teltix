import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'pages/home/home_page.dart';
import './pages/ticket_page.dart';
import './pages/profile_page.dart';
import './pages/search_page.dart';
import './comps/animate_route.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package
import './pages/watchlist_page.dart';

Widget buildPage() {
  return CurvedNavBarWithSlide();
}

class CurvedNavBarWithSlide extends StatefulWidget {
  @override
  _CurvedNavBarWithSlideState createState() => _CurvedNavBarWithSlideState();
}

class _CurvedNavBarWithSlideState extends State<CurvedNavBarWithSlide> {
  int _page = 0;
  PageController _pageController = PageController();
  final Uri _url = Uri.parse('https://maps.app.goo.gl/Cy2yzNjrRhXeLonR8');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _GoToMap(BuildContext context) async {
    bool goToMap = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          actionsPadding: EdgeInsets.all(0),
          title: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.yellow.shade700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.question_mark,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Confirm Navigation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Do you want to navigate to the map?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          actions: [
            Container(
              padding: EdgeInsets.only(bottom: 16.0),
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade900,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Confirm'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (goToMap == true) {
      _launchUrl();
    }
  }

  final List<Widget> _pages = [
    HomePage(),
    TicketPage(),
    ProfilePage(),
  ];

  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.grey.shade900,
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 40,
                height: 40,
              ),
              SizedBox(width: 20),
              Expanded(
                child: SizedBox(), // Empty space to center the title
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              color: Colors.grey.shade200,
              onPressed: () {
                Navigator.of(context).push(animatedDart(
                  Offset(1.0, 0.0),
                  SearchPage(),
                ));
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite),
              color: Colors.grey.shade200,
              onPressed: () {
                Navigator.of(context).push(animatedDart(
                  Offset(1.0, 0.0),
                  WatchlistPage(),
                ));
              },
            ),
            Container(
              margin: EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(Icons.location_on),
                color: Colors.grey.shade200,
                onPressed: () {
                  _GoToMap(context);
                },
              ),
            ),
          ],
          automaticallyImplyLeading: false, // Remove back button
          elevation: 0, // Remove shadow from AppBar itself
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24), // Add border radius
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _page = index;
          });
        },
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.local_activity, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: Colors.grey.shade900,
        buttonBackgroundColor: Colors.grey.shade900,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
    );
  }
}
