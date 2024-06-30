import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import '../../utils/db_connect.dart'; // Import your DBConnect class file
import 'details_page.dart'; // Import your DetailsPage class file

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBConnect _dbConnect = DBConnect();
  late Future<List<Map<String, dynamic>>> _bannersFuture;
  late Future<List<Map<String, dynamic>>> _moviesFuture;
  late Future<List<Map<String, dynamic>>> _moviesGenreFuture;
  int _currentBanner = 0;
  final CarouselController _bannerController = CarouselController();
  final ScrollController _scrollController = ScrollController();
  String _selectedGenre = '';

  @override
  void initState() {
    super.initState();
    _bannersFuture = _dbConnect.getAllBanners();
    _moviesFuture = _dbConnect.getAllMovies();
    _moviesGenreFuture = _dbConnect.getAllMovies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _bannersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No banners found.'));
                }

                final banners = snapshot.data!;
                return Column(
                  children: [
                    CarouselSlider(
                      items: banners.map((banner) {
                        final Uint8List? imageBytes = banner['image'];
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(imageBytes!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                      carouselController: _bannerController,
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 24 / 9,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentBanner = index;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: banners.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              _bannerController.animateToPage(entry.key),
                          child: Container(
                            width: _currentBanner == entry.key ? 24.0 : 8.0,
                            height: 8.0,
                            margin: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: _currentBanner == entry.key
                                  ? Colors.grey.shade900
                                  : Colors.grey[400],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.movie, size: 22, color: Colors.grey.shade900),
                      SizedBox(
                          width: 5), // Add some space between icon and text
                      Text(
                        'Movies',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Currently Showing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No movies found.'));
                }

                // Get today's date
                final today = DateTime.now();

                // Filter movies based on release date matching today's date
                final movies = snapshot.data!.where((movie) {
                  final releaseDateStr = movie['release_date'] as String;
                  // Split the date string and parse it accordingly
                  final parts = releaseDateStr.split('/');
                  if (parts.length == 3) {
                    final day = int.tryParse(parts[0]);
                    final month = int.tryParse(parts[1]);
                    final year = int.tryParse(parts[2]);

                    if (day != null && month != null && year != null) {
                      final releaseDate = DateTime(year + 2000, month,
                          day); // Assuming the year format is 'yy'
                      return releaseDate.year == today.year &&
                          releaseDate.month == today.month &&
                          releaseDate.day == today.day;
                    }
                  }
                  return false;
                }).toList();

                if (movies.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Image.asset('assets/search.jpg',
                            width: 250, // Adjust width as needed
                            height: 150,
                            fit: BoxFit.fitWidth // Adjust height as needed
                            ),
                        SizedBox(height: 5),
                        Text(
                          'No Movies Are Showing Today',
                          style: TextStyle(
                            fontSize: 16, // Adjust font size as needed
                            fontWeight:
                                FontWeight.bold, // Adjust font weight as needed
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.width / 1.5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final Uint8List? poster = movies[index]['poster'];
                      return Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 1 / 2.2,
                            margin: EdgeInsets.symmetric(horizontal: 4.0),
                            child: AspectRatio(
                              aspectRatio: 9 / 21,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: poster != null
                                            ? MemoryImage(poster)
                                            : AssetImage(
                                                    'assets/placeholder.png')
                                                as ImageProvider<Object>,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailsPage(
                                                  movieId: movies[index]['id']),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Click to view more',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 5.0),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.movie_filter,
                          size: 22, color: Colors.grey.shade900),
                      SizedBox(width: 5), // Closing SizedBox
                      Text(
                        'Genre',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Search By Genre',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _moviesGenreFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No movies found.'));
                }

                final movies = snapshot.data!;
                final allGenres = Set<String>();
                for (final movie in movies) {
                  final genres = movie['genre'] as String;
                  final splitGenres = genres.split(', ');
                  allGenres.addAll(splitGenres);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: allGenres.map((genre) {
                          final isActive = genre == _selectedGenre;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ActionChip(
                              label: Row(
                                children: [
                                  Icon(
                                    Icons.movie,
                                    color: Colors.white,
                                  ), // Icon to the left of the genre
                                  SizedBox(
                                      width: 4), // Adjust spacing as needed
                                  Text(
                                    genre,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: isActive
                                  ? Colors.yellow.shade700
                                  : Colors.grey.shade900,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: Colors.transparent),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedGenre = isActive ? '' : genre;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 10),
                    _selectedGenre.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                Image.asset('assets/search.jpg',
                                    width: 250, // Adjust width as needed
                                    height: 150,
                                    fit: BoxFit
                                        .fitWidth // Adjust height as needed
                                    ),
                                SizedBox(height: 5),
                                Text(
                                  'No Genre Selected',
                                  style: TextStyle(
                                    fontSize: 16, // Adjust font size as needed
                                    fontWeight: FontWeight
                                        .bold, // Adjust font weight as needed
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.width /
                                1.5, // Height of the card based on the aspect ratio
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                final movieGenres =
                                    (movies[index]['genre'] as String)
                                        .split(', ');
                                if (_selectedGenre.isNotEmpty &&
                                    !movieGenres.contains(_selectedGenre)) {
                                  return SizedBox
                                      .shrink(); // Hide the movie if it doesn't belong to the selected genre
                                }
                                final Uint8List? poster =
                                    movies[index]['poster'];
                                return Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          1 /
                                          2.2, // Width of the card
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      child: AspectRatio(
                                        aspectRatio: 9 / 21,
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: poster != null
                                                      ? MemoryImage(poster)
                                                      : AssetImage(
                                                              'assets/placeholder.png')
                                                          as ImageProvider<
                                                              Object>,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailsPage(
                                                                movieId: movies[
                                                                        index]
                                                                    ['id']),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'Click to view more',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            5.0), // Add a space of 10.0 between each movie card
                                  ],
                                );
                              },
                            ),
                          ),
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.movie, size: 22, color: Colors.grey.shade900),
                      SizedBox(
                          width: 5), // Add some space between icon and text
                      Text(
                        'Movies',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No movies found.'));
                }

                // Get today's date
                final today = DateTime.now();

// Get tomorrow's date
                final tomorrow = today.add(Duration(days: 1));

// Filter movies based on release date matching tomorrow's date or later
                final movies = snapshot.data!.where((movie) {
                  final releaseDateStr = movie['release_date'] as String;
                  // Split the date string and parse it accordingly
                  final parts = releaseDateStr.split('/');
                  if (parts.length == 3) {
                    final day = int.tryParse(parts[0]);
                    final month = int.tryParse(parts[1]);
                    final year = int.tryParse(parts[2]);

                    if (day != null && month != null && year != null) {
                      final releaseDate = DateTime(year + 2000, month,
                          day); // Assuming the year format is 'yy'
                      // Check if the movie is releasing tomorrow or later
                      return releaseDate.isAtSameMomentAs(tomorrow) ||
                          releaseDate.isAfter(tomorrow);
                    }
                  }
                  return false;
                }).toList();

                if (movies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center text vertically
                      children: [
                        Image.asset(
                          'assets/search.jpg',
                          width: 250,
                          height: 150,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'No Movies Are Coming Soon or Releasing Tomorrow',
                          textAlign:
                              TextAlign.center, // Center text horizontally
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.width / 1.5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final Uint8List? poster = movies[index]['poster'];
                      return Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 1 / 2.2,
                            margin: EdgeInsets.symmetric(horizontal: 4.0),
                            child: AspectRatio(
                              aspectRatio: 9 / 21,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: poster != null
                                            ? MemoryImage(poster)
                                            : AssetImage(
                                                    'assets/placeholder.png')
                                                as ImageProvider<Object>,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailsPage(
                                                  movieId: movies[index]['id']),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Click to view more',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 5.0),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Image.asset(
                  'assets/6586053.jpg',
                  width: 250,
                  height: 150,
                  fit: BoxFit.fitWidth,
                ), // Replace with your image path
                SizedBox(height: 10),
                Text(
                  "And... cut!, your journey will stop here, please go back to the top",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                TextButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0.0,
                      duration: Duration(seconds: 1),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    "Go to Top",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
