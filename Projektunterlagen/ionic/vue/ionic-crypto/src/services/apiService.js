export async function fetchCryptoPrices() {
    const url = 'https://api.binance.com/api/v3/ticker/price';
    const response = await fetch(url);
    const data = await response.json();
  
    const usdtCoins = data
      .filter((coin) => coin.symbol.endsWith('USDT'))
      .map((coin) => ({
        symbol: coin.symbol,
        price: parseFloat(coin.price),
      }))
      .sort((a, b) => b.price - a.price)
      .slice(0, 100);
  
    return usdtCoins;
  }
  