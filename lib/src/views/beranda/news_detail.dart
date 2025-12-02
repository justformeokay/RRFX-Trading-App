import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

class NewsDetail extends StatefulWidget {
  const NewsDetail({super.key, this.idNews});
  final String? idNews;

  @override
  State<NewsDetail> createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  UtilitiesController utilitiesController = Get.find();
  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? "";
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      utilitiesController.getNewsDetail(newsID: widget.idNews).then((result) {
        if (!result) {
          debugPrint(utilitiesController.responseMessage.value);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: "",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            /// Judul berita
            Obx(
              () => Text(
                utilitiesController.newsDetail.value?.response.title ??
                    "News Title",
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: textTheme.titleLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 10),

            /// Tanggal publish
            Obx(
              () => utilitiesController.newsDetail.value?.response.tanggal ==
                      null
                  ? const SizedBox()
                  : Text(
                      DateFormat("EEEE, dd MMMM yyyy").format(
                        DateTime.parse(
                          utilitiesController.newsDetail.value!.response.tanggal!,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: textTheme.bodySmall?.color,
                      ),
                    ),
            ),
            const SizedBox(height: 10),

            /// Author
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              leading: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo-rrfx-3.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              title: Text(
                "Published by",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: textTheme.bodySmall?.color,
                ),
              ),
              subtitle: Obx(
                () => Text(
                  utilitiesController.newsDetail.value?.response.author ??
                      "Admin RRFX",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Gambar berita
            Obx(
              () => Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: utilitiesController.newsDetail.value?.response.picture != null
                      ? NetworkImage(utilitiesController.newsDetail.value!.response.picture!)
                      : const AssetImage('assets/images/promotion.jpg') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Obx(() => Text(utilitiesController.newsDetail.value?.response.message ?? "", textAlign: TextAlign.justify,)),

            Obx(
              () => Html(
                data: utilitiesController.newsDetail.value?.response.message != null ? parseHtmlString(utilitiesController.newsDetail.value!.response.message!) : "",
                style: {
                  // hapus background putih default <body>
                  "body": Style(
                    backgroundColor: Colors.transparent,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: FontSize(14),
                  ),
                  // override untuk <span> dan <p>
                  "span": Style(
                    backgroundColor: Colors.transparent,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  "p": Style(
                    backgroundColor: Colors.transparent,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    margin: Margins.symmetric(vertical: 0),
                  ),
                  "h3": Style(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize(18),
                  ),
                  "h1": Style(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize(18),
                  ),
                  "h2": Style(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize(18),
                  ),
                  "a": Style(
                    color: Colors.blueAccent,
                    textDecoration: TextDecoration.underline,
                  ),
                },
                onLinkTap: (url, attributes, element) {
                  if (url != null) {
                    launchUrl(Uri.parse(url));
                  }
                },
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
