import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProfileActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool primary;
  final bool isDanger;

  const ProfileActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.primary = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDanger 
        ? Colors.redAccent.shade400 
        : (primary ? AppTheme.primary : Colors.white);
    
    final textColor = primary || isDanger ? Colors.white : AppTheme.primary;
    
    final side = primary || isDanger 
        ? BorderSide.none 
        : BorderSide(color: AppTheme.primary.withValues(alpha: 0.3), width: 1.5);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: isLoading 
            ? const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : (icon != null ? Icon(icon, size: 22) : const SizedBox.shrink()),
        label: Text(
          label, 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          side: side,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
