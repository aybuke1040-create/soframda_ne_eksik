import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<XFile?> compressImage(String path) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    path,
    "${path}_compressed.jpg",
    quality: 70,
  );

  return result;
}
