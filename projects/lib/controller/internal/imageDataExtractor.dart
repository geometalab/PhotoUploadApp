import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/model/informationCollector.dart';

class ImageDataExtractor {
  InformationCollector collector = InformationCollector();

  Future<List<Map>> futureCollector() async {
    // TODO check if metadata tags are same on other devices
    // Returns an empty list when something goes wrong
    List<Map> maps = List.empty(growable: true);
    try {
      for (XFile image in collector.images) {
        Map<String, dynamic> infoMap = new Map();
        infoMap['image'] = Image.file(File(image.path),
            scale: 0.5, filterQuality: FilterQuality.medium, fit: BoxFit.cover);
        final imageBytes = await image.readAsBytes();
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
        infoMap['fileName'] = File(image.name).toString().substring(6);

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

        maps.add(infoMap);
      }
      if (!_assureSameFiletype(maps)) return List.empty();
      return maps;
    } catch (e) {
      // Somehow, thrown errors don't get printed to console, so I print them as well.
      print("Error while processing image: $e");
      throw (e);
    }
  }

  bool _assureSameFiletype(List<Map> maps) {
    // Makes sure all selected files have the same filetype
    String? fileType1;
    String? fileType2;
    for (Map map in maps) {
      fileType1 = map['fileType'];
      if (fileType2 != null) {
        if (fileType1 != fileType2) {
          // If different file types have been found
          return false;
        }
      }
      fileType2 = fileType1;
    }
    return true;
  }
}
