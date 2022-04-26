import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ActionHelper {
  launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
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
