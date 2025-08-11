import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/crypto.dart';

void main() {
  runApp(CryptoPriceApp());
}

class CryptoPriceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Prices',
      theme: ThemeData.light(), // Light Theme
      home: CryptoPriceScreen(),
    );
  }
}

class CryptoPriceScreen extends StatefulWidget {
  @override
  _CryptoPriceScreenState createState() => _CryptoPriceScreenState();
}

class _CryptoPriceScreenState extends State<CryptoPriceScreen> {
  final ApiService apiService = ApiService();
  List<Crypto> cryptoPrices = [];
  Timer? timer;
  bool isUpdating = true;

  @override
  void initState() {
    super.initState();
    fetchCryptoPrices();
    startAutoUpdate();
  }

  void fetchCryptoPrices() async {
    try {
      List<Crypto> prices = await apiService.fetchPrices();
      setState(() {
        cryptoPrices = prices;
      });
    } catch (e) {
      print('Error fetching prices: $e');
    }
  }

  void startAutoUpdate() {
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      if (isUpdating) {
        fetchCryptoPrices();
      }
    });
  }

  void stopAutoUpdate() {
    setState(() {
      isUpdating = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Crypto Prices'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: stopAutoUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: Text(
                'flutter',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cryptoPrices.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      cryptoPrices[index].symbol,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '\$${cryptoPrices[index].price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
