import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/db_connect.dart';
import '../../utils/app_provider.dart';
import '../../build_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../comps/animate_route.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLogin = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController(); // Tambahkan ini
  final DBConnect _dbHelper = DBConnect();

  Future<void> _register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text; // Tambahkan ini

    // Check if user already exists
    final existingUsers = await _dbHelper.query(
      'users',
      'email = ?',
      [email],
    );

    if (existingUsers.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User already exists')),
      );
      return;
    }

    await _dbHelper.insert('users', {
      'username': username, // Tambahkan ini
      'email': email,
      'password': password,
      'level': 'user',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration successful')),
    );
    await _login(context, email, password);
  }

  Future<void> _login(
      BuildContext context, String email, String password) async {
    final users = await _dbHelper.query(
      'users',
      'email = ? AND password = ?',
      [email, password],
    );

    if (users.isNotEmpty) {
      final user = users.first;
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('userEmail', email);
      prefs.setString('username', user['username']);
      prefs.setString(
          'userLevel', user['level']); // Set user's level in SharedPreferences

      Provider.of<AppProvider>(context, listen: false).login(
        email,
        user['username'],
        user['level'], // Pass user's level to AppProvider
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );
      Navigator.of(context).push(animatedDart(
        Offset(1.0, 0.0),
        buildPage(),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blueGrey.shade900,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _isLogin ? "Login" : "Register",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _isLogin
                          ? "Welcome back! Please login to your account."
                          : "Register your account to get started with Teltix.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/Login.png',
                      height: 250,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 15),
                          if (!_isLogin) // Tampilkan username hanya saat register
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: "Username",
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                          if (!_isLogin)
                            SizedBox(
                                height: 15), // Tambahkan jarak jika register
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_isLogin) {
                                    _login(context, _emailController.text,
                                        _passwordController.text);
                                  } else {
                                    _register();
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.yellow.shade700, // Background color
                                foregroundColor: Colors.white, // Text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _isLogin ? 'Login' : 'Register',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _usernameController
                                    .clear(); // Clear username field
                                _emailController.clear(); // Clear email field
                                _passwordController
                                    .clear(); // Clear password field
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? "Don't have an account? Register"
                                  : "Already have an account? Login",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
