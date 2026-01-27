import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/views/markets/models/market_mt5_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MarketMt5Controller extends GetxController with WidgetsBindingObserver {
  // Observable Map untuk menyimpan data market. Key: Symbol (String), Value: MarketModel
  final RxMap<String, MarketMt5Model> marketData = <String, MarketMt5Model>{}.obs;
  
  // Edit Mode dan Selection
  final RxBool isEditMode = false.obs;
  final RxSet<String> selectedMarkets = <String>{}.obs;
  final RxSet<String> archivedMarkets = <String>{}.obs;
  final RxMap<String, MarketMt5Model> archivedMarketData = <String, MarketMt5Model>{}.obs;
  
  // URL WebSocket
  final String _wsUrl = 'ws://207.148.119.106:9003';
  // Status koneksi
  final RxBool isConnected = false.obs;
  final RxBool hasConnectionError = false.obs;
  final RxBool isReconnecting = false.obs;
  late WebSocketChannel _channel;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); 
    connectWebSocket();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this); 
    _channel.sink.close();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Ketika aplikasi kembali ke foreground (Resumed)
    if (state == AppLifecycleState.resumed) {
      print("Aplikasi kembali aktif (RESUMED). Memeriksa koneksi...");
      if (!isConnected.value) {
        // Hanya sambungkan ulang jika saat ini terputus
        connectWebSocket(); 
      }
    } 
    
    // Opsional: Putuskan koneksi saat aplikasi di-background (Paused)
    // Walaupun OS sering memutusnya, ini bisa jadi housekeeping yang baik.
    else if (state == AppLifecycleState.paused) {
        print("Aplikasi di-background (PAUSED). Menutup koneksi...");
        _channel.sink.close();
        isConnected.value = false;
    }
  }

  void connectWebSocket() {
    // Tutup koneksi lama jika ada
    try {
      if (isConnected.value) {
        _channel.sink.close();
      }
    } catch (e) {
      print('Error closing old channel: $e');
    }

    try {
      isReconnecting.value = true;
      hasConnectionError.value = false;
      isConnected.value = false; // Reset dulu
      
      print('Mencoba koneksi ke $_wsUrl...');
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      
      _channel.stream.listen(
        (data) {
          // Set connected saat data pertama diterima
          if (!isConnected.value) {
            isConnected.value = true;
            isReconnecting.value = false;
            print('WebSocket TERSAMBUNG ke $_wsUrl');
          }
          
          _handleNewData(data.toString());
          
          // Reset error jika data diterima
          if (hasConnectionError.value) {
            hasConnectionError.value = false;
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          isConnected.value = false;
          hasConnectionError.value = true;
          isReconnecting.value = false;
        },
        onDone: () {
          print('WebSocket TERPUTUS');
          isConnected.value = false;
          isReconnecting.value = false;
          
          // Set error jika belum ada
          if (!hasConnectionError.value) {
            hasConnectionError.value = true;
          }
        },
        cancelOnError: false, // Jangan cancel stream saat error
      );
      
      // Set timeout untuk koneksi
      Future.delayed(const Duration(seconds: 5), () {
        if (isReconnecting.value && !isConnected.value) {
          print('WebSocket connection timeout');
          isReconnecting.value = false;
          hasConnectionError.value = true;
          try {
            _channel.sink.close();
          } catch (e) {
            print('Error closing channel after timeout: $e');
          }
        }
      });
      
    } catch (e) {
      print('Gagal menyambung ke WebSocket: $e');
      isConnected.value = false;
      hasConnectionError.value = true;
      isReconnecting.value = false;
    }
  }

  // Method untuk retry koneksi manual
  void retryConnection() {
    if (!isReconnecting.value) {
      connectWebSocket();
    }
  }

  void _handleNewData(String data) {
    // Asumsikan data yang diterima adalah string JSON tunggal per pesan
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final newModel = MarketMt5Model.fromJson(json);
      final symbol = newModel.symbol;

      // Logika pembaruan state
      marketData.update(symbol, (existingModel) {
        // Jika model sudah ada, update dengan data baru sambil menyimpan previous price
        return existingModel.updateWithNewData(newModel);
      }, ifAbsent: () {
        // Jika model belum ada, tambahkan baru
        return newModel;
      });
    } catch (e) {
      print('Error parsing or processing JSON: $e');
      print('Received data: $data');
    }
  }

  // ===== EDIT MODE METHODS =====
  
  /// Toggle edit mode
  void toggleEditMode() {
    isEditMode.toggle();
    if (!isEditMode.value) {
      // Clear selection ketika keluar dari edit mode
      selectedMarkets.clear();
    }
  }

  /// Toggle selection untuk market
  void toggleSelection(String symbol) {
    if (selectedMarkets.contains(symbol)) {
      selectedMarkets.remove(symbol);
    } else {
      selectedMarkets.add(symbol);
    }
  }

  /// Select all markets
  void selectAll(List<String> symbols) {
    selectedMarkets.addAll(symbols);
  }

  /// Deselect all markets
  void deselectAll() {
    selectedMarkets.clear();
  }

  /// Archive selected markets
  void archiveSelected() {
    // Simpan data market sebelum di-archive
    for (String symbol in selectedMarkets) {
      final marketModel = marketData[symbol];
      if (marketModel != null) {
        archivedMarketData[symbol] = marketModel;
      }
      marketData.remove(symbol);
    }
    archivedMarkets.addAll(selectedMarkets);
    selectedMarkets.clear();
  }

  /// Unarchive market
  void unarchiveMarket(String symbol) {
    // Restore data market
    final marketModel = archivedMarketData[symbol];
    if (marketModel != null) {
      marketData[symbol] = marketModel;
    }
    archivedMarkets.remove(symbol);
    archivedMarketData.remove(symbol);
  }

  /// Get visible markets (excluding archived ones)
  List<String> getVisibleMarkets() {
    return marketData.keys
        .where((symbol) => !archivedMarkets.contains(symbol))
        .toList();
  }
}