import 'package:get/get.dart';
import 'package:dio/dio.dart';

class ArticlesController extends GetxController {
  final Dio dio = Dio();

  RxList articles = [].obs;
  RxBool loading = false.obs;
  RxInt page = 1.obs;
  RxBool loadMore = true.obs;

  Future<void> fetchArticles({bool refresh = false}) async {
    if (refresh) {
      page.value = 1;
      articles.clear();
      loadMore.value = true;
    }

    if (!loadMore.value) return;

    loading.value = true;

    final url = "https://gateway.rrfx.co.id/api/v1/contents/category/all?type=ARTICLE&limit=7&page=${page.value}";

    try {
      final res = await dio.get(url);

      final list = res.data["data"]["list"] as List;
      final options = res.data["data"]["options"];

      articles.addAll(list);
      loadMore.value = options["is_load_more"] == true;

      if (loadMore.value) page++;

    } catch (e) {
      print("Error: $e");
    }

    loading.value = false;
  }

  @override
  void onInit() {
    fetchArticles();
    super.onInit();
  }
}
