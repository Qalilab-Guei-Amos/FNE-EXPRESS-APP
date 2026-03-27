import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/validation_controller.dart';
import '../../../core/theme/app_theme.dart';

class ValidationStepper extends StatelessWidget {
  final ValidationController ctrl;
  const ValidationStepper({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      child: Obx(() {
        final step = ctrl.currentStep.value;
        return Row(
          children: [
            _StepDot(label: 'Général', isActive: step >= 0, isCompleted: step > 0),
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: step > 0 ? AppTheme.primary : AppTheme.divider,
              ),
            ),
            _StepDot(label: 'Articles', isActive: step >= 1, isCompleted: step > 1),
          ],
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepDot({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.primary
                : (isActive ? Colors.white : Colors.grey.shade100),
            border: Border.all(
              color: isActive ? AppTheme.primary : AppTheme.divider,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Center(
                  child: Text(
                    label == 'Général' ? '1' : '2',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppTheme.primary : AppTheme.textGrey,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppTheme.textDark : AppTheme.textGrey,
          ),
        ),
      ],
    );
  }
}
