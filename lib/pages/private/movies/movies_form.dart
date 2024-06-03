import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/db_connect.dart';
import 'movies_model.dart';
import 'movies_controller.dart';
import 'package:intl/intl.dart';

class MovieFormPage extends StatefulWidget {
  final DBConnect _dbConnect = DBConnect();
  final MovieController movieController;
  final Movie? movie;
  final VoidCallback onMovieSaved;

  MovieFormPage({
    required this.movieController,
    this.movie,
    required this.onMovieSaved,
  });

  @override
  _MovieFormPageState createState() => _MovieFormPageState();
}

class _MovieFormPageState extends State<MovieFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _producerController = TextEditingController();
  final TextEditingController _castController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();
  final TextEditingController _showTimeController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _ticketCountController = TextEditingController();

  Uint8List? _imageBytes;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late String _submitButtonText;
  String? _imageErrorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _initControllers(widget.movie!);
      _loadImage(widget.movie!.id!);
      _submitButtonText = 'Save';
    } else {
      _submitButtonText = 'Add';
    }
  }

  void _initControllers(Movie movie) {
    _titleController.text = movie.title;
    _genreController.text = movie.genre;
    _minutesController.text =
        movie.duration != null ? _getMinutes(movie.duration!) : '';
    _directorController.text = movie.director;
    _producerController.text = movie.producer;
    _castController.text = movie.cast;
    _synopsisController.text = movie.synopsis;
    _showTimeController.text = movie.showTime;
    _releaseDateController.text = movie.releaseDate;
    _ticketPriceController.text = movie.ticketPrice.toString();
    _ticketCountController.text = movie.ticketCount.toString();

    if (movie.releaseDate != null && movie.releaseDate.isNotEmpty) {
      _selectedDate = DateFormat('dd/MM/yy').parse(movie.releaseDate);
    }
    if (movie.showTime != null && movie.showTime.isNotEmpty) {
      _selectedTime =
          TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(movie.showTime));
    }
  }

  Future<void> _loadImage(int movieId) async {
    final imageBytes = await widget._dbConnect.getImage(movieId);
    setState(() {
      _imageBytes = imageBytes;
    });
  }

  String _getMinutes(String duration) {
    // Assuming duration is in format 'XX minutes'
    List<String> parts = duration.split(' ');
    if (parts.length > 0) {
      return parts[0];
    } else {
      return '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _releaseDateController.text = DateFormat('dd/MM/yy').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _showTimeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageErrorMessage = null;
      });
    }
  }

  String _formatPrice(String price) {
    final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return numberFormat.format(double.parse(price));
  }

  void _saveMovie() {
    if (_formKey.currentState!.validate() && _imageBytes != null) {
      String title = _titleController.text;
      String genre = _genreController.text;
      String minutes = _minutesController.text;
      String director = _directorController.text;
      String producer = _producerController.text;
      String cast = _castController.text;
      String synopsis = _synopsisController.text;
      String releaseDate = _releaseDateController.text;
      int ticketPrice = int.tryParse(_ticketPriceController.text) ?? 0;
      int ticketCount = int.tryParse(_ticketCountController.text) ?? 0;

      Movie movie = Movie(
        id: widget.movie?.id,
        title: title,
        genre: genre,
        duration: '$minutes minutes',
        director: director,
        producer: producer,
        cast: cast,
        synopsis: synopsis,
        showTime: _selectedTime != null ? _selectedTime!.format(context) : '',
        releaseDate: releaseDate,
        ticketPrice: ticketPrice,
        ticketCount: ticketCount,
        poster: _imageBytes,
      );

      widget.movieController.insertOrUpdateMovie(movie);
      widget.onMovieSaved();
      Navigator.pop(context);
    } else if (_imageBytes == null) {
      setState(() {
        _imageErrorMessage = 'Please select an image';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          widget.movie == null ? 'Add Movie' : 'Edit Movie',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Movie Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _genreController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a genre';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Genre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _synopsisController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a synopsis';
                      }
                      return null;
                    },
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Synopsis',
                      labelStyle: TextStyle(color: Colors.grey.shade900),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _minutesController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the duration in minutes';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Duration (Minutes)',
                      labelStyle: TextStyle(color: Colors.grey.shade900),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _releaseDateController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a release date';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Release Date',
                          labelStyle: TextStyle(color: Colors.grey.shade900),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _showTimeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a show time';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Show Time',
                          labelStyle: TextStyle(color: Colors.grey.shade900),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _imageBytes != null
                      ? Image.memory(_imageBytes!)
                      : Text('No image selected'),
                  if (_imageErrorMessage != null)
                    Text(
                      _imageErrorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.yellow.shade700),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      side: MaterialStateProperty.all<BorderSide>(
                          BorderSide.none),
                    ),
                    child: Text('Pick Image'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Production Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _directorController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a director';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Director',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _producerController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a producer';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Producer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _castController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the cast';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Cast',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ticket Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _ticketPriceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the ticket price';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ticket Price (IDR)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _ticketCountController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the ticket count';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ticket Count',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveMovie,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.yellow.shade700),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: Text('$_submitButtonText'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
