import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _passwordVisible = false;

  bool _isEmail(String input) {
    final RegExp emailExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailExp.hasMatch(input);
  }

  bool _isPhoneNumber(String input) {
    final RegExp phoneExp = RegExp(
      r'^\+?[0-9]{10,15}$',
    );
    return phoneExp.hasMatch(input);
  }

  void _login() async {
    String emailOrPhone = _emailOrPhoneController.text.trim();
    String password = _passwordController.text.trim();

    if (emailOrPhone.isEmpty || password.isEmpty) {
      _showMessage('All fields are required');
      return;
    }

    try {
      if (_isEmail(emailOrPhone)) {
        await _auth.signInWithEmailAndPassword(
          email: emailOrPhone,
          password: password,
        );
      } else if (_isPhoneNumber(emailOrPhone)) {
        _loginWithPhoneNumber(emailOrPhone, password);
      } else {
        _showMessage('Invalid email or phone number');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          _showMessage('No user found with this email or phone number.');
        } else if (e.code == 'wrong-password') {
          _showMessage('Incorrect password.');
        } else {
          _showMessage('Login failed: incorrect email or password');
        }
      } else {
        _showMessage('Login failed: incorrect email or password');
      }
    }
  }

  void _loginWithPhoneNumber(String phoneNumber, String password) async {
    try {
      User? user = (await _auth.signInWithEmailAndPassword(
        email: phoneNumber + '@example.com',
        password: password,
      ))
          .user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        _showMessage('Login failed. Please check your credentials.');
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          _showMessage('No user found with this phone number.');
        } else if (e.code == 'wrong-password') {
          _showMessage('Incorrect password.');
        } else {
          _showMessage('incorrect email or password');
        }
      } else {
        _showMessage('incorrect email or password');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 60),
            Text(
              'Login',
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.0),
            TextField(
              controller: _emailOrPhoneController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: Colors.green),
                labelText: 'E-Mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.green),
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              child: Text('LOGIN'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an Account?"),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
