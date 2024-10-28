import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skypi/screens/login_screen.dart';
import 'package:skypi/screens/notification_screen.dart';
import 'package:skypi/screens/signup_screen.dart';
import 'package:skypi/screens/upload_project_screen.dart';
import 'package:skypi/screens/user_profile_screen.dart';
import 'package:skypi/screens/home_screen.dart';
import 'package:skypi/screens/task_screen.dart' as task;

// Your web app's Firebase configuration
const FirebaseOptions firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyDI-c6AJUmgFbEmwKnDreeLwVdAzu3P4YE",
  authDomain: "skypi-8a884.firebaseapp.com",
  projectId: "skypi-8a884",
  storageBucket: "skypi-8a884.appspot.com",
  messagingSenderId: "303386496023",
  appId: "1:303386496023:web:9a3786fd392ff478e32052",
  measurementId: "G-SCQ5JYBX22",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: firebaseConfig);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyPi',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/task': (context) => task.TaskScreen(),
        '/profile': (context) => UserProfileScreen(
          category: '', // Add the appropriate category name or variable here
          onProgressUpdated: (progress) {
            // Implement functionality here if needed
          },
        ),
        '/notification': (context) => PostsScreen(),
        '/upload': (context) => UploadProjectScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
