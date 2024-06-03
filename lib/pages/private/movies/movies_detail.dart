import 'package:flutter/material.dart';
import 'movies_model.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  MovieDetailPage({required this.movie});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool isExpanded = false;
  final GlobalKey _textKey = GlobalKey();
  bool _isTextOverflowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  void _checkTextOverflow() {
    final RenderBox renderBox =
        _textKey.currentContext!.findRenderObject() as RenderBox;
    final double textHeight = renderBox.size.height;

    const int maxLines = 3;
    final TextPainter textPainter = TextPainter(
      text:
          TextSpan(text: widget.movie.synopsis, style: TextStyle(fontSize: 18)),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: renderBox.size.width);

    setState(() {
      _isTextOverflowing = textPainter.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('Movie Details', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            pinned: true,
            expandedHeight: 200.0, // adjust as needed
            flexibleSpace: FlexibleSpaceBar(
              background: Image.memory(
                widget.movie.poster!,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
                color: Colors.black.withOpacity(0.5), // Darken the background
              ),
            ),
            backgroundColor:
                Colors.grey.shade900, // Change app bar color when collapsed
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.movie.poster != null
                          ? Image.memory(
                              widget.movie.poster!,
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 150,
                              color: Colors.grey,
                              child: Center(child: Text('No image')),
                            ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${widget.movie.title}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildGenre(widget.movie.genre),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('${widget.movie.duration}',
                                style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('${widget.movie.showTime}',
                                style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('${widget.movie.releaseDate}',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Movie Synopsis',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedCrossFade(
                            firstChild: Text(
                              widget.movie.synopsis,
                              key: _textKey,
                              style: TextStyle(fontSize: 18),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            secondChild: Text(
                              widget.movie.synopsis,
                              style: TextStyle(fontSize: 18),
                            ),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: Duration(milliseconds: 300),
                          ),
                          if (_isTextOverflowing)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    isExpanded ? 'Read less' : 'Read more',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Movie Production',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildProfileItems(
                            widget.movie.director, 'Director'),
                        ..._buildProfileItems(
                            widget.movie.producer, 'Producer'),
                        ..._buildProfileItems(widget.movie.cast, 'Cast'),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Movie Ticket',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Chip(
                        backgroundColor: Colors.grey.shade900,
                        label: Text(
                          'Price: Rp ${widget.movie.ticketPrice}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Adjust border radius
                          side: BorderSide(
                            color: Colors.grey.shade900, // Border color yellow
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Add some space between chips
                      Chip(
                        backgroundColor: Colors.yellow.shade700,
                        label: Text(
                          'Available: ${widget.movie.ticketCount}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Adjust border radius
                          side: BorderSide(
                            color:
                                Colors.yellow.shade700, // Border color yellow
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProfileItems(String names, String job) {
    final nameList = names.split(',').map((name) => name.trim()).toList();
    return nameList.map((name) => ProfileItem(name: name, job: job)).toList();
  }

  Widget buildGenre(String genre) {
    final genreList = genre.split(',').map((genre) => genre.trim()).toList();
    final joinedGenres = genreList.join(' | ');
    return Text(
      joinedGenres,
      style: TextStyle(fontSize: 16),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String name;
  final String job;

  ProfileItem({required this.name, required this.job});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0), // Adjust spacing as needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          CircleAvatar(
            backgroundColor: Colors.black,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          SizedBox(height: 4),
          Text(
            job,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            name,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
