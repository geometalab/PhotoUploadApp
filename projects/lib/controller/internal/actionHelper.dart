import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionHelper {
  launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  openEmail(List<String> recipients) async {
    final Email email = Email(
      recipients: recipients,
    );
    // TODO doesn't work on some phones, throwing "PlatformException(not_available, No email clients found!)"
    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      throw ("No email client has been found.");
    }
  }
}
