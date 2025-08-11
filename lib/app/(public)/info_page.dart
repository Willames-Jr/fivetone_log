import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'willamesj11@gmail.com',
      query: 'subject=Contact%20from%20App',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {

    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.about),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '531 Log',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.appDescription,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Willames Jr.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.foundBug,
              style: const TextStyle(fontSize: 15, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _launchEmail,
              icon: const Icon(Icons.bug_report, color: Colors.red),
              label: Text(localizations.reportBugButton, style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.featureIdea,
              style: const TextStyle(fontSize: 15, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _launchEmail,
              icon: const Icon(Icons.email, color: Colors.blueAccent),
              label: Text(localizations.contactMe, style: const TextStyle(color: Colors.blueAccent)),
            ),
            const Spacer(),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
