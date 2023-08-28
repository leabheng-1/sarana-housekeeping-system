import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:i_system/screen/dashboard.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String? initialToken;

  MyApp({this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialToken != null ? DashboardPage() : LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false; // To track the "Remember me" checkbox state
  bool _showPassword = false; // To track the visibility of password
  String _apiResponse = '';

  Future<void> _loginUser() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final url = Uri.parse('http://localhost:8000/api/login');
    final response = await http.post(url, body: {
      'name': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _apiResponse = responseData['message'];
      });
       final token = responseData['data']['token']['name'];
         SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
    } else {
      setState(() {
        _apiResponse = 'Login failed';
      });
        AwesomeDialog(
         width: 500,  
        context: context,
        dialogType: DialogType.ERROR,
        title: 'Login Failed',
        desc: 'Incorrect username or password.',
        btnOkOnPress: () {},
      )..show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.bottomCenter, // Align the circle to the bottom
              child: Container(
                width: double.infinity, // Expand the width to cover the entire column
                height: double.infinity, // Expand the height to cover the entire column
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(999), // Make it a full circle
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          'Logo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '3line text',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon: Container(
                          margin: EdgeInsets.only(left:5,right:15),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        prefixIcon: Container(
                          margin: EdgeInsets.only(left:5,right: 15),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.lock,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          child: Icon(
                            _showPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                      ),
                      obscureText: !_showPassword,
                    ),
                    SizedBox(height: 16),
                    Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.error)) {
            return Colors.red;
          }
          return Colors.green;
        }),
        value: _rememberMe,
        shape: CircleBorder(),
        onChanged: (bool? value) {
          setState(() {
            _rememberMe = value!;
          });
        },
      ),
      Text('Remember me'),
    ],
  ),
),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loginUser,
                      child: Text('Login'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _apiResponse,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
