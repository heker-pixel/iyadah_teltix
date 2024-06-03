// banner_page.dart
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
    await _bannerController.deleteBanner(banner.id);
    _loadBanners();
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
            title: Text('Add Banner'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Image.memory(
                    imageBytes,
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _bannerController.insertBanner(imageBytes);
                      _loadBanners();
                      Navigator.pop(context);
                    },
                    child: Text('Add Banner'),
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
        title: Text('Banner CRUD'),
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
                  title: Text('Banner ${banner.id}'),
                  leading: Image.memory(
                    banner.imageBytes,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showUpdateFormModal(context, banner),
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => _deleteBanner(context, banner),
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
