import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget checklistStatement({bool? accepted}){
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text("Dengan mengisi kolom “YA” di bawah ini, saya menyatakan bahwa semua informasi dan semua dokumen yang saya lampirkan dalam APLIKASI PEMBUKAAN REKENING TRANSAKSI SECARA ELEKTRONIK ONLINE adalah benar dan tepat, Saya akan bertanggung jawab penuh apabila dikemudian hari terjadi sesuatu hal sehubungan dengan ketidakbenaran data yang saya berikan.", textAlign: TextAlign.justify, style: GoogleFonts.inter(color: Colors.black54)),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(value: accepted == true ? true : false, onChanged: (value) => accepted = !accepted!),
              Text("YA")
            ],
          ),
          Row(
            children: [
              Checkbox(value: accepted == false ? true : false, onChanged: (value) => accepted = !accepted!),
              Text("TIDAK")
            ],
          ),
        ],
      )
    ],
  );
}