# Trading App

A Flutter-based stock trading application built as part of a Flutter Developer assignment.

The app demonstrates a simulated trading experience with market data, watchlists, holdings, order placement, and order history.

## Features

- 📈 Market screen with live simulated price updates
- 🔎 Stock search
- ⭐ Multiple watchlists
- ➕ Add and remove stocks from watchlists
- ↕️ Reorder watchlist stocks
- 💼 Holdings with portfolio summary
- 📊 Portfolio P&L calculation
- 🛒 Buy and sell orders
- 💰 Wallet balance validation
- ✅ Order confirmation
- 📋 Order history
- 📱 Responsive UI
- 🎨 Consistent dark trading-themed UI

## Stocks Used

The app uses the following 10 stocks throughout the application:

- RELIANCE
- TCS
- INFY
- HDFCBANK
- ICICIBANK
- SBIN
- ITC
- LT
- BHARTIARTL
- AXISBANK

## Architecture

The application follows a feature-based architecture with BLoC for state management.

```text
lib/
├── core/
│
├── features/
│   ├── market/
│   │   ├── bloc/
│   │   ├── data/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── watchlist/
│   │   ├── bloc/
│   │   ├── data/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── holdings/
│   │   ├── bloc/
│   │   ├── data/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── trading/
│       ├── bloc/
│       ├── data/
│       ├── screens/
│       └── widgets/
│
└── main.dart
