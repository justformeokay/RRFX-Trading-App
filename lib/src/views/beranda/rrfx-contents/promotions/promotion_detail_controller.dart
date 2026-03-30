import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'promotion_detail_model.dart';

class PromotionDetailController extends GetxController {
  final slug = "".obs;

  PromotionDetailController(String s) {
    slug.value = s;
  }

  RxBool loading = true.obs;
  Rxn<PromotionDetailModel> detail = Rxn<PromotionDetailModel>();

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  final dio = Dio(BaseOptions(
    baseUrl: GlobalVariable.gatewayURL,
  ));

  Future<void> fetchDetail() async {
    try {
      loading.value = true;
      final res = await dio.get("/api/v1/contents/${slug.value}");
      detail.value = PromotionDetailModel.fromJson(res.data["data"]);
    } catch (e) {
      print("Error fetching detail: $e");
    } finally {
      loading.value = false;
    }
  }
}
