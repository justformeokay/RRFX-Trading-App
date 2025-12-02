import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'account_model.dart';
import 'account_service.dart';

class AccountController extends GetxController {
  final AccountService _accountService = AccountService();
  final box = GetStorage();
  final String _defaultAccountKey = 'defaultAccountLogin';

  final RxList<AccountDetailModel> _allAccounts = <AccountDetailModel>[].obs;
  List<AccountDetailModel> get allAccounts => _allAccounts;

  final Rxn<AccountDetailModel> selectedAccount = Rxn<AccountDetailModel>(null);
  final isLoading = true.obs;

  // LIST REAL
  List<AccountDetailModel> get realAccounts => _allAccounts.where((acc) => acc.type?.toLowerCase() == 'real').toList();

  // LIST DEMO
  List<AccountDetailModel> get demoAccounts => _allAccounts.where((acc) => acc.type?.toLowerCase() == 'demo').toList();

  // --- Getters untuk View ---
  String? get selectedLoginId => selectedAccount.value?.login;
  bool get hasAccounts => _allAccounts.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchAccountInfo();
  }

  Future<bool> connectToMeta5({String? loginNumber}) async {
    isLoading.value = true;
    try {
      bool success = await _accountService.connectingAccountToMeta5(loginNumber: loginNumber);
      isLoading.value = false;
      if (success) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePasswordMeta5({String? loginNumber, String? newPassword, String? otp}) async {
    isLoading.value = true;
    try {
      bool success = await _accountService.changePasswordMeta5(loginNumber: loginNumber, newPassword: newPassword, otp: otp);
      isLoading.value = false;
      if (success) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendOTPChangePasswordMeta() async {
    isLoading.value = true;
    try {
      bool success = await _accountService.sendOTPChangePasswordMeta();
      isLoading.value = false;
      if (success) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAccountInfo() async {
    isLoading.value = true;
    try {
      String accessToken = await _accountService.getAccessToken();
      final accountModel = await _accountService.fetchAccountInfo(accessToken: accessToken);
      isLoading.value = false;
      _allAccounts.clear(); 
      _allAccounts.addAll(accountModel.allAccounts); 
      _loadDefaultAccount();

    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error API', e.toString().replaceAll('Exception: ', ''));
      _allAccounts.clear(); 
      selectedAccount.value = null; 
    } finally {
      isLoading.value = false;
    }
  }

  void resetAccountsState() {
    _allAccounts.clear(); 
    selectedAccount.value = null; 
  }

  void _loadDefaultAccount() {
    final defaultLogin = box.read<String?>(_defaultAccountKey);
    
    // Prioritas 1: Akun dari local storage
    if (defaultLogin != null) {
      final storedAccount = _allAccounts.firstWhereOrNull((acc) => acc.login == defaultLogin);
      if (storedAccount != null) {
        selectedAccount.value = storedAccount;
        return;
      }
    }
    
    // Prioritas 2: Aturan default (Demo index 0 atau Real index 0)
    if (_allAccounts.isNotEmpty) {
      final demoAccount = _allAccounts.firstWhereOrNull((acc) => acc.type == 'demo');
      selectedAccount.value = demoAccount ?? _allAccounts.first;
    } else {
      selectedAccount.value = null;
    }
  }

  void selectAccount(AccountDetailModel account) {
    selectedAccount.value = account;
    if (account.login != null) {
      box.write(_defaultAccountKey, account.login!);
      AppSnackbar.success('Akun ${account.login} dipilih sebagai akun default.');
    }
  }

  bool isSelected(AccountDetailModel account) {
    return selectedAccount.value?.login == account.login;
  }

  void clearDefaultAccount() {
    box.remove(_defaultAccountKey);
    selectedAccount.value = null;
    // Get.snackbar('Sesi berakhir', 'Akun default telah dihapus dari penyimpanan lokal.', snackPosition: SnackPosition.BOTTOM);
  }
}