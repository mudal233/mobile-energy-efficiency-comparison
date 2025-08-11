import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto.dart';

class ApiService {
  final String apiUrl = 'https://api.binance.com/api/v3/ticker/price';

  Future<List<Crypto>> fetchPrices() async {
    final url = Uri.parse(apiUrl);

    final response = await http.get(url);


    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);

      List<Crypto> allUsdtCoins = jsonList
          .where((coin) => coin['symbol'].toString().endsWith('USDT'))
          .map((coin) => Crypto.fromJson(coin))
          .toList();

      allUsdtCoins.sort((a, b) => b.price.compareTo(a.price));
      return allUsdtCoins.take(100).toList();
    } else {
      throw Exception('Fehler beim Laden der Preise');
    }
  }

}
