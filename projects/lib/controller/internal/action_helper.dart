import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../../config.dart';

class ActionHelper {
  static const wikimediaRest = Config.wikimediaRest;

  openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      if (Platform.isIOS && uri.path.contains("oauth2/authorize")) {
        // if authorisation flow on ios, open in app-internal browser for smoother user experience
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
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

  Future<String> getSentryDns() async {
    await dotenv.load(fileName: ".env");
    String? dns =
        dotenv.env['SENTRY_DNS']; // Get the dns from the local .env file
    if (dns == null) {
      throw ("Sentry DNS is not provided in .env");
    }
    return dns;
  }

  Future<String> getClientSecret() async {
    await dotenv.load(fileName: ".env");
    String? clientSecret = dotenv
        .env['SECRET_TOKEN']; // Get the secret token from the local .env file
    if (clientSecret == null) {
      throw ("Secret token is not provided in .env");
    }
    return clientSecret;
  }
}
