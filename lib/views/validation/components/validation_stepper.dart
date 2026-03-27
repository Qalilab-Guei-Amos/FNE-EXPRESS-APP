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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      child: Obx(() {
        final step = ctrl.currentStep.value;
        return Row(
          children: [
            _StepDot(index: 1, label: 'Client',
                isActive: step == 0,
                isCompleted: step > 0),
            _Connector(filled: step > 0),
            _StepDot(index: 2, label: 'Produits',
                isActive: step == 1,
                isCompleted: false),
          ],
        );
      }),
    );
  }
}

class _Connector extends StatelessWidget {
  final bool filled;
  const _Connector({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: filled ? AppTheme.primary : AppTheme.divider,
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepDot({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.primary
                : (isActive ? AppTheme.primary : Colors.grey.shade100),
            border: Border.all(
              color: (isActive || isCompleted) ? AppTheme.primary : AppTheme.divider,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppTheme.textGrey,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: (isActive || isCompleted) ? FontWeight.bold : FontWeight.normal,
            color: (isActive || isCompleted) ? AppTheme.textDark : AppTheme.textGrey,
          ),
        ),
      ],
    );
  }
}
