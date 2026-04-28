import 'package:flutter/material.dart';

class WeatherErrorState extends StatelessWidget {
  const WeatherErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String message;
  final VoidCallback onRetry;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 72,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to Load Weather',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onSecondaryAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              child: Text(secondaryActionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
