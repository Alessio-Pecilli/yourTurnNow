import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_controller_web_google.dart';
import '../widgets/google_logo.dart';
import '../widgets/activate_on_key.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // --- SFONDO BASE ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFDF6EC), // panna
                  Color(0xFFE0EAFD), // blu soft
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // --- CERCHI AGGIUNTIVI (sfumati, statici, morbidi) ---
          Positioned(top: -80, left: -40, child: _buildCircle(const Color(0xFF2563EB), 200, 0.15)),
          Positioned(bottom: -100, right: -80, child: _buildCircle(const Color(0xFF1E3A8A), 260, 0.12)),
          Positioned(top: 300, right: -50, child: _buildCircle(const Color(0xFF60A5FA), 160, 0.1)),

          // nuovi cerchi extra per maggiore profondità
          Positioned(top: 150, left: -70, child: _buildCircle(const Color(0xFF3B82F6), 120, 0.08)),
          Positioned(bottom: 200, left: 50, child: _buildCircle(const Color(0xFF93C5FD), 140, 0.08)),
          Positioned(bottom: 100, right: 150, child: _buildCircle(const Color(0xFF2563EB), 100, 0.07)),
          // verso il centro alto-sinistra
          Positioned(top: 220, left: 120,
              child: _buildCircle(const Color(0xFF2563EB), 90, 0.07)),

          // dietro il form, molto sfumato
          Positioned(top: 300, right: 240,
              child: _buildCircle(const Color(0xFF60A5FA), 120, 0.06)),

          // un tocco piccolo in basso al centro
          Positioned(bottom: 140, left: 200,
              child: _buildCircle(const Color(0xFF93C5FD), 80, 0.05)),

          Positioned(bottom: 640, left: 400,
              child: _buildCircle(const Color(0xFF93C5FD), 80, 0.05)),
          // --- CERCHI CENTRALI (aggiuntivi) ---

// centro-sinistra, grande e molto sfumato
Positioned(
  top: 240,
  left: 180,
  child: _buildCircle(const Color(0xFF60A5FA), 180, 0.08),
),

// centro-destra, leggermente più piccolo
Positioned(
  top: 480,
  right: 760,
  child: _buildCircle(const Color(0xFF2563EB), 140, 0.07),
),

// piccolo accento sopra la card
Positioned(
  top: 160,
  right: 720,
  child: _buildCircle(const Color(0xFF93C5FD), 80, 0.06),
),

// piccolo accento sotto la card
Positioned(
  top: 280,
  left: 600,
  child: _buildCircle(const Color(0xFF2563EB), 90, 0.05),
),

          // --- CONTENUTO ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Card(
                          elevation: 8,
                          shadowColor: Colors.black26,
                          color: Colors.white.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.home_rounded, size: 64, color: scheme.primary),
                                const SizedBox(height: 20),
                                Text(
                                  "Benvenuto in Coinquilini",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Organizza casa insieme: To-do condivisi, spese, e tanta serenità.",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: const Color(0xFF1E40AF),
                                      ),
                                ),
                                const SizedBox(height: 32),
                                ActivateOnKey(
                                  onActivate: () => ref.read(authControllerProvider).login(),
                                  child: FilledButton.tonalIcon(
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 56),
                                      backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                                      foregroundColor: const Color(0xFF2563EB),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const GoogleLogo(),
                                    onPressed: () => ref.read(authControllerProvider).login(),
                                    label: const Text("Continua con Google"),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Accedendo confermi di voler sincronizzare i dati solo ai fini dell’app.",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF1E40AF),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity * 0.5),
            blurRadius: 50,
            spreadRadius: 25,
          ),
        ],
      ),
    );
  }
}
