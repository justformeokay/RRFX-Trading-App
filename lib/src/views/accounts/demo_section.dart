import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/views/accounts/demo_account_information.dart';

import 'components/card_info_account.dart';

class DemoSection extends StatefulWidget {
  const DemoSection({super.key});

  @override
  State<DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<DemoSection> {
  TradingController tradingController = Get.put(TradingController());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: CustomColor.defaultColor,
      onRefresh: () async {},
      child: Obx(
        () {
          if(tradingController.tradingAccountModels.value?.response.demo?.isEmpty == true && tradingController.tradingAccountModels.value?.response.real?.isEmpty == true){
            return SizedBox(
              width: double.infinity,
              height: double.maxFinite,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CardInfoAccount(
                        isDemo: true,
                      )
                    ],
                  ),
                ),
              ),
            );
          }
          return ListView(
            children: List.generate(tradingController.tradingAccountModels.value?.response.demo?.length ?? 0, (i){
              var result = tradingController.tradingAccountModels.value?.response.demo?[i];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: (){
                    if(result != null){
                      Get.to(() => DemoAccountInformation(loginID: result.login));
                    }
                  },
                  splashColor: CustomColor.secondaryColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: CustomColor.secondaryColor, width: 0.5),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  title: Text("Account ID : ${result?.login ?? "-"}", style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: CustomColor.secondaryColor)),
                  subtitle: Text(result?.balance == null ? "\$0" : "Balance : \$${tradingController.tradingAccountModels.value!.response.demo![i].balance!.split('.').first}", style: GoogleFonts.inter(fontSize: 17, color: Theme.of(context).textTheme.titleLarge?.color)),
                  trailing: Icon(Icons.keyboard_arrow_right_sharp, size: 25, color: CustomColor.secondaryColor),
                  leading: CircleAvatar(
                    backgroundColor: CustomColor.secondaryColor,
                    child: Icon(Icons.candlestick_chart, color: Colors.white),
                  ),
                ),
              );
            }),
          );
        }
      ),
    );
  }
}
