import 'package:dio/dio.dart';
import 'package:get/get.dart';
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
    baseUrl: "https://gateway.rrfx.co.id",
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
