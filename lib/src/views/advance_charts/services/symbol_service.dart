import 'package:rrfx/src/service/auth_service.dart';
import '../models/symbol_model.dart';

class SymbolService {
  final AuthService _authService = AuthService();

  /// Fetch symbols grouped by category from API
  /// 
  /// Parameters:
  /// - [account]: Account login number (e.g., "391638")
  /// 
  /// Returns SymbolsResponse with grouped symbols or throws exception on error
  Future<SymbolsResponse> getSymbolsGroup(String account) async {
    try {
      final response = await _authService.get(
        'market/symbols-group?account=$account',
      );

      print("Account: $account, API Response: $response");

      if (response['status'] == true) {
        return SymbolsResponse.fromJson(response);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch symbols');
      }
    } catch (e) {
      print('❌ Error fetching symbols: $e');
      rethrow;
    }
  }

  /// Get all symbols as flat list (without grouping)
  Future<List<SymbolModel>> getAllSymbols(String account) async {
    try {
      final symbolsResponse = await getSymbolsGroup(account);
      
      List<SymbolModel> allSymbols = [];
      for (var group in symbolsResponse.response) {
        allSymbols.addAll(group.symbols);
      }
      
      return allSymbols;
    } catch (e) {
      print('❌ Error getting all symbols: $e');
      rethrow;
    }
  }

  /// Search symbols by name or alias
  Future<List<SymbolModel>> searchSymbols(String account, String query) async {
    try {
      final allSymbols = await getAllSymbols(account);
      
      final searchQuery = query.toLowerCase();
      return allSymbols.where((symbol) {
        return symbol.symbol.toLowerCase().contains(searchQuery) ||
               symbol.symbolAlias.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      print('❌ Error searching symbols: $e');
      rethrow;
    }
  }
}
