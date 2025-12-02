import 'dart:math';

String generateFixedId(String prefix) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random();

  // panjang yang harus diisi random (total 21)
  int randomLength = 21 - (prefix.length + 1); // +1 untuk "_"

  String randomStr = List.generate(randomLength, (_) {
    return chars[rand.nextInt(chars.length)];
  }).join();

  return "${prefix}_$randomStr";
}
