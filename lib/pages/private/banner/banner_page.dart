import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iyadah_teltix/pages/private/banner/banner_model.dart'
    as MyBanner;
import 'banner_controller.dart';

class BannerPage extends StatefulWidget {
  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  final BannerController _bannerController = BannerController();
  late List<MyBanner.Banner> _banners = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  void _loadBanners() async {
    _banners = await _bannerController.getAllBanners();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showFormModal(BuildContext context) async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Uint8List imageBytes = await pickedImage.readAsBytes();
      await _bannerController.insertBanner(imageBytes);
      _loadBanners();
    }
  }

  Future<void> _showUpdateFormModal(
      BuildContext context, MyBanner.Banner banner) async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Uint8List imageBytes = await pickedImage.readAsBytes();
      await _bannerController.updateBanner(banner.id, imageBytes);
      _loadBanners();
    }
  }

  Future<void> _deleteBanner(
      BuildContext context, MyBanner.Banner banner) async {
    showDialog(
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
              'Are you sure you want to delete this banner?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0), // Increased text size
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
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
                        onPressed: () async {
                          await _bannerController.deleteBanner(banner.id);
                          _loadBanners();
                          Navigator.of(context).pop();
                        },
                        child: Text('Delete'),
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
  }

  Future<void> _showForm(BuildContext context) async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Uint8List imageBytes = await pickedImage.readAsBytes();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white, // Adjust form color
            title: Center(child: Text('Add Banner')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.memory(
                    imageBytes,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // Full width
                    child: ElevatedButton(
                      onPressed: () async {
                        await _bannerController.insertBanner(imageBytes);
                        _loadBanners();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700, // Button color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                        ),
                      ),
                      child: Text(
                        'Add Banner',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image, color: Colors.white),
              SizedBox(width: 6),
              Text('Banner', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final MyBanner.Banner banner = _banners[index];
                return ListTile(
                  title: Center(
                      child: Text('Banner No. ${index + 1}')), // Adjusted title
                  leading: Image.memory(
                    banner.imageBytes,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  trailing: PopupMenuButton(
                    color: Colors.white, // Adjust dropdown background color
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.black),
                              SizedBox(width: 8),
                              Text('Edit',
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),
                          value: 'edit',
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.black),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),
                          value: 'delete',
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showUpdateFormModal(context, banner);
                      } else if (value == 'delete') {
                        _deleteBanner(context, banner);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: Colors.yellow.shade700, // Floating button color
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
