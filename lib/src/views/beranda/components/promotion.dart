import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rrfx/src/components/containers/news_card.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/helpers/handlers/url_handler.dart';

class PromotionSection extends StatefulWidget {
  const PromotionSection({super.key});

  @override
  State<PromotionSection> createState() => _PromotionSectionState();
}

class _PromotionSectionState extends State<PromotionSection> {
  PageController pageControllerPromo = PageController();
  UtilitiesController utilitiesController = Get.put(UtilitiesController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      utilitiesController.getSlideImageHome().then((result){
        if(!result){
          debugPrint(utilitiesController.responseMessage.value);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(
      () => utilitiesController.isLoading.value ? const SizedBox() : Column(
        children: [
          SizedBox(
            width: size.width,
            height: size.width / 2,
            child: Obx(
              () => PageView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: utilitiesController.slideModel.value?.response.length ?? 0,
                pageSnapping: true,
                controller: pageControllerPromo,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: NewsCard.blurredNews(onPressed: (){
                    openInChrome(utilitiesController.slideModel.value?.response[index].link ?? 'https://rrfx.co.id');
                  }, imageURL: utilitiesController.slideModel.value?.response[index].picture),
                ),
              ),
            ),
          ),
          // Center(
          //   child: Obx(
          //     () => SmoothPageIndicator(
          //       controller: pageControllerPromo,
          //       count: utilitiesController.slideModel.value?.response.length ?? 0,
          //       effect: WormEffect(
          //         dotHeight: 5,
          //         dotWidth: 20,
          //         type: WormType.thinUnderground,
          //         activeDotColor: CustomColor.defaultColor,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
