import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import '../models/symbol_model.dart';
import '../services/symbol_service.dart';

class SymbolsController extends GetxController {
  final SymbolService _symbolService = SymbolService();
  final accountController = Get.find<AccountController>();
  final _storage = GetStorage();

  // State
  final RxList<SymbolGroupModel> symbolGroups = <SymbolGroupModel>[].obs;
  final RxList<SymbolModel> allSymbols = <SymbolModel>[].obs;
  final RxList<SymbolModel> filteredSymbols = <SymbolModel>[].obs;
  final RxList<String> favoriteSymbolIds = <String>[].obs;
  final Rxn<SymbolModel> selectedSymbol = Rxn<SymbolModel>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  String? _lastFetchedAccount;

  // Storage key
  static const String _favoritesKey = 'favorite_symbols';

  @override
  void onInit() {
    super.onInit();
    // Load favorites from storage
    _loadFavorites();

    // Auto fetch symbols when account changes (with debounce)
    ever(accountController.selectedAccount, (_) {
      if (accountController.selectedAccount.value != null) {
        final currentAccount = accountController.selectedAccount.value?.login;
        // Only fetch if account actually changed
        if (currentAccount != _lastFetchedAccount) {
          fetchSymbols();
        }
      }
    });
  }

  /// Load favorites from GetStorage
  void _loadFavorites() {
    final storedFavorites = _storage.read<List>(_favoritesKey);
    if (storedFavorites != null) {
      favoriteSymbolIds.value = List<String>.from(storedFavorites);
      print('📌 Loaded ${favoriteSymbolIds.length} favorite symbols');
    }
  }

  /// Save favorites to GetStorage
  void _saveFavorites() {
    _storage.write(_favoritesKey, favoriteSymbolIds);
    print('💾 Saved ${favoriteSymbolIds.length} favorite symbols');
  }

  /// Get favorite symbols
  List<SymbolModel> get favoriteSymbols {
    return allSymbols
        .where((symbol) => favoriteSymbolIds.contains(symbol.symbol))
        .toList();
  }

  /// Check if symbol is favorite
  bool isFavorite(String symbolId) {
    return favoriteSymbolIds.contains(symbolId);
  }

  /// Toggle favorite status
  void toggleFavorite(SymbolModel symbol) {
    if (isFavorite(symbol.symbol)) {
      favoriteSymbolIds.remove(symbol.symbol);
      print('⭐ Removed ${symbol.symbolAlias} from favorites');
    } else {
      favoriteSymbolIds.add(symbol.symbol);
      print('⭐ Added ${symbol.symbolAlias} to favorites');
    }
    _saveFavorites();
  }

  /// Clear all favorites (used on logout)
  void clearFavorites() {
    favoriteSymbolIds.clear();
    _storage.remove(_favoritesKey);
    print('🗑️ Cleared all favorite symbols');
  }

  /// Get symbols by category
  List<SymbolModel> getSymbolsByCategory(String category) {
    final group = symbolGroups.firstWhereOrNull(
      (g) => g.name.toLowerCase() == category.toLowerCase(),
    );
    return group?.symbols ?? [];
  }

  /// Fetch symbols from API
  Future<void> fetchSymbols() async {
    final account = accountController.selectedAccount.value?.login;

    if (account == null || account.isEmpty) {
      print('⚠️ No account selected');
      return;
    }

    // Skip if already loading or already fetched for this account
    if (isLoading.value || account == _lastFetchedAccount) {
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print('📥 Fetching symbols for account: $account');

      final response = await _symbolService.getSymbolsGroup(account);

      symbolGroups.value = response.response;

      // Flatten all symbols
      allSymbols.clear();
      for (var group in response.response) {
        allSymbols.addAll(group.symbols);
      }

      // Initialize filtered symbols
      filteredSymbols.value = allSymbols;

      // Auto-select first symbol if none selected
      if (selectedSymbol.value == null && allSymbols.isNotEmpty) {
        selectedSymbol.value = allSymbols.first;
      }

      _lastFetchedAccount = account;
      print(
        '✅ Loaded ${allSymbols.length} symbols in ${symbolGroups.length} groups',
      );
    } catch (e) {
      print('❌ Error fetching symbols: $e');
      hasError.value = true;
      errorMessage.value =
          'Terjadi kesalahan saat memuat data. Silakan coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Search symbols by query
  void searchSymbols(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredSymbols.value = allSymbols;
      return;
    }

    final searchLower = query.toLowerCase();
    filteredSymbols.value =
        allSymbols.where((symbol) {
          return symbol.symbol.toLowerCase().contains(searchLower) ||
              symbol.symbolAlias.toLowerCase().contains(searchLower);
        }).toList();
  }

  /// Select a symbol
  void selectSymbol(SymbolModel symbol) {
    selectedSymbol.value = symbol;
    print('📊 Selected symbol: ${symbol.symbolAlias} (${symbol.symbol})');
  }

  /// Get symbols by group name
  List<SymbolModel> getSymbolsByGroup(String groupName) {
    final group = symbolGroups.firstWhereOrNull(
      (g) => g.name.toLowerCase() == groupName.toLowerCase(),
    );
    return group?.symbols ?? [];
  }

  /// Get symbol by name
  SymbolModel? getSymbolByName(String symbolName) {
    return allSymbols.firstWhereOrNull(
      (s) => s.symbol == symbolName || s.symbolAlias == symbolName,
    );
  }

  /// Refresh symbols data
  Future<void> refreshSymbols() async {
    await fetchSymbols();
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    filteredSymbols.value = allSymbols;
  }
}
