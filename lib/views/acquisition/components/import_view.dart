import 'package:flutter/material.dart';
import '../../../controllers/acquisition_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import 'option_button.dart';

class ImportView extends StatelessWidget {
  final AcquisitionController ctrl;
  const ImportView({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: R.hPad(context),
          vertical: R.vPad(context),
        ),
        child: R.centered(context,
            child: Column(
              children: [
                SizedBox(height: isTablet ? 40 : 24),
                Container(
                  width: R.icon(context, 110),
                  height: R.icon(context, 110),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.upload_file,
                      size: R.icon(context, 54), color: AppTheme.primary),
                ),
                SizedBox(height: isTablet ? 28 : 20),
                Text(
                  'Importer votre facture',
                  style: TextStyle(
                    fontSize: R.fs(context, 22),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Choisissez une méthode pour importer\nvotre document de vente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.fs(context, 15),
                    color: AppTheme.textGrey.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isTablet ? 48 : 40),
                if (isTablet) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OptionButton(
                          icon: Icons.camera_alt,
                          label: 'Prendre une photo',
                          subtitle: 'Photographier la facture papier',
                          color: AppTheme.primary,
                          onTap: ctrl.pickFromCamera,
                        ),
                      ),
                      SizedBox(width: R.gap(context)),
                      Expanded(
                        child: OptionButton(
                          icon: Icons.photo_library,
                          label: 'Depuis la galerie',
                          subtitle: 'Sélectionner une image existante',
                          color: const Color(0xFF2E7D9E),
                          onTap: ctrl.pickFromGallery,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.gap(context)),
                  OptionButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Importer un PDF',
                    subtitle: 'Fichier PDF ou image depuis l\'appareil',
                    color: const Color(0xFFB23535),
                    onTap: ctrl.pickDocument,
                  ),
                ] else ...[
                  OptionButton(
                    icon: Icons.camera_alt,
                    label: 'Prendre une photo',
                    subtitle: 'Photographier la facture papier',
                    color: AppTheme.primary,
                    onTap: ctrl.pickFromCamera,
                  ),
                  SizedBox(height: R.gap(context)),
                  OptionButton(
                    icon: Icons.photo_library,
                    label: 'Depuis la galerie',
                    subtitle: 'Sélectionner une image existante',
                    color: const Color(0xFF2E7D9E),
                    onTap: ctrl.pickFromGallery,
                  ),
                  SizedBox(height: R.gap(context)),
                  OptionButton(
                    icon: Icons.picture_as_pdf,
                    label: 'Importer un PDF',
                    subtitle: 'Fichier PDF ou image depuis l\'appareil',
                    color: const Color(0xFFB23535),
                    onTap: ctrl.pickDocument,
                  ),
                ],
                SizedBox(height: isTablet ? 48 : 32),
              ],
            )),
      ),
    );
  }
}
