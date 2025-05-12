import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import 'base/button_base.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(S.current.about_app),centerTitle: true,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.app_name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.current.about_app_subtitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            _buildModeCard(
              context,
              title: S.current.writer_mode_title,
              description: S.current.writer_mode_description,
              icon: Icons.edit,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 16),

            _buildModeCard(
              context,
              title: S.current.reader_mode_title,
              description: S.current.reader_mode_description,
              icon: Icons.menu_book,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 24),

            Text(
              S.current.about_app_conclusion,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32,),
            ButtonBase(text: S.of(context).support_the_project, onPressed: () { launchUrl(Uri.parse('https://boosty.to/doshikfromych')); },),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required Color color,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...description.split('\n').map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line.startsWith('- ') ? '• ${line.substring(2)}' : line,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )),
          ],
        ),
      ),
    );
  }
}