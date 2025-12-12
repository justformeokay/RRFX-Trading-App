import 'package:get/get.dart';
import 'package:rrfx/src/controllers/trading.dart';

class TradingAccountController extends GetxController {
  RxBool isLoading = false.obs;
  RxList allAccountTrading = [].obs;
  RxList demoAccount = [].obs;
  RxList realAccount = [].obs;
  TradingController tradingController = Get.put(TradingController());

  @override
  void onInit() {
    getAndSetAccountTradingV2();
    super.onInit();
  }

  Future<void> getAndSetAccountTradingV2() async {
    await tradingController.getTradingAccount().then((resultTradingAccount) {
      if (!resultTradingAccount) {
        return;
      }
      demoAccount.value = tradingController.tradingAccountModels.value?.response.demo ?? [];
      realAccount.value = tradingController.tradingAccountModels.value?.response.real ?? [];
      allAccountTrading.clear();
      allAccountTrading..clear()..addAll(demoAccount)..addAll(realAccount);
    });
  }
}