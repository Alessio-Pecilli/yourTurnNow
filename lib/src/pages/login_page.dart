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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF6EC), Color(0xFFE0EAFD)], // panna -> blu soft
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black26,
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icona casa sopra
                          Icon(Icons.home_rounded, size: 64, color: scheme.primary),
                          const SizedBox(height: 20),

                          Text(
                            "Benvenuto in Coinquilini",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            "Organizza casa insieme: To-do condivisi, spese, e tanta serenita",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF1E40AF), // blu scuro (Tailwind "blue-900")
                                ),
                          ),
                          const SizedBox(height: 32),

                          // Bottone Google con ActivateOnKey
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }
}
