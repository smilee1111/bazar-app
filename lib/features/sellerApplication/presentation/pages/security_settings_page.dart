import 'package:bazar/app/theme/textstyle.dart';
import 'package:flutter/material.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(
            'Security Controls',
            style: AppTextStyle.inputBox.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These controls improve account protection. Some options are reserved for a future backend update.',
            style: AppTextStyle.minimalTexts.copyWith(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 14),
          const _SecurityOptionTile(
            title: 'Two-factor authentication',
            subtitle: 'Add extra verification during login',
            icon: Icons.verified_user_outlined,
          ),
          const SizedBox(height: 10),
          const _SecurityOptionTile(
            title: 'Biometric lock',
            subtitle: 'Protect app access with fingerprint or face ID',
            icon: Icons.fingerprint_rounded,
          ),
          const SizedBox(height: 10),
          const _SecurityOptionTile(
            title: 'Login alerts',
            subtitle: 'Get notified for unusual sign-in activity',
            icon: Icons.notifications_active_outlined,
          ),
        ],
      ),
    );
  }
}

class _SecurityOptionTile extends StatelessWidget {
  const _SecurityOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.inputBox.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyle.minimalTexts.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                  ),
                ),
              ],
            ),
          ),
          const Switch(value: false, onChanged: null),
        ],
      ),
    );
  }
}
