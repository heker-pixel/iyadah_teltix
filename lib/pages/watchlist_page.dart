import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_provider.dart';
import '../pages/home/details_page.dart';
import '../utils/db_connect.dart';

class WatchlistPage extends StatefulWidget {
  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  late Future<List<WatchlistItem>> _watchlist;

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  void _fetchWatchlist() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final db = DBConnect();

    // Dapatkan userId berdasarkan userEmail yang ada di provider
    if (appProvider.userEmail != null) {
      final userId = await db.getUserIdByEmail(appProvider.userEmail!);
      if (userId != null) {
        setState(() {
          _watchlist = db.getWatchlistWithDetails(userId);
        });
      } else {
        // Handle case when userId is not found
        setState(() {
          _watchlist = Future.value([]);
        });
      }
    } else {
      // Handle case when userEmail is not set in the provider
      setState(() {
        _watchlist = Future.value([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        centerTitle: true, // Ensures the title is centered
        title: Text(
          'Watchlist',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<WatchlistItem>>(
        future: _watchlist,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in watchlist'));
          } else {
            final watchlist = snapshot.data!;
            return Container(
              padding: EdgeInsets.only(top: 8.0), // Add padding to the top
              height: MediaQuery.of(context).size.width / 1.5,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: watchlist.length,
                itemBuilder: (context, index) {
                  final item = watchlist[index];
                  final Uint8List? poster = item.poster;
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
                                        : AssetImage('assets/placeholder.png')
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
                                            movieId: item.movieId,
                                          ),
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
          }
        },
      ),
    );
  }
}
