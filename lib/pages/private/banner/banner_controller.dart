import 'dart:typed_data';
import '../../../utils/db_connect.dart';
import 'banner_model.dart';

class BannerController {
  final DBConnect _dbConnect = DBConnect();

  Future<int> insertBanner(Uint8List imageBytes) async {
    return await _dbConnect.insertBanner(imageBytes);
  }

  Future<int> updateBanner(int id, Uint8List imageBytes) async {
    return await _dbConnect.updateBanner(id, imageBytes);
  }

  Future<int> deleteBanner(int id) async {
    return await _dbConnect.deleteBanner(id);
  }

  Future<List<Banner>> getAllBanners() async {
    final List<Map<String, dynamic>> bannersData =
        await _dbConnect.getAllBanners();
    return bannersData
        .map((bannerData) =>
            Banner(id: bannerData['id'], imageBytes: bannerData['image']))
        .toList();
  }
}
