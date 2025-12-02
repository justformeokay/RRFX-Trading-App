import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/icon_container.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/controllers/trading.dart';

class CardInfoAccount extends StatefulWidget {
  const CardInfoAccount({super.key, required this.isDemo, this.onTapCreateReal});
  final bool isDemo;
  final VoidCallback? onTapCreateReal;

  @override
  State<CardInfoAccount> createState() => _CardInfoAccountState();
}

class _CardInfoAccountState extends State<CardInfoAccount> {
  TradingController tradingController = Get.put(TradingController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconContainer.defaultIconContainer(
            size: size,
            icon: Clarity.lightbulb_solid,
          ),
          const SizedBox(height: 32.0),
          Text(widget.isDemo ? LanguageGlobalVar.NOT_HAVE_ACCOUNT_DEMO.tr : LanguageGlobalVar.NOT_HAVE_ACCOUNT_REAL.tr, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
          const SizedBox(height: 8.0),
          Text(widget.isDemo ? LanguageGlobalVar.NOT_HAVE_ACCOUNT_DEMO_TEXT.tr : LanguageGlobalVar.NOT_HAVE_ACCOUNT_REAL_TEXT.tr, style: GoogleFonts.inter(fontSize: 14.0, color: CustomColor.textThemeDarkSoftColor), textAlign: TextAlign.center),
          const SizedBox(height: 32.0),
          Obx(
            () => ElevatedButton(
              onPressed: tradingController.isLoading.value ? null : (){
                if(widget.isDemo){
                  tradingController.createDemo().then((result){
                    if (mounted) {
                      CustomScaffoldMessanger.showAppSnackBar(context, message: tradingController.responseMessage.value, type: result ? SnackBarType.success : SnackBarType.error, action: SnackBarAction(label: "Okay", onPressed: (){}));
                    }
                  });
                }else{
                  if(widget.onTapCreateReal != null){
                    widget.onTapCreateReal!();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                overlayColor: CustomColor.backgroundLightColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: CustomColor.secondaryColor,
              ),
              child: Text(widget.isDemo ? "Buka Demo Account" : "Buka Real Account", style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold
              ))
            ),
          ),
        ],
      ),
    );
  }
}