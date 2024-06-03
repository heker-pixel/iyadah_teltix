import 'package:flutter/material.dart';
import '../../comps/animate_route.dart';
import 'login_screen.dart';

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _introData = [
    {
      'image': 'assets/intro1.png',
      'title': 'Welcome to Teltix',
      'subtitle':
          'The official app for purchasing movie tickets showcasing the work of students from SMK Telkom Banjarbaru.',
    },
    {
      'image': 'assets/intro2.png',
      'title': 'Discover Student Creations',
      'subtitle':
          'Explore and watch original films crafted by talented students.',
    },
    {
      'image': 'assets/intro3.png',
      'title': 'Support Young Talent!',
      'subtitle':
          'Get your tickets now and experience extraordinary works from the next generation of filmmakers.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _introData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 35),
                          Image.asset(_introData[index]['image']!, height: 300),
                          Text(
                            _introData[index]['title']!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 3),
                          Text(
                            _introData[index]['subtitle']!,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (_currentPage != _introData.length - 1) {
                          _pageController.animateToPage(
                            _introData.length - 1,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _pageController.animateToPage(
                            0,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _introData.length - 1 ? 'Back' : 'Skip',
                        style: TextStyle(color: Colors.blueGrey.shade900),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        _introData.length,
                        (index) => GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: const EdgeInsets.all(4.0),
                            width: _currentPage == index ? 24.0 : 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: _currentPage == index
                                  ? Colors.yellow.shade600
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_currentPage < _introData.length - 1) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.of(context).push(animatedDart(
                            Offset(0.0, 1.0),
                            LoginScreen(),
                          ));
                        }
                      },
                      child: Text(
                        _currentPage == _introData.length - 1
                            ? 'Sign In'
                            : 'Next',
                        style: TextStyle(color: Colors.blueGrey.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
