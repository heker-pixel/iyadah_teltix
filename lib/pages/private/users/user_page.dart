import 'package:flutter/material.dart';
import './user_controller.dart';
import './user_model.dart';
import '../../../comps/animate_route.dart';
import '../dashboard_page.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserController _userController = UserController();
  List<User>? _users;
  List<User>? _filteredUsers;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_searchUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchUsers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await _userController.getUsers();
    setState(() {
      _users = users;
      _filteredUsers = users;
    });
  }

  void _searchUsers() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      final filteredUsers = _users?.where((user) {
        return user.username.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        _filteredUsers = filteredUsers;
      });
    } else {
      setState(() {
        _filteredUsers = _users;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  hintText: 'Search Users',
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
                    Icon(Icons.person, color: Colors.white),
                    SizedBox(width: 6), // Space between icon and text
                    Text('Users', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade900,
        automaticallyImplyLeading: true, // Add this line to show back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(animatedDart(
              Offset(-1.0, 0.0),
              DashboardPage(),
            ));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchController.clear();
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: _filteredUsers == null || _filteredUsers!.isEmpty
          ? _buildNoUserWidget()
          : ListView.builder(
              itemCount: _filteredUsers!.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers![index];
                Color backgroundColor = user.level == 'admin'
                    ? Colors.yellow.shade700
                    : Colors.grey.shade900;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: backgroundColor,
                    child: Text(
                      user.username[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    user.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.email),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 6), // Space between icon and text
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 6), // Space between icon and text
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    color: Colors.white, // Set the background color of dropdown
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showEditUserForm(user);
                      } else if (value == 'delete') {
                        _confirmDeleteUser(user);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserForm();
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.yellow.shade700,
      ),
    );
  }

  void _showAddUserForm() {
    _buildUserForm(null);
  }

  void _showEditUserForm(User user) {
    _buildUserForm(user);
  }

  void _buildUserForm(User? user) {
    final _formKey = GlobalKey<FormState>(); // Add form key

    TextEditingController usernameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController levelController = TextEditingController();

    if (user != null) {
      usernameController.text = user.username;
      emailController.text = user.email;
      passwordController.text = user.password;
      levelController.text = user.level;
    }

    final List<String> levels = ['admin', 'user']; // List of level options

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey, // Assign form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user == null ? 'Add User' : 'Edit User',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      // Add check for duplicate username only when adding a new user
                      if (user == null &&
                          _users != null &&
                          _users!.any((u) => u.username == value)) {
                        return 'Username already exists';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 13),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      // Add check for duplicate email only when adding a new user
                      if (user == null &&
                          _users != null &&
                          _users!.any((u) => u.email == value)) {
                        return 'Email already exists';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 13),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    value: user != null ? user.level : null,
                    onChanged: (value) {
                      setState(() {
                        levelController.text = value!;
                      });
                    },
                    items: levels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Level',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // Make button fill container width
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (user == null) {
                            // Add user
                            final newUser = User(
                              username: usernameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                              level: levelController.text,
                            );
                            await _userController.addUser(newUser);
                          } else {
                            // Edit user
                            user.username = usernameController.text;
                            user.email = emailController.text;
                            user.password = passwordController.text;
                            user.level = levelController.text;
                            await _userController.updateUser(user);
                          }
                          Navigator.pop(context);
                          await _loadUsers();
                        }
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.yellow.shade700),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: Text(user == null ? 'Add' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoUserWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
              'assets/search.jpg'), // Assuming 'search.jpg' is in the assets folder
          SizedBox(height: 10), // Adjust spacing between image and text
          Text('No users found'),
        ],
      ),
    );
  }

  void _confirmDeleteUser(User user) {
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
              'Are you sure you want to delete ${user.username}?',
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
                          Navigator.of(context).pop();
                          await _userController.deleteUser(user.id!);
                          await _loadUsers();
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
}
