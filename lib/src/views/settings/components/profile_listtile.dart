import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

Widget profileListTile(BuildContext context, {String? name, String? email, String? urlPhoto, Function()? onPressedPhoto, bool? imageOnline, Function()? onTapImage, bool? changedImage, Function()? onPressedEdit}){
  return Row(
    children: [
      GestureDetector(
        onTap: onTapImage,
        child: Stack(
          children: [
            GestureDetector(
              onTap: onPressedPhoto,
              child: Hero(
                tag: 'profileImage',
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.transparent,
                  backgroundImage: changedImage == true && urlPhoto != null && urlPhoto.isNotEmpty
                      ? FileImage(File(urlPhoto))
                      : (imageOnline == true && urlPhoto != null && urlPhoto.isNotEmpty)
                          ? NetworkImage(urlPhoto) // di sini urlPhoto sudah mengandung ?ts=...
                          : const AssetImage('assets/images/logo-rrfx.png')
                              as ImageProvider,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColor.secondaryBackground.withOpacity(0.3)
                ),
                child: Icon(CupertinoIcons.camera_fill, color: Colors.white60, size: 19)
              ),
            )
          ],
        ),
      ),
      const SizedBox(width: 20),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name ?? "Name", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color, fontSize: 18), maxLines: 1),
          Text(email ?? "email@email.com", style: GoogleFonts.inter(color: CustomColor.textThemeLightSoftColor, fontSize: 14), maxLines: 1),
          const SizedBox(height: 5),
          SizedBox(
            height: 20,
            child: ElevatedButton(
              onPressed: onPressedEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.secondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3)
              ),
              child: Text("Edit Profile", style: GoogleFonts.inter(fontSize: 10, color: Colors.black))
            ),
          )
        ],
      )
    ],
  );
}