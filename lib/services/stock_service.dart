import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';

class StockService {
  // Using Alpha Vantage or similar is common, but requires a key.
  // For demonstration, we'll simulate a response that mimics a real API call.
  // API Endpoint example: https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=IBM&apikey=DEMO_KEY

  Future<List<Stock>> getStocks() async {
    // In a real app, you would fetch from an API like this:
    // final response = await http.get(Uri.parse('YOUR_API_ENDPOINT'));
    // if (response.statusCode == 200) { ... }

    // Simulating API delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock Data simulating "Groww" like top stocks
    return [
      Stock(symbol: 'RELIANCE', name: 'Reliance Industries', price: 2987.50, change: 45.20, changePercent: 1.54),
      Stock(symbol: 'TCS', name: 'Tata Consultancy Svc', price: 3890.15, change: -23.40, changePercent: -0.60),
      Stock(symbol: 'HDFCBANK', name: 'HDFC Bank', price: 1456.80, change: 12.50, changePercent: 0.87),
      Stock(symbol: 'INFY', name: 'Infosys Limited', price: 1678.30, change: -8.90, changePercent: -0.53),
      Stock(symbol: 'ICICIBANK', name: 'ICICI Bank', price: 1045.60, change: 15.30, changePercent: 1.48),
      Stock(symbol: 'SBIN', name: 'State Bank of India', price: 765.40, change: 8.20, changePercent: 1.08),
      Stock(symbol: 'BHARTIARTL', name: 'Bharti Airtel', price: 1123.90, change: 25.60, changePercent: 2.33),
      Stock(symbol: 'ITC', name: 'ITC Limited', price: 435.20, change: -2.10, changePercent: -0.48),
      Stock(symbol: 'LICI', name: 'LIC India', price: 1023.50, change: 35.80, changePercent: 3.62),
      Stock(symbol: 'TATAMOTORS', name: 'Tata Motors', price: 987.45, change: 42.15, changePercent: 4.46),
      Stock(symbol: 'BAJFINANCE', name: 'Bajaj Finance', price: 6789.00, change: -120.50, changePercent: -1.74),
      Stock(symbol: 'MARUTI', name: 'Maruti Suzuki', price: 11234.50, change: 56.50, changePercent: 0.51),
      Stock(symbol: 'SUNPHARMA', name: 'Sun Pharma', price: 1567.80, change: 18.20, changePercent: 1.17),
      Stock(symbol: 'ASIANPAINT', name: 'Asian Paints', price: 2890.30, change: -45.60, changePercent: -1.55),
      Stock(symbol: 'TITAN', name: 'Titan Company', price: 3678.90, change: 12.30, changePercent: 0.34),
      Stock(symbol: 'ADANIENT', name: 'Adani Enterprises', price: 3145.20, change: 89.50, changePercent: 2.93),
      Stock(symbol: 'HCLTECH', name: 'HCL Technologies', price: 1567.40, change: -12.40, changePercent: -0.78),
      Stock(symbol: 'WIPRO', name: 'Wipro Limited', price: 489.30, change: -3.20, changePercent: -0.65),
      Stock(symbol: 'ULTRACEMCO', name: 'UltraTech Cement', price: 9876.50, change: 123.40, changePercent: 1.25),
      Stock(symbol: 'NTPC', name: 'NTPC Limited', price: 345.60, change: 4.50, changePercent: 1.32),
      Stock(symbol: 'ONGC', name: 'ONGC', price: 267.80, change: 5.60, changePercent: 2.14),
      Stock(symbol: 'AXISBANK', name: 'Axis Bank', price: 1089.40, change: -8.90, changePercent: -0.81),
      Stock(symbol: 'POWERGRID', name: 'Power Grid Corp', price: 289.50, change: 3.40, changePercent: 1.19),
      Stock(symbol: 'COALINDIA', name: 'Coal India', price: 456.70, change: 12.30, changePercent: 2.77),
      Stock(symbol: 'BAJAJ-AUTO', name: 'Bajaj Auto', price: 7890.30, change: -45.60, changePercent: -0.57),
      Stock(symbol: 'M&M', name: 'Mahindra & Mahindra', price: 1890.40, change: 34.50, changePercent: 1.86),
      Stock(symbol: 'ADANIPORTS', name: 'Adani Ports', price: 1234.50, change: 45.60, changePercent: 3.84),
      Stock(symbol: 'JIOFIN', name: 'Jio Financial', price: 345.60, change: 12.30, changePercent: 3.69),
      Stock(symbol: 'ZOMATO', name: 'Zomato', price: 156.70, change: 8.90, changePercent: 6.02),
      Stock(symbol: 'TATASTEEL', name: 'Tata Steel', price: 145.60, change: 2.30, changePercent: 1.60),
      Stock(symbol: 'PAYTM', name: 'Paytm', price: 420.50, change: -18.90, changePercent: -4.30),
      Stock(symbol: 'DLF', name: 'DLF Limited', price: 890.40, change: 15.60, changePercent: 1.78),
      Stock(symbol: 'IRFC', name: 'IRFC', price: 145.60, change: 5.60, changePercent: 4.00),
      Stock(symbol: 'VBL', name: 'Varun Beverages', price: 1456.70, change: 34.50, changePercent: 2.43),
      Stock(symbol: 'HINDUNILVR', name: 'Hindustan Unilever', price: 2345.60, change: -12.30, changePercent: -0.52),
      Stock(symbol: 'NESTLEIND', name: 'Nestle India', price: 2567.80, change: -34.50, changePercent: -1.33),
      Stock(symbol: 'TECHM', name: 'Tech Mahindra', price: 1234.50, change: -15.60, changePercent: -1.25),
      Stock(symbol: 'GRASIM', name: 'Grasim Industries', price: 2134.50, change: 23.40, changePercent: 1.11),
      Stock(symbol: 'CIPLA', name: 'Cipla', price: 1456.70, change: 12.30, changePercent: 0.85),
    ];
  }

  // Example of how to structure a real call (commented out)
  /*
  Future<Stock> fetchStockQuote(String symbol) async {
    final apiKey = 'YOUR_API_KEY';
    final url = 'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey';
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final quote = data['Global Quote'];
      return Stock(
        symbol: quote['01. symbol'],
        name: symbol, // API might not return name in quote
        price: double.parse(quote['05. price']),
        change: double.parse(quote['09. change']),
        changePercent: double.parse(quote['10. change percent'].replaceAll('%', '')),
      );
    } else {
      throw Exception('Failed to load stock');
    }
  }
  */
}
