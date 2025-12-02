import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/views/beranda/news_detail.dart';

class ForexNews extends StatefulWidget {
  const ForexNews({super.key});

  @override
  State<ForexNews> createState() => _ForexNewsState();
}

class _ForexNewsState extends State<ForexNews> {
  double itemHeight = 100.0;
  double maxVisibleItems = 3;
  DateTime now = DateTime.now();
  UtilitiesController utilitiesController = Get.put(UtilitiesController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      utilitiesController.getNewsList().then((result){
        if(!result){}
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Global Forex News", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(utilitiesController.newsModel.value?.response.length ?? 0, (index) {
                    if(utilitiesController.newsModel.value?.response[index].type == "News"){
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: (){
                          Get.to(() => NewsDetail(idNews: utilitiesController.newsModel.value?.response[index].id));
                        },
                        child: Container(
                          width: size.width / 1.18,
                          height: size.width / 2.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                              image: utilitiesController.newsModel.value?.response[index].picture != null ? DecorationImage(image: NetworkImage(utilitiesController.newsModel.value!.response[index].picture!), fit: BoxFit.cover) : DecorationImage(image: AssetImage('assets/images/ic_launcher.png'), fit: BoxFit.cover)
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: size.width / 1.18,
                                height: size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.black26,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(child: Obx(() => Text(utilitiesController.newsModel.value?.response[index].title ?? "Berita ke ${index + 1}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis))),
                                    Flexible(child: Obx(() => Text("Published: ${DateFormat('EEEE, dd MMMM yyyy').add_jms().format(DateTime.parse(utilitiesController.newsModel.value!.response[index].tanggal!))}", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text("Fundamentals & Technical Analysis", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SingleChildScrollView(
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(utilitiesController.newsModel.value?.response.length ?? 0, (index) {
                    if(utilitiesController.newsModel.value?.response[index].type != "News"){
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: (){
                          Get.to(() => NewsDetail(idNews: utilitiesController.newsModel.value?.response[index].id));
                        },
                        child: Container(
                          width: size.width / 1.18,
                          height: size.width / 2.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            image: utilitiesController.newsModel.value?.response[index].picture != null ? DecorationImage(image: NetworkImage(utilitiesController.newsModel.value!.response[index].picture!), fit: BoxFit.cover) : DecorationImage(image: AssetImage('assets/images/ic_launcher.png'), fit: BoxFit.cover)
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: size.width / 1.18,
                                height: size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.black26,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(child: Obx(() => Text(utilitiesController.newsModel.value?.response[index].title ?? "Berita ke ${index + 1}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis))),
                                    Flexible(child: Obx(() => Text("Published: ${DateFormat('EEEE, dd MMMM yyyy').add_jms().format(DateTime.parse(utilitiesController.newsModel.value!.response[index].tanggal!))}", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ListView.builder(
//   itemCount: 8,
//   shrinkWrap: true,
//   itemBuilder: (context, index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Berita ke ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
//           SizedBox(height: 4),
//           Text("Deskripsi Berita ke ${index + 1}"),
//           SizedBox(height: 4),
//           Text("Published: ${DateFormat('MMMM, dd yyyy').format(now)}", style: TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   },
// )