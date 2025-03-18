import 'package:flutter/material.dart';
import 'farmer_wallet.dart';
import 'farmer_transaction_summary.dart';

class FarmerDashboardPage extends StatelessWidget {
  final String userId;
  final String username;

  const FarmerDashboardPage({super.key, required this.userId, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  /// Builds the AppBar
  AppBar _buildAppBar() {
    return AppBar(title: const Text("Farmer Dashboard"));
  }

  /// Builds the main body content
  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWelcomeText(),
          const SizedBox(height: 10),
          _buildUserIdText(),
          const SizedBox(height: 20),
          _buildTransactionSummaryButton(context),
          const SizedBox(height: 10),
          _buildWalletButton(context),
        ],
      ),
    );
  }

  /// Displays the welcome message
  Widget _buildWelcomeText() {
    return Text(
      "Welcome, $username!",
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  /// Displays the user ID text
  Widget _buildUserIdText() {
    return Text(
      "User ID: $userId",
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    );
  }

  /// Builds the Transaction Summary button
  Widget _buildTransactionSummaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerTransactionSummary(userId: userId),
          ),
        );
      },
      child: const Text("Transaction Summary"),
    );
  }

  /// Builds the Wallet button
  Widget _buildWalletButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerWallet(userId: userId),
          ),
        );
      },
      child: const Text("Wallet"),
    );
  }
}
