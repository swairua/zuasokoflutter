import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
import '../screens/change_password_page.dart';
import '../screens/dashboard_page.dart';
import '../screens/farmer_dashboard_page.dart'; // Ensure this is imported

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterPage());
          case '/change_password':
            return MaterialPageRoute(builder: (context) => const ChangePasswordPage());
          case '/dashboard':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => DashboardPage(
                  userId: args['userId'], 
                  username: args['username'],
                ),
              );
            }
            return _errorRoute();
          case '/farmer_dashboard':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => FarmerDashboardPage(
                  userId: args['userId'],
                  username: args['username'],
                ),
              );
            }
            return _errorRoute();
          default:
            return _errorRoute();
        }
      },
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Page not found!")),
      ),
    );
  }
}
