import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'fne_web_view_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/fne_record.dart';

class FneResultScreen extends StatelessWidget {
  final FneRecord record;
  const FneResultScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('FNE Générée',
            style: TextStyle(fontSize: R.fs(context, 18))),
        actions: [
          IconButton(
            icon: Icon(Icons.share,
                color: Colors.white, size: R.icon(context, 22)),
            onPressed: _share,
            tooltip: 'Partager',
          ),
          SizedBox(width: R.hPad(context) - 16),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: R.hPad(context),
          vertical: R.vPad(context),
        ),
        child: R.centered(context,
            child: isTablet
                ? _TabletLayout(record: record, onShare: _share)
                : _MobileLayout(record: record, onShare: _share)),
      ),
    );
  }

  void _share() {
    final lines = [
      'FNE Express — Facture Normalisée Électronique',
      'Client : ${record.clientName}',
      'Numéro FNE : ${record.fneNumber ?? 'N/A'}',
      'Date : ${AppFormatters.date(record.createdAt)}',
      'Total TTC : ${AppFormatters.currency(record.totalTTC)}',
      if (record.qrCode != null) ...[
        '',
        'Vérifier la facture : ${record.qrCode}',
      ],
    ];
    Share.share(lines.join('\n'), subject: 'FNE — ${record.clientName}');
  }
}

// ── Layout tablette : bannière + QR à gauche / détails à droite ───────────────
class _TabletLayout extends StatelessWidget {
  final FneRecord record;
  final VoidCallback onShare;
  const _TabletLayout({required this.record, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonne gauche : bannière succès + QR
            Expanded(
              child: Column(
                children: [
                  _SuccessBanner(record: record),
                  if (record.qrCode != null) ...[
                    SizedBox(height: R.gap(context)),
                    _QrCard(record: record),
                  ],
                ],
              ),
            ),
            SizedBox(width: R.gap(context) * 1.2),
            // Colonne droite : détails de la facture
            Expanded(
              child: _DetailsCard(record: record),
            ),
          ],
        ),
        SizedBox(height: R.gap(context) * 1.5),
        _ActionButtons(onShare: onShare),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Layout mobile : empilé verticalement ─────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final FneRecord record;
  final VoidCallback onShare;
  const _MobileLayout({required this.record, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SuccessBanner(record: record),
        SizedBox(height: R.gap(context)),
        if (record.qrCode != null) ...[
          _QrCard(record: record),
          SizedBox(height: R.gap(context)),
        ],
        _DetailsCard(record: record),
        SizedBox(height: R.gap(context) * 1.5),
        _ActionButtons(onShare: onShare),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Bannière succès ───────────────────────────────────────────────────────────
class _SuccessBanner extends StatelessWidget {
  final FneRecord record;
  const _SuccessBanner({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.isTablet(context) ? 28 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(R.radius(context)),
      ),
      child: Column(
        children: [
          Icon(Icons.verified,
              color: Colors.white, size: R.icon(context, 56)),
          SizedBox(height: R.isTablet(context) ? 12 : 8),
          Text(
            'Facture Normalisée',
            style: TextStyle(
              color: Colors.white,
              fontSize: R.fs(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (record.fneNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              record.fneNumber!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: R.fs(context, 13.5),
              ),
            ),
          ],
          SizedBox(height: R.isTablet(context) ? 16 : 12),
          Text(
            AppFormatters.currency(record.totalTTC),
            style: TextStyle(
              color: Colors.white,
              fontSize: R.fs(context, 28),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte vérification FNE ────────────────────────────────────────────────────
class _QrCard extends StatelessWidget {
  final FneRecord record;
  const _QrCard({required this.record});

  void _openVerification() {
    Get.to(() => FneWebViewScreen(url: record.qrCode!));
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.verified_outlined,
                      color: Colors.green.shade700,
                      size: R.icon(context, 24)),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Facture certifiée FNE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: R.fs(context, 14),
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vérifiable sur la plateforme FNE',
                        style: TextStyle(
                            fontSize: R.fs(context, 12),
                            color: AppTheme.textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: R.gap(context)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openVerification,
                icon: Icon(Icons.open_in_browser, size: R.icon(context, 18)),
                label: Text('Voir la facture certifiée',
                    style: TextStyle(fontSize: R.fs(context, 14))),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade400),
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carte détails facture ─────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final FneRecord record;
  const _DetailsCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.radius(context))),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails de la facture',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: R.fs(context, 15),
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: R.gap(context)),
            _DetailRow('Client', record.clientName),
            _DetailRow('Date', AppFormatters.date(record.createdAt)),
            if (record.invoice.invoiceNumber != null)
              _DetailRow('N° Original', record.invoice.invoiceNumber!),
            Divider(height: R.gap(context) * 1.5),
            // Liste des articles
            ...record.invoice.items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: R.gap(context) * 0.5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.designation,
                        style: TextStyle(
                            fontSize: R.fs(context, 13),
                            color: AppTheme.textDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.quantity.toStringAsFixed(0)} × ${AppFormatters.currency(item.unitPrice)}',
                      style: TextStyle(
                          fontSize: R.fs(context, 12),
                          color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: R.gap(context) * 1.5),
            _DetailRow('Total HT',
                AppFormatters.currency(record.invoice.totalHT)),
            _DetailRow(
                'TVA', AppFormatters.currency(record.invoice.totalTVA)),
            _DetailRow(
                'Total TTC', AppFormatters.currency(record.totalTTC),
                bold: true),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _DetailRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppTheme.textGrey, fontSize: R.fs(context, 13))),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: R.fs(context, 13),
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Boutons d'action ──────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final VoidCallback onShare;
  const _ActionButtons({required this.onShare});

  @override
  Widget build(BuildContext context) {
    final isTablet = R.isTablet(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: Icon(Icons.share, size: R.icon(context, 20)),
            label: Text('Partager',
                style: TextStyle(fontSize: R.fs(context, 15))),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              padding:
                  EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
            ),
          ),
        ),
        SizedBox(width: R.gap(context)),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              int count = 0;
              Get.until((_) => count++ >= 3);
            },
            icon: Icon(Icons.home, size: R.icon(context, 20)),
            label: Text('Accueil',
                style: TextStyle(fontSize: R.fs(context, 15))),
            style: ElevatedButton.styleFrom(
              padding:
                  EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
            ),
          ),
        ),
      ],
    );
  }
}
