import 'package:flutter/material.dart';
import 'package:aplikasi_cafe/screens/home_screen.dart';
import 'package:aplikasi_cafe/screens/initialization_screen.dart';
import 'package:aplikasi_cafe/auth/signin_screen.dart';
import 'package:aplikasi_cafe/utils/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initializeDummyUsers();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "D' Cafe",
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.light,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate app initialization
      await Future.delayed(const Duration(seconds: 2));

      // Check if user is logged in
      final isLoggedIn = await AuthService.isLoggedIn();
      final isFirstTime = await AuthService.isFirstTime();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (!isFirstTime && !isLoggedIn) {
        // User has used app before but not logged in
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } else if (isFirstTime) {
        // First time user - show initialization
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InitializationScreen()),
        );
      } else {
        // User is logged in - go to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      // If initialization fails, ensure we still leave the splash state
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const InitializationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7b3f00),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_cafe,
                          color: Colors.white,
                          size: 40,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "D' Cafe",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Initializing...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
