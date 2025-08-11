class Crypto {
  final String symbol;
  final double price;

  Crypto({required this.symbol, required this.price});

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      symbol: json['symbol'],
      price: double.parse(json['price']),
    );
  }
}
