import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/validation_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class SubmitBar extends StatelessWidget {
  final ValidationController ctrl;
  const SubmitBar({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = ctrl.currentStep.value;
      final isSubmitting = ctrl.state.value == ValidationState.submitting;

      // Libellé et icône selon l'étape
      final String label;
      final IconData icon;
      final VoidCallback? action;

      if (isSubmitting) {
        label = 'Certification...';
        icon = Icons.hourglass_top;
        action = null;
      } else if (step == 1) {
        label = 'Certifier FNE';
        icon = Icons.verified_outlined;
        action = ctrl.submitAndSign;
      } else {
        label = 'Suivant';
        icon = Icons.arrow_forward;
        action = ctrl.nextStep;
      }

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.hPad(context),
          vertical: R.isTablet(context) ? 18 : 14,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: R.centered(
            context,
            child: Row(
              children: [
                if (step > 0) ...[
                  OutlinedButton(
                    onPressed: isSubmitting ? null : ctrl.previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      minimumSize: const Size(0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.radius(context)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: AppTheme.primary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Retour',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: R.fs(context, 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: R.btnH(context),
                    child: ElevatedButton.icon(
                      onPressed: action,
                      style: step == 1
                          ? ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                            )
                          : null,
                      icon: isSubmitting
                          ? SizedBox(
                              width: R.icon(context, 18),
                              height: R.icon(context, 18),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(icon, size: R.icon(context, 20)),
                      label: Text(
                        label,
                        style: TextStyle(
                          fontSize: R.fs(context, 15),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
