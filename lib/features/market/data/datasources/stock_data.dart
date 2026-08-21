import 'package:trading_app/features/market/data/models/stock_model.dart';

class StockData {
  StockData._();

  static const List<StockModel> stocks = [
    StockModel(
      symbol: 'RELIANCE',
      name: 'Reliance Industries',
      initialPricePaise: 285075,
    ),
    StockModel(
      symbol: 'TCS',
      name: 'Tata Consultancy Services',
      initialPricePaise: 345020,
    ),
    StockModel(symbol: 'INFY', name: 'Infosys', initialPricePaise: 178560),
    StockModel(
      symbol: 'HDFCBANK',
      name: 'HDFC Bank',
      initialPricePaise: 194325,
    ),
    StockModel(
      symbol: 'ICICIBANK',
      name: 'ICICI Bank',
      initialPricePaise: 132450,
    ),
    StockModel(
      symbol: 'SBIN',
      name: 'State Bank of India',
      initialPricePaise: 86540,
    ),
    StockModel(symbol: 'ITC', name: 'ITC Limited', initialPricePaise: 42575),
    StockModel(
      symbol: 'LT',
      name: 'Larsen & Toubro',
      initialPricePaise: 382610,
    ),
    StockModel(
      symbol: 'BHARTIARTL',
      name: 'Bharti Airtel',
      initialPricePaise: 198750,
    ),
    StockModel(
      symbol: 'AXISBANK',
      name: 'Axis Bank',
      initialPricePaise: 124680,
    ),
  ];

  static StockModel getBySymbol(String symbol) {
    return stocks.firstWhere((stock) => stock.symbol == symbol);
  }
}
