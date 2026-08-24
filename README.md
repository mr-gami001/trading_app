# Production-Quality Clean Architecture Flutter Trading App

A complete, high-performance, ready-to-publish mobile trading application built with **Flutter (Stable Channel)**, **Clean Architecture**, **`flutter_bloc` state management**, **`get_it` dependency injection**, **`decimal` financial math precision**, and a **Free Live Real-Time WebSocket Data Stream**.

Designed for heavy real-time data loads, zero visual jank, precise monetary calculations, and full local persistence across app restarts.

---

## ⚡ Live Free WebSocket Engine

- **Real-Time Live WebSocket Feed**: Integrated [`LiveWebSocketMarketDataDataSource`](file:///Users/divyeshgami/Desktop/Trading%20App%20Flutter%20Assignment/lib/data/datasources/market/live_websocket_market_data_datasource.dart) connecting to an **open, 100% free public market WebSocket stream** (`wss://stream.binance.com:9443/ws/!miniTicker@arr`).
- **Zero API Key / Zero Cost**: Requires no setup, environment variables, or paid subscriptions.
- **Auto-Reconnection**: Handles disconnects seamlessly with exponential backoff.
- **Seamless Clean Architecture Swap**: The data source implements `MarketDataDataSource` and streams live ticks directly to `MarketBloc`, `WatchlistBloc`, `HoldingsBloc`, and `BuySellTicketPage` without modifying any UI or business logic.

---

## 🏗 Architecture & Folder Structure

```text
lib/
├── app/
│   ├── app.dart                          # MaterialApp with MultiBlocProvider
│   ├── app_bloc_observer.dart            # Custom BlocObserver for telemetry
│   └── theme/                            # Material 3 Dark Trading Theme
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_text_styles.dart
│
├── core/
│   ├── constants/
│   │   ├── stock_constants.dart          # 10 Stock universe with initial Decimal prices
│   │   └── app_constants.dart            # Storage keys and defaults
│   ├── errors/
│   ├── services/
│   └── utils/
│       ├── decimal_utils.dart            # Financial Decimal math helpers
│       ├── currency_formatter.dart       # INR currency formatter
│       └── validation_utils.dart         # Order quantity validation logic
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── portfolio_local_datasource.dart
│   │   │   └── watchlist_local_datasource.dart
│   │   └── market/
│   │       ├── market_data_datasource.dart               # Interface
│   │       ├── market_data_datasource_impl.dart          # Local Mock Generator
│   │       └── live_websocket_market_data_datasource.dart # Free Live WebSocket Stream
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── features/
│   ├── market/                           # Live Prices Overview & WebSocket Stream
│   ├── watchlist/                        # Multi-Watchlist Management
│   ├── trading/                          # Buy/Sell Order Execution
│   └── holdings/                         # Portfolio Holdings & Real-Time P&L
│
├── injection_container.dart              # Dependency Injection initialization
└── main.dart
```

---

## 🌟 Key Features & Specification Compliance

### 1. Watchlist (Feature 1)
- **Multiple Watchlists**: Create, rename, and delete watchlists dynamically.
- **Stock Picker**: Select from the 10 supported stocks via a modal sheet.
- **Drag-to-Reorder**: Interactive stock reordering powered by `ReorderableListView` dispatching `ReorderWatchlistEvent`.
- **Live Updating & Preservation**: Live ticks bind accurately to reordered rows without stale updates.
- **Persistent Storage**: Watchlists, active index, and stock ordering persist across app restarts using `SharedPreferences`.
- **Pre-filled Order Ticket**: Tapping any stock tile opens the Buy/Sell ticket pre-filled with that stock.

### 2. Live Prices & WebSocket Feed (Feature 2)
- **10 Indian Stocks Universe**:
  - `RELIANCE`, `TCS`, `INFY`, `HDFCBANK`, `ICICIBANK`, `SBIN`, `ITC`, `LT`, `BHARTIARTL`, `AXISBANK`.
- **Free Live WebSocket Engine**: Connects via WebSockets to stream real-time price updates dynamically into the app.
- **Stress Test Mode**: Supports high-frequency live ticks with targeted `BlocSelector` per row (only the ticked stock tile rebuilds).
- **Price Flashing**: Visual green flash on price increase and red flash on price decrease.

### 3. Buy / Sell Ticket (Feature 3)
- **Order Execution Form**: Supports BUY and SELL orders at current market LTP.
- **Live LTP Binding**: Live price and projected order value (`Quantity × LTP`) update in real time using `Decimal` math while form is open.
- **Execution Price Capture**: Captures the exact submission LTP at submission time.
- **Inline Validation**:
  - Positive whole integer quantity check.
  - Margin/Balance check before BUY submit (`orderValue <= walletBalance`).
  - Held quantity check before SELL submit (`sellQuantity <= heldQuantity`).
- **Instant Execution**: Deducts from wallet balance (Buy) or holdings quantity (Sell), creates/updates holding with weighted average price calculation, and records in order history.
- **Order Confirmation**: Displays execution summary modal.

### 4. Portfolio & Holdings (Feature 4)
- **Real-Time Portfolio P&L**:
  - Live Total Invested, Current Portfolio Value, Total P&L (₹ and %).
- **Stock Rows**: Shows Symbol, Quantity, Average Cost, LTP, Current Value, and individual P&L.
- **Dynamic Sorting**: Sort by P&L (Descending/Ascending), Current Value, or Symbol. Reorders dynamically as live market ticks arrive.
- **Auto-Removal**: Selling 100% of a holding removes the row cleanly.
- **Persisted State**: Holdings, order history, and wallet margin (`₹10,00,000.00` starting default) persist across app restarts.

---

## 💰 Financial Decimal Math Precision

To guarantee zero floating-point arithmetic errors, **no monetary calculations use `double`**:
- **Prices, Wallet Balances, Order Values, Average Costs, P&L, P&L %, Change, and Change %** are represented and calculated strictly using `Decimal` (`decimal` package) and `DecimalUtils`.
- **Weighted Average Cost Formula**:
  $$\text{New Avg Cost} = \frac{(\text{oldQty} \times \text{oldAvg}) + (\text{newQty} \times \text{buyPrice})}{\text{oldQty} + \text{newQty}}$$
- All currency values are formatted to Indian Rupee standard format (`₹1,23,456.78`).

---

## 🚀 How to Run the Application

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run automated test suite
flutter test

# 3. Launch application (macOS Desktop / iOS Simulator / Android / Web)
flutter run
```
