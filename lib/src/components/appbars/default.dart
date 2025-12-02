import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';

class CustomAppBar {
  static AppBar defaultAppBar({String? title, List<Widget>? actions, bool? autoImplyLeading, PreferredSize? bottom}){
    return AppBar(
      title: Text(title ?? ""),
      surfaceTintColor: CustomColor.backgroundIcon,
      actions: actions,
      forceMaterialTransparency: true,
      leading: autoImplyLeading == true ? IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: CustomColor.secondaryColor)) : const SizedBox(),
      bottom: bottom,
    );
  }
}