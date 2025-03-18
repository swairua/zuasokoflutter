import 'package:flutter/material.dart';
import 'screens/farmer_dashboard_page.dart';
import 'screens/driver_dashboard_page.dart';
import 'screens/customer_dashboard_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;

          switch (settings.name) {
            case '/farmer_dashboard_page':
              return MaterialPageRoute(
                builder: (context) => FarmerDashboardPage(
                  userId: args['userId'],
                  username: args['username'],
                ),
              );

            case '/driver_dashboard_page':
              return MaterialPageRoute(
                builder: (context) => DriverDashboardPage(
                  userId: args['userId'],
                  username: args['username'],
                ),
              );

            case '/customer_dashboard_page':
              return MaterialPageRoute(
                builder: (context) => CustomerDashboardPage(
                  userId: args['userId'],
                  username: args['username'],
                ),
              );

            case '/dashboard_page':
              return MaterialPageRoute(
                builder: (context) => DashboardPage(
                  userId: args['userId'],
                  username: args['username'],
                ),
              );
          }
        }

        return null;
      },
    );
  }
}
