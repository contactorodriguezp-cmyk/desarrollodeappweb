import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'comercial/comercial_home.dart';
import 'ingenieria/ing_shell.dart';

enum Perfil { comercial, ingenieria }

class IngresoScreen extends StatefulWidget {
  const IngresoScreen({super.key});

  @override
  State<IngresoScreen> createState() => _IngresoScreenState();
}

class _IngresoScreenState extends State<IngresoScreen> {
  Perfil perfil = Perfil.comercial;
  final email = TextEditingController(text: 'martina.lopez@empresa.com');
  final clave = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    email.dispose();
    clave.dispose();
    super.dispose();
  }

  void _cambiarPerfil(Perfil p) => setState(() {
        perfil = p;
        email.text = p == Perfil.comercial ? 'martina.lopez@empresa.com' : 'juan.perez@empresa.com';
      });

  void _ingresar() {
    if (email.text.trim().isEmpty || clave.text.isEmpty) {
      avisar(context, 'Completá tu email y tu contraseña.');
      return;
    }
    final nav = Navigator.of(context);
    if (perfil == Perfil.comercial) {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => const ComercialHome()));
    } else {
      ingTab.value = 0;
      nav.pushReplacement(MaterialPageRoute(
        settings: const RouteSettings(name: IngenieriaShell.routeName),
        builder: (_) => const IngenieriaShell(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 32),
                const Align(alignment: Alignment.centerLeft, child: Logo()),
                const SizedBox(height: 40),
                const Text('Ingresá a tu cuenta', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Registrá visitas técnicas y respondé las solicitudes de Ingeniería desde cualquier dispositivo.',
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                const Text('Perfil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                SegmentedButton<Perfil>(
                  segments: const [
                    ButtonSegment(value: Perfil.comercial, label: Text('Comercial'), icon: Icon(Icons.work_outline)),
                    ButtonSegment(value: Perfil.ingenieria, label: Text('Ingeniería'), icon: Icon(Icons.engineering_outlined)),
                  ],
                  selected: {perfil},
                  onSelectionChanged: (s) => _cambiarPerfil(s.first),
                ),
                const SizedBox(height: 16),
                LabeledField('Email', controller: email, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                LabeledField('Contraseña', controller: clave, obscure: true),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const RecuperarScreen())),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _ingresar, child: const Text('Ingresar')),
                const SizedBox(height: 16),
                const Text(
                  'Tu perfil define qué ves al ingresar. En esta versión de prueba podés elegirlo arriba.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecuperarScreen extends StatefulWidget {
  const RecuperarScreen({super.key});

  @override
  State<RecuperarScreen> createState() => _RecuperarScreenState();
}

class _RecuperarScreenState extends State<RecuperarScreen> {
  final email = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.bg),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.mail_outline, color: AppColors.primary, size: 28),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Recuperá tu contraseña', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Ingresá tu email y te mandamos un enlace para crear una contraseña nueva.',
                style: TextStyle(fontSize: 15, color: AppColors.muted)),
            const SizedBox(height: 24),
            LabeledField('Email', controller: email, hint: 'nombre@empresa.com', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (email.text.trim().isEmpty) {
                  avisar(context, 'Escribí tu email.');
                  return;
                }
                avisar(context, 'Te mandamos el enlace a ${email.text.trim()}.');
                Navigator.of(context).pop();
              },
              child: const Text('Enviar enlace'),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Volver al ingreso')),
          ]),
        ),
      ),
    );
  }
}
