import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:projects/model/informationCollector.dart';

class ImageDataExtractor {
  InformationCollector collector = InformationCollector();

  Future<Map> futureCollector() async {
    // TODO check if metadata tags are same on other devices
    try {
      Map<String, dynamic> infoMap = new Map();
      infoMap['image'] = Image.file(File(collector.image!.path), height: 100);
      final imageBytes = await collector.image!.readAsBytes();
      final decodedImage = await decodeImageFromList(imageBytes);
      final exifData = await readExifFromBytes(imageBytes);

      if (exifData.containsKey('Image DateTime')) {
        infoMap['dateTime'] = exifData['Image DateTime']!.printable;
      }
      if (exifData.containsKey('GPS GPSLatitudeRef') &&
          exifData.containsKey('GPS GPSLatitude') &&
          exifData.containsKey('GPS GPSLongitudeRef') &&
          exifData.containsKey('GPS GPSLongitude')) {
        infoMap['gpsLatRef'] = exifData['GPS GPSLatitudeRef']!.printable;
        infoMap['gpsLat'] = exifData['GPS GPSLatitude']!.printable;

        infoMap['gpsLngRef'] = exifData['GPS GPSLongitudeRef']!.printable;
        infoMap['gpsLng'] = exifData['GPS GPSLongitude']!.printable;
      }
      collector.date =
          DateTime.parse(infoMap['dateTime'].toString().replaceAll(":", ""));

      infoMap['width'] = decodedImage.width;
      infoMap['height'] = decodedImage.height;
      infoMap['fileName'] = File(collector.image!.name).toString().substring(6);

      // If prefillContent is defined and title is empty, we can auto generate a file name
      if (collector.preFillContent != null &&
          (collector.fileName == null || collector.fileName!.isEmpty)) {
        if (infoMap.containsKey("dateTime") &&
            collector.preFillContent!.isNotEmpty) {
          collector.fileName =
              "${collector.preFillContent!.replaceAll(" ", "_")}_${collector.date.year}-${collector.date.month}-${collector.date.day}";
        }
      }

      String fileName = infoMap['fileName'].toString().split(".")[1];
      infoMap['fileType'] = "." + fileName.substring(0, fileName.length - 1);
      collector.fileType = infoMap['fileType'];
      return infoMap;
    } catch (e) {
      // Somehow, thrown errors don't get printed to console, so I print them as well.
      print("Error while processing image: $e");
      throw ("Error while processing image: $e");
    }
  }
}
