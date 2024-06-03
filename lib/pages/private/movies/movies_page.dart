import 'package:flutter/material.dart';
import 'movies_form.dart';
import 'movies_controller.dart';
import 'movies_model.dart';
import 'movies_detail.dart';
import '../../../comps/animate_route.dart';
import '../dashboard_page.dart';

class MoviesPage extends StatefulWidget {
  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final MovieController _movieController = MovieController();
  List<Movie> _movies = [];
  List<Movie> _filteredMovies = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _searchController.addListener(_filterMovies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    final movies = await _movieController.getAllMovies();
    setState(() {
      _movies = movies;
      _filteredMovies = movies;
    });
  }

  void _filterMovies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMovies = _movies.where((movie) {
        return movie.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _deleteMovie(int id) async {
    Movie movieToDelete = _movies.firstWhere((movie) => movie.id == id);

    bool confirmDelete = await showDialog(
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
                  Icons.warning,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Confirm Delete',
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
              'Are you sure you want to delete this ${movieToDelete.title}?',
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
                        onPressed: () => Navigator.of(context)
                            .pop(false), // Return false when cancel is pressed
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
                        onPressed: () => Navigator.of(context)
                            .pop(true), // Return true when confirm is pressed
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

    if (confirmDelete) {
      await _movieController.deleteMovie(id);
      await _loadMovies();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filterMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        automaticallyImplyLeading: true, // Add this line to show back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(animatedDart(
              Offset(-1.0, 0.0),
              DashboardPage(),
            ));
            if (_isSearching) {
              _toggleSearch();
            } else {
              Scaffold.of(context).openDrawer();
            }
          },
        ),
        title: _isSearching
            ? TextField(
                style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 14.0), // Mengatur ukuran teks
                controller: _searchController,
                decoration: InputDecoration(
                  isDense: true, // Mengurangi tinggi keseluruhan TextField
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 3.5,
                      horizontal:
                          12.0), // Mengatur padding horizontal dan vertical
                  hintText: 'Search Movies',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade900,
                      fontSize: 14.0), // Mengatur ukuran teks hint
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius:
                        BorderRadius.circular(24), // Mengatur radius border
                  ),
                ),
              )
            : Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.movie, color: Colors.white),
                    SizedBox(width: 8), // Space between icon and text
                    Text('Movies', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
        actions: [
          IconButton(
            icon: _isSearching
                ? Icon(Icons.close, color: Colors.white)
                : Icon(Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: _filteredMovies.isEmpty
            ? _buildNoMoviesWidget()
            : _buildMoviesList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieFormPage(
                movieController: _movieController,
                onMovieSaved: _loadMovies,
              ),
            ),
          );
        },
        backgroundColor: Colors.yellow.shade700,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoMoviesWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
              'assets/search.jpg'), // Assuming 'search.jpg' is in the assets folder
          SizedBox(height: 10), // Adjust spacing between image and text
          Text('No movies available'),
        ],
      ),
    );
  }

  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }

  String truncateGenre(String genre) {
    List<String> parts = genre.split(',');
    if (parts.length > 2) {
      return '${parts[0]}, ${parts[1]}...';
    }
    return genre;
  }

  Widget _buildMoviesList() {
    return ListView.builder(
      itemCount: _filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = _filteredMovies[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Card(
            elevation: 0, // No shadow
            color: Colors.white,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: movie.poster != null
                      ? Image.memory(
                          movie.poster!,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 70,
                          width: 70,
                          color: Colors.grey,
                          child: Center(
                            child: Text(
                              'No Image',
                              style: TextStyle(
                                color: Colors.grey.shade900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truncateWithEllipsis(11, movie.title),
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          truncateGenre(movie.genre),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.5),
                        Text(
                          '${movie.showTime} / ${movie.releaseDate}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Details') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailPage(movie: movie),
                        ),
                      );
                    } else if (value == 'Edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieFormPage(
                            movieController: _movieController,
                            movie: movie,
                            onMovieSaved: _loadMovies,
                          ),
                        ),
                      );
                    } else if (value == 'Delete') {
                      _deleteMovie(movie.id!);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'Details',
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.grey.shade900),
                            SizedBox(width: 8),
                            Text('Details'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.grey.shade900),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.grey.shade900),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ];
                  },
                  icon: Icon(Icons.more_vert),
                  color:
                      Colors.white, // Set the background color of the dropdown
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
