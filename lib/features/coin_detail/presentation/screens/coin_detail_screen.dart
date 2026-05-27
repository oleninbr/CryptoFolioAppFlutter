import 'package:flutter/material.dart';

class CoinDetailScreen extends StatelessWidget {
  final String coinId;

  const CoinDetailScreen({super.key, required this.coinId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(coinId)),
      body: const Center(child: Text('Coin Detail Screen')),
    );
  }
}
