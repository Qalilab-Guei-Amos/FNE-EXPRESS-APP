import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/validation_controller.dart';
import 'validation_stepper.dart';
import 'articles_step_view.dart';
import 'info_step_view.dart';
import 'submit_bar.dart';

class ReviewForm extends StatelessWidget {
  final ValidationController ctrl;
  const ReviewForm({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── STEPPER HORIZONTAL ────────────────────────────────────
        ValidationStepper(ctrl: ctrl),

        Expanded(
          child: Obx(() {
            switch (ctrl.currentStep.value) {
              case 0:
                return InfoStepView(ctrl: ctrl);
              case 1:
                return ArticlesStepView(ctrl: ctrl);
              default:
                return InfoStepView(ctrl: ctrl);
            }
          }),
        ),

        // ── BARRE DE NAVIGATION ───────────────────────────────────
        SubmitBar(ctrl: ctrl),
      ],
    );
  }
}
