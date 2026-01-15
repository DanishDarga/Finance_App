import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/stock.dart';
import '../../services/stock_service.dart';

class StockMarketPage extends StatefulWidget {
  const StockMarketPage({super.key});

  @override
  State<StockMarketPage> createState() => _StockMarketPageState();
}

class _StockMarketPageState extends State<StockMarketPage> {
  final StockService _stockService = StockService();
  late Future<List<Stock>> _stocksFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Stock> _allStocks = [];
  List<Stock> _filteredStocks = [];

  @override
  void initState() {
    super.initState();
    _loadStocks();
    _searchController.addListener(_filterStocks);
  }

  void _loadStocks() {
    setState(() {
      _stocksFuture = _stockService.getStocks().then((stocks) {
        _allStocks = stocks;
        _filteredStocks = stocks;
        return stocks;
      });
    });
  }

  void _filterStocks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStocks = _allStocks.where((stock) {
        return stock.symbol.toLowerCase().contains(query) ||
            stock.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using a light/dark aware theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppConstants.backgroundColorDark : AppConstants.backgroundColorLight;
    final cardColor = isDarkMode ? AppConstants.cardColorDark : AppConstants.cardColorLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Market Trends'),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStocks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stocks (e.g. Reliance, TCS)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),

          // Market List
          Expanded(
            child: FutureBuilder<List<Stock>>(
              future: _stocksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppConstants.errorColor),
                        const SizedBox(height: 16),
                        Text('Failed to load market data', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        ElevatedButton(onPressed: _loadStocks, child: const Text('Retry')),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No stocks available'));
                }

                final stocks = _filteredStocks;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final stock = stocks[index];
                    final isPositive = stock.change >= 0;
                    
                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Stock Icon (Placeholder for company logo)
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isPositive 
                                    ? AppConstants.successColor.withOpacity(0.1)
                                    : AppConstants.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  stock.symbol[0],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: isPositive ? AppConstants.successColor : AppConstants.errorColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Name and Symbol
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stock.symbol,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stock.name,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Price and Change
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${AppConstants.currencySymbol}${stock.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                      color: isPositive ? AppConstants.successColor : AppConstants.errorColor,
                                      size: 16,
                                    ),
                                    Text(
                                      '${stock.change.abs().toStringAsFixed(2)} (${stock.changePercent.abs().toStringAsFixed(2)}%)',
                                      style: TextStyle(
                                        color: isPositive ? AppConstants.successColor : AppConstants.errorColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
