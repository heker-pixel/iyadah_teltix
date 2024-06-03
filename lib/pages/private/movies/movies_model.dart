import 'dart:typed_data';

class Movie {
  final int? id;
  final String title;
  final String genre;
  final String duration;
  final String director;
  final String producer;
  final String cast;
  final String synopsis;
  final String showTime;
  final String releaseDate;
  final int ticketPrice;
  final int ticketCount;
  final Uint8List? poster;

  Movie({
    this.id, // Make id optional
    required this.title,
    required this.genre,
    required this.duration,
    required this.director,
    required this.producer,
    required this.cast,
    required this.synopsis,
    required this.showTime,
    required this.releaseDate,
    required this.ticketPrice,
    required this.ticketCount,
    required this.poster,
  });
}
