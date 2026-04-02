import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/markets/models/market_mt5_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MarketMt5Controller extends GetxController with WidgetsBindingObserver {
  // Storage untuk persist data market
  final GetStorage _storage = GetStorage();
  static const String _cacheKey = 'cached_market_data';
  static const String _cacheTimeKey = 'cached_market_time';
  static const String _archivedKey = 'archived_markets';
  
  // Observable Map untuk menyimpan data market. Key: Symbol (String), Value: MarketModel
  final RxMap<String, MarketMt5Model> marketData = <String, MarketMt5Model>{}.obs;
  
  // Edit Mode dan Selection
  final RxBool isEditMode = false.obs;
  final RxSet<String> selectedMarkets = <String>{}.obs;
  final RxSet<String> archivedMarkets = <String>{}.obs;
  final RxMap<String, MarketMt5Model> archivedMarketData = <String, MarketMt5Model>{}.obs;
  
  // Flag untuk menandai data offline/cached
  final RxBool isUsingCachedData = false.obs;
  final Rxn<DateTime> lastUpdateTime = Rxn<DateTime>();
  
  // URL WebSocket
  final String _wsUrl = GlobalVariable.wsMarketURL;
  // Status koneksi
  final RxBool isConnected = false.obs;
  final RxBool hasConnectionError = false.obs;
  final RxBool isReconnecting = false.obs;
  late WebSocketChannel _channel;
  
  // Auto-retry parameters
  Timer? _retryTimer;
  int _retryAttempt = 0;
  static const int _maxRetryAttempts = 10;
  static const int _initialRetryDelaySeconds = 2;
  static const int _maxRetryDelaySeconds = 60;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    
    // Load cached data terlebih dahulu
    _loadCachedData();
    _loadArchivedMarkets();
    
    // Kemudian coba connect ke websocket
    connectWebSocket();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    // Cancel retry timer
    _cancelRetryTimer();
    // Save data sebelum close
    _saveCacheData();
    _saveArchivedMarkets();
    _channel.sink.close();
    super.onClose();
  }
  
  /// Cancel any pending retry timer
  void _cancelRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }
  
  /// Calculate retry delay with exponential backoff
  int _getRetryDelay() {
    // Exponential backoff: 2, 4, 8, 16, 32, 60, 60, 60...
    final delay = _initialRetryDelaySeconds * (1 << _retryAttempt.clamp(0, 5));
    return delay.clamp(_initialRetryDelaySeconds, _maxRetryDelaySeconds);
  }
  
  /// Schedule auto-retry with exponential backoff
  void _scheduleAutoRetry() {
    // Don't retry if we've exceeded max attempts
    if (_retryAttempt >= _maxRetryAttempts) {
      print('⚠️ Max retry attempts ($_maxRetryAttempts) reached. Stopping auto-retry.');
      return;
    }
    
    // Cancel any existing timer
    _cancelRetryTimer();
    
    final delaySeconds = _getRetryDelay();
    print('🔄 Auto-retry scheduled in ${delaySeconds}s (attempt ${_retryAttempt + 1}/$_maxRetryAttempts)');
    
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!isConnected.value && !isReconnecting.value) {
        _retryAttempt++;
        connectWebSocket();
      }
    });
  }
  
  /// Reset retry counter (called on successful connection)
  void _resetRetryCounter() {
    _retryAttempt = 0;
    _cancelRetryTimer();
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
        print("Aplikasi di-background (PAUSED). Menyimpan data dan menutup koneksi...");
        _saveCacheData();
        _saveArchivedMarkets();
        _channel.sink.close();
        isConnected.value = false;
    }
  }

  // ===== CACHE METHODS =====
  
  /// Load cached market data dari storage
  void _loadCachedData() {
    try {
      final cachedJson = _storage.read<String>(_cacheKey);
      final cachedTimeStr = _storage.read<String>(_cacheTimeKey);
      
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> cachedMap = jsonDecode(cachedJson);
        
        cachedMap.forEach((symbol, data) {
          try {
            // Skip market yang di-archive
            if (archivedMarkets.contains(symbol)) {
              return;
            }
            
            final model = MarketMt5Model.fromJson(data);
            marketData[symbol] = model;
          } catch (e) {
            print('Error loading cached market $symbol: $e');
          }
        });
        
        if (cachedTimeStr != null) {
          lastUpdateTime.value = DateTime.tryParse(cachedTimeStr);
        }
        
        if (marketData.isNotEmpty) {
          isUsingCachedData.value = true;
          print('✅ Loaded ${marketData.length} cached markets (${archivedMarkets.length} archived)');
        }
      }
    } catch (e) {
      print('Error loading cached data: $e');
    }
  }
  
  /// Save market data ke storage
  void _saveCacheData() {
    try {
      if (marketData.isEmpty) return;
      
      final Map<String, dynamic> cacheMap = {};
      marketData.forEach((symbol, model) {
        cacheMap[symbol] = model.toJson();
      });
      
      _storage.write(_cacheKey, jsonEncode(cacheMap));
      _storage.write(_cacheTimeKey, DateTime.now().toIso8601String());
      print('💾 Saved ${marketData.length} markets to cache');
    } catch (e) {
      print('Error saving cache data: $e');
    }
  }
  
  /// Load archived markets dari storage
  void _loadArchivedMarkets() {
    try {
      final archivedJson = _storage.read<String>(_archivedKey);
      if (archivedJson != null && archivedJson.isNotEmpty) {
        final List<dynamic> archivedList = jsonDecode(archivedJson);
        archivedMarkets.addAll(archivedList.cast<String>());
        print('✅ Loaded ${archivedMarkets.length} archived markets');
      }
    } catch (e) {
      print('Error loading archived markets: $e');
    }
  }
  
  /// Save archived markets ke storage
  void _saveArchivedMarkets() {
    try {
      _storage.write(_archivedKey, jsonEncode(archivedMarkets.toList()));
    } catch (e) {
      print('Error saving archived markets: $e');
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
            // Reset retry counter on successful connection
            _resetRetryCounter();
            print('✅ WebSocket TERSAMBUNG ke $_wsUrl');
          }
          
          _handleNewData(data.toString());
          
          // Reset error jika data diterima
          if (hasConnectionError.value) {
            hasConnectionError.value = false;
          }
        },
        onError: (error) {
          print('❌ WebSocket Error: $error');
          isConnected.value = false;
          hasConnectionError.value = true;
          isReconnecting.value = false;
          // Schedule auto-retry on error
          _scheduleAutoRetry();
        },
        onDone: () {
          print('⚡ WebSocket TERPUTUS');
          isConnected.value = false;
          isReconnecting.value = false;
          
          // Set error jika belum ada
          if (!hasConnectionError.value) {
            hasConnectionError.value = true;
          }
          // Schedule auto-retry on disconnect
          _scheduleAutoRetry();
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

  // Counter untuk periodic save
  int _dataUpdateCount = 0;
  
  void _handleNewData(String data) {
    // Asumsikan data yang diterima adalah string JSON tunggal per pesan
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final newModel = MarketMt5Model.fromJson(json);
      final symbol = newModel.symbol;

      // Cek apakah market ini sudah di-archive
      if (archivedMarkets.contains(symbol)) {
        return; // Jangan tampilkan market yang di-archive
      }

      // Logika pembaruan state
      marketData.update(symbol, (existingModel) {
        // Jika model sudah ada, update dengan data baru sambil menyimpan previous price
        return existingModel.updateWithNewData(newModel);
      }, ifAbsent: () {
        // Jika model belum ada, tambahkan baru
        return newModel;
      });
      
      // Update flag - sekarang menggunakan data live
      if (isUsingCachedData.value) {
        isUsingCachedData.value = false;
      }
      lastUpdateTime.value = DateTime.now();
      
      // Save cache secara periodic (setiap 50 update)
      _dataUpdateCount++;
      if (_dataUpdateCount >= 50) {
        _saveCacheData();
        _dataUpdateCount = 0;
      }
      
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
    // Simpan ke storage
    _saveArchivedMarkets();
    print('✅ Archived markets saved to storage');
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
    // Simpan ke storage
    _saveArchivedMarkets();
    print('✅ Unarchived market saved to storage');
  }

  /// Get visible markets (excluding archived ones)
  List<String> getVisibleMarkets() {
    return marketData.keys
        .where((symbol) => !archivedMarkets.contains(symbol))
        .toList();
  }
}