import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
import '../screens/change_password_page.dart';
import '../screens/dashboard_page.dart';
import '../screens/farmer_dashboard_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zuasoko',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Debug: Print the current route and arguments
        debugPrint('Navigating to route: ${settings.name}');
        debugPrint('Route arguments: ${settings.arguments}');

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
              // Debug: Print extracted arguments
              debugPrint('Dashboard args - userId: ${args['userId']}, username: ${args['username']}');
              if (args['userId'] == null) {
                debugPrint('⚠️ userId is NULL in dashboard arguments!');
              }
              return MaterialPageRoute(
                builder: (context) => DashboardPage(
                  userId: args['userId'], 
                  username: args['username'],
                ),
              );
            } else {
              debugPrint('❌ Invalid arguments type for /dashboard: ${settings.arguments.runtimeType}');
              return _errorRoute();
            }
          case '/farmer_dashboard':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              // Debug: Print extracted arguments
              debugPrint('FarmerDashboard args - userId: ${args['userId']}, username: ${args['username']}');
              if (args['userId'] == null) {
                debugPrint('⚠️ userId is NULL in farmer_dashboard arguments!');
              }
              return MaterialPageRoute(
                builder: (context) => FarmerDashboardPage(
                  userId: args['userId'],
                  username: args['username'],
                ),
              );
            } else {
              debugPrint('❌ Invalid arguments type for /farmer_dashboard: ${settings.arguments.runtimeType}');
              return _errorRoute();
            }
          default:
            debugPrint('❌ Unknown route: ${settings.name}');
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