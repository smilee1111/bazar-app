import 'package:bazar/app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:bazar/features/notification/presentation/widgets/notification_bell.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.14),
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            'assets/images/bazarlogo.png',
            height: 40,
            width: 40,
          ),
        ),
      ),
      title: const Text('Bazar'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: const NotificationBell(),
        ),
      ],
    );
  }
}
