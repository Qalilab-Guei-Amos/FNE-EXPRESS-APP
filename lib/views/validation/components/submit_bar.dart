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
                    child: Icon(Icons.arrow_back, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: R.btnH(context),
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : (step == 0 ? ctrl.nextStep : ctrl.submitAndSign),
                      icon: isSubmitting
                          ? SizedBox(
                              width: R.icon(context, 20),
                              height: R.icon(context, 20),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              step == 0 ? Icons.arrow_forward : Icons.verified,
                              size: R.icon(context, 20),
                            ),
                      label: Text(
                        isSubmitting
                            ? 'Certification...'
                            : (step == 0 ? 'Suivant' : 'Certifier la FNE'),
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
