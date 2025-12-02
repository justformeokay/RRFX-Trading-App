import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/views/beranda/news_detail.dart';

class PlantCard {
  final String id;
  final String author;
  final String title;
  final String description;
  final String date;
  final String imageUrl;

  PlantCard({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
  });
}

class CardGridPage extends StatefulWidget {
  const CardGridPage({super.key, this.title});
  final String? title;

  @override
  State<CardGridPage> createState() => _CardGridPageState();
}

class _CardGridPageState extends State<CardGridPage> {
  UtilitiesController utilitiesController = Get.find();
  final RxList<PlantCard> cards = <PlantCard>[].obs;
  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? "";
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      utilitiesController.getNewsList().then((resultNews){
        if(!resultNews){
          // CustomScaffoldMessanger.showAppSnackBar(context, message: utilitiesController.responseMessage.value, type: SnackBarType.error);
          return;
        }
        if (utilitiesController.newsModel.value?.response.isNotEmpty == true) {
          final typeFilter = widget.title == "News" ? "News" : "Market Analysis";
          cards.addAll(utilitiesController.newsModel.value!.response.where((item) => item.type == typeFilter).map((item) => PlantCard(
              id: item.id ?? '',
              author: item.author ?? '',
              title: item.title ?? '',
              description: item.message ?? '',
              date: item.tanggal ?? '',
              imageUrl: item.picture ?? '',
            ),
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(title: "Semua ${widget.title ?? "News"}", autoImplyLeading: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(
          () {
            if(cards.isEmpty){
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesome.newspaper, size: 45.0),
                    const SizedBox(height: 8.0),
                    Text(widget.title ?? "News", style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w700)),
                    Text("${widget.title ?? "News"} belum tersedia, mohon tunggu update terbaru dari admin.", style: GoogleFonts.inter(fontSize: 12.0, fontWeight: FontWeight.w400, color: Get.textTheme.bodySmall?.color), textAlign: TextAlign.center),
                  ],
                ),
              );
            }
            return GridView.builder(
              itemCount: cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // jumlah kolom
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65, // biar proporsional kayak contoh
              ),
              itemBuilder: (context, index) {
                final card = cards[index];
                return Bounce(
                  onTap: (){
                    Get.to(() => NewsDetail(idNews: card.id));
                  },
                  child: Card(
                    elevation: 3,
                    semanticContainer: true,
                    surfaceTintColor: Colors.white,
                    shadowColor: Theme.of(context).shadowColor,
                    borderOnForeground: true,
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar
                        Expanded(
                          child: Image.network(
                            card.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Konten teks
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.author,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                card.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                parseHtmlString(card.description),
                                style: const TextStyle(fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                card.date,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        ),
      ),
    );
  }
}
