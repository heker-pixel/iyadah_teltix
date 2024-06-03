import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../utils/db_connect.dart';
import './home/details_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _searchResultsMovies;
  Future<List<Map<String, dynamic>>>?
      _searchResultsFigure; // Add search results for Figure

  final DBConnect _dbConnect = DBConnect();

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResultsMovies = null;
        _searchResultsFigure = null;
      });
    } else {
      setState(() {
        _searchResultsMovies = _dbConnect.searchMovies(query);
        _searchResultsFigure =
            _dbConnect.searchFigure(query); // Perform search for Figure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade900,
          leading: Icon(Icons.search, color: Colors.white),
          title: TextField(
            controller: _searchController,
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 14.0,
            ),
            onChanged: _performSearch, // Call search on text change
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 3.5, horizontal: 12.0),
              hintText: 'Search Movies',
              hintStyle: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 14.0,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.yellow.shade700,
            labelColor: Colors.yellow.shade700,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: "Movies"),
              Tab(text: "Figure"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSearchResultsMovies(),
            _buildSearchResultsFigure(), // Add Figure tab content
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsMovies() {
    if (_searchResultsMovies == null) {
      return _buildSearchMoviesWidget();
    } else {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _searchResultsMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final movies = snapshot.data ?? [];
            if (movies.isEmpty) {
              return _buildNoMoviesWidget();
            } else {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of items per row
                    childAspectRatio:
                        0.7, // Adjust based on item height and width
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final Uint8List? poster = movies[index]['poster'];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailsPage(movieId: movies[index]['id']),
                          ),
                        );
                      },
                      child: GridTile(
                        child: poster != null
                            ? Image.memory(poster, fit: BoxFit.cover)
                            : Image.asset('assets/placeholder.png',
                                fit: BoxFit.cover),
                        footer: GridTileBar(
                          backgroundColor: Colors.black54,
                          subtitle: Center(
                            child: Text(
                              'Click to View More',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight:
                                    FontWeight.w500, // Increased font weight
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }
        },
      );
    }
  }

  Widget _buildSearchResultsFigure() {
    if (_searchResultsFigure == null) {
      return _buildNoMoviesWidget();
    } else {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _searchResultsFigure,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final figures = snapshot.data ?? [];
            if (figures.isEmpty) {
              return _buildNoMoviesWidget();
            } else {
              return ListView.builder(
                itemCount: figures.length,
                itemBuilder: (context, index) {
                  final String? cast = figures[index]['cast'];
                  final String? director = figures[index]['director'];
                  final String? producer = figures[index]['producer'];

                  List<Widget> jobWidgets = [];

                  if (cast != null) {
                    jobWidgets.add(_buildJobWidget('Cast', cast));
                  }
                  if (director != null) {
                    jobWidgets.add(_buildJobWidget('Director', director));
                  }
                  if (producer != null) {
                    jobWidgets.add(_buildJobWidget('Producer', producer));
                  }

                  final String? movieName = figures[index]['title'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(movieName ?? 'Unknown Movie'),
                      ),
                      ...jobWidgets,
                    ],
                  );
                },
              );
            }
          }
        },
      );
    }
  }

  Widget _buildJobWidget(String job, String name) {
    return ListTile(
      title: Text(name),
      subtitle: Text('Job: $job'),
    );
  }

  Widget _buildNoMoviesWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/search.jpg',
          width: 250,
          height: 150,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(height: 10),
        Text(
          "No movies available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchMoviesWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/search.jpg',
          width: 250,
          height: 150,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(height: 10),
        Text(
          "Search movies you want to know",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
