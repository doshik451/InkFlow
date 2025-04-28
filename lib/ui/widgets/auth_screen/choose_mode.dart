import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/mode/app_mode_cubit.dart';
import '../../../generated/l10n.dart';
import '../../../modes/app_mode.dart';
import '../../../utils/routes.dart';

class ChooseMode extends StatelessWidget {
  const ChooseMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).choose_mode),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ModeSelectionCard(
              icon: Icons.edit,
              title: S.of(context).writer_mode_title,
              description: S.of(context).writer_mode_description,
              onTap: () => _selectMode(context, AppMode.writerMode),
            ),

            const SizedBox(height: 20),

            _ModeSelectionCard(
              icon: Icons.menu_book,
              title: S.of(context).reader_mode_title,
              description: S.of(context).reader_mode_description,
              onTap: () => _selectMode(context, AppMode.readerMode),
            ),
          ],
        ),
      ),
    );
  }

  void _selectMode(BuildContext context, AppMode mode) {
    context.read<AppModeCubit>().switchMode(mode);

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.getMainRoute(context),
      (route) => false,
    );
  }
}

class _ModeSelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeSelectionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 50, color: Theme.of(context).colorScheme.tertiary),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}