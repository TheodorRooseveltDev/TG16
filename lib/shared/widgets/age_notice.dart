import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class AgeNotice extends StatelessWidget {
  const AgeNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 18+ Icon
          Image.asset(
            'assets/images/18-plus.png',
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 12),
          // Notice text
          Expanded(
            child: Text(
              'These games are intended for an adult audience only (18+). These games do not offer any real money wagering or a chance to win real money prizes.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
