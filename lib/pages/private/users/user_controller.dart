import './user_model.dart';
import '../../../utils/db_connect.dart';

class UserController {
  final DBConnect _dbConnect = DBConnect();

  Future<int> addUser(User user) async {
    return await _dbConnect.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final List<Map<String, dynamic>> usersMapList =
        await _dbConnect.queryAll('users');
    return usersMapList.map((userMap) => User.fromMap(userMap)).toList();
  }

  Future<int> updateUser(User user) async {
    return await _dbConnect.update(
      'users',
      user.toMap(),
      'id = ?',
      [user.id],
    );
  }

  Future<String> getUserEmail(int userId) async {
    try {
      final List<Map<String, dynamic>> usersMapList =
          await _dbConnect.query('users', 'id = ?', [userId]);
      if (usersMapList.isNotEmpty) {
        return usersMapList.first['email'];
      } else {
        throw Exception('User with ID $userId not found');
      }
    } catch (e) {
      throw Exception('Error getting user email: $e');
    }
  }

  Future<int> deleteUser(int id) async {
    return await _dbConnect.delete(
      'users',
      'id = ?',
      [id],
    );
  }
}
