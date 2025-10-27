import 'dart:html' as html;
import 'package:camera/camera.dart';

void downloadVideoWeb(XFile file, String name, String formattedDate) async {
  final blob = html.Blob([await file.readAsBytes()]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', '${name}_${formattedDate}.webm')
    ..click();
  html.Url.revokeObjectUrl(url);
}
