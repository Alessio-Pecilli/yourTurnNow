// lib/widgets/help_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class HelpBanner extends StatelessWidget {
  const HelpBanner({super.key, required this.onClose, required this.shortcutInfo});
  final VoidCallback onClose;
  final String shortcutInfo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Guida rapida profilo utente',
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13.5, height: 1.25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Come funziona', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade900)),
                      const SizedBox(height: 4),
                      const Text('• Importo: positivo = accredito, negativo = addebito.'),
                      const Text('• Filtri: scegli una categoria e/o un intervallo di date.'),
                      const Text('• Aggiungi: usa il pulsante “Aggiungi” per inserire una nuova voce.'),
                      const SizedBox(height: 6),
                      Text(shortcutInfo, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Nascondi aiuto',
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
