import '../../../utils/db_connect.dart';
import './movies_model.dart';

class MovieController {
  final DBConnect _dbConnect = DBConnect();

  Future<List<Movie>> getAllMovies() async {
    final movies = await _dbConnect.getAllMovies();
    return movies.map((movieMap) => _mapToMovie(movieMap)).toList();
  }

  Future<void> insertOrUpdateMovie(Movie movie) async {
    final movieData = _mapToMovieData(movie);
    if (movie.id == null) {
      await _dbConnect.insertMovie(movieData);
    } else {
      await _dbConnect.updateMovie(movie.id!, movieData);
    }
  }

  Future<void> deleteMovie(int movieId) async {
    await _dbConnect.deleteMovie(movieId);
  }

  Movie _mapToMovie(Map<String, dynamic> movieMap) {
    return Movie(
      id: movieMap['id'],
      title: movieMap['title'],
      genre: movieMap['genre'],
      duration: movieMap['duration'],
      director: movieMap['director'],
      producer: movieMap['producer'],
      cast: movieMap['cast'],
      synopsis: movieMap['synopsis'],
      showTime: movieMap['show_time'],
      releaseDate: movieMap['release_date'],
      ticketPrice: movieMap['ticket_price'],
      ticketCount: movieMap['ticket_count'],
      poster: movieMap['poster'],
    );
  }

  Map<String, dynamic> _mapToMovieData(Movie movie) {
    return {
      'title': movie.title,
      'genre': movie.genre,
      'duration': movie.duration,
      'director': movie.director,
      'producer': movie.producer,
      'cast': movie.cast,
      'synopsis': movie.synopsis,
      'show_time': movie.showTime,
      'release_date': movie.releaseDate,
      'ticket_price': movie.ticketPrice,
      'ticket_count': movie.ticketCount,
      'poster': movie.poster,
    };
  }
}
