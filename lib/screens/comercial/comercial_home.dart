import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../ingreso_screen.dart';
import 'detalle_solicitud_screen.dart';
import 'resumen_screen.dart';
import 'visita_screen.dart';

/// Pestaña activa de la app del comercial (0 Solicitudes, 1 Historial, 2 Perfil).
final comercialTab = ValueNotifier<int>(0);

/// Abre la pantalla que corresponde según el estado de la solicitud.
void abrirSolicitud(BuildContext context, Solicitud s) {
  final Widget destino = switch (s.estado) {
    Estado.pendiente => DetalleSolicitudScreen(s),
    Estado.enCurso => VisitaScreen(s),
    Estado.completada => ResumenScreen(s),
  };
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => destino));
}

class ComercialHome extends StatelessWidget {
  const ComercialHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: comercialTab,
      builder: (context, tab, _) => Scaffold(
        body: IndexedStack(index: tab, children: const [MisSolicitudesTab(), HistorialTab(), PerfilTab()]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => comercialTab.value = i,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.list_alt), label: 'Solicitudes'),
            NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

/// Contenido centrado con ancho máximo, para que en la compu no se estire.
class _Centrado extends StatelessWidget {
  const _Centrado({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: child));
}

class MisSolicitudesTab extends StatefulWidget {
  const MisSolicitudesTab({super.key});

  @override
  State<MisSolicitudesTab> createState() => _MisSolicitudesTabState();
}

class _MisSolicitudesTabState extends State<MisSolicitudesTab> {
  Estado filtro = Estado.pendiente;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final mias = app.delComercial(app.usuarioComercial);
        int cuenta(Estado e) => mias.where((s) => s.estado == e).length;
        final lista = mias.where((s) => s.estado == filtro).toList()
          ..sort((a, b) => a.limite.compareTo(b.limite));
        return Scaffold(
          appBar: AppBar(
            title: const Logo(),
            actions: [
              IconButton(
                tooltip: 'Notificaciones',
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificacionesScreen())),
                icon: Badge(
                  isLabelVisible: app.noLeidas > 0,
                  label: Text('${app.noLeidas}'),
                  child: const Icon(Icons.notifications_none),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _Centrado(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text('Hola, ${app.usuarioComercial.split(' ').first}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                cuenta(Estado.pendiente) == 0
                    ? 'No tenés solicitudes pendientes.'
                    : 'Tenés ${cuenta(Estado.pendiente)} solicitudes pendientes de Ingeniería.',
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final e in Estado.values)
                  ChoiceChip(
                    label: Text('${e.label} (${cuenta(e)})'),
                    selected: filtro == e,
                    onSelected: (_) => setState(() => filtro = e),
                  ),
              ]),
              const SizedBox(height: 12),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No hay solicitudes en este estado.',
                      textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
                ),
              for (final s in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SolicitudCard(s, onTap: () => abrirSolicitud(context, s)),
                ),
            ]),
          ),
        );
      },
    );
  }
}

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  // Se guardan las no leídas al abrir, para resaltarlas aunque ya se marquen como leídas.
  late final Set<Notificacion> nuevas = app.notificaciones.where((n) => !n.leida).toSet();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => app.marcarLeidas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nuevas.isEmpty ? 'Notificaciones' : 'Notificaciones (${nuevas.length} nuevas)')),
      body: _Centrado(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          for (final n in app.notificaciones)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Panel(
                color: nuevas.contains(n) ? AppColors.primarySoft : null,
                onTap: () {
                  final s = n.codigo == null ? null : app.buscar(n.codigo!);
                  if (s != null) abrirSolicitud(context, s);
                },
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: nuevas.contains(n) ? AppColors.surface : AppColors.bg,
                    child: const Icon(Icons.notifications_none, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(n.titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(n.detalle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      const SizedBox(height: 3),
                      Text(n.cuando,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted)),
                    ]),
                  ),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

class HistorialTab extends StatefulWidget {
  const HistorialTab({super.key});

  @override
  State<HistorialTab> createState() => _HistorialTabState();
}

class _HistorialTabState extends State<HistorialTab> {
  String busqueda = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final q = busqueda.toLowerCase();
        final lista = app
            .delComercial(app.usuarioComercial)
            .where((s) => s.estado == Estado.completada)
            .where((s) => '${s.codigo} ${s.cliente} ${s.titulo}'.toLowerCase().contains(q))
            .toList()
          ..sort((a, b) => b.relevamiento!.enviado!.compareTo(a.relevamiento!.enviado!));
        return Scaffold(
          appBar: AppBar(title: const Text('Historial', style: TextStyle(fontWeight: FontWeight.w700))),
          body: _Centrado(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              TextField(
                onChanged: (v) => setState(() => busqueda = v),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search), hintText: 'Buscar por cliente o código'),
              ),
              const SizedBox(height: 12),
              if (lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No hay visitas enviadas.', textAlign: TextAlign.center),
                ),
              for (final s in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SolicitudCard(s, onTap: () => abrirSolicitud(context, s)),
                ),
            ]),
          ),
        );
      },
    );
  }
}

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  bool avisos = true;
  bool sinConexion = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final mias = app.delComercial(app.usuarioComercial);
        final enviadas = mias.where((s) => s.estado == Estado.completada).length;
        final pendientes = mias.where((s) => s.estado != Estado.completada).length;
        return Scaffold(
          appBar: AppBar(title: const Text('Perfil', style: TextStyle(fontWeight: FontWeight.w700))),
          body: _Centrado(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Panel(
                child: Row(children: [
                  const Avatar('ML', size: 56),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(app.usuarioComercial, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const Text('Ejecutiva comercial · Mendoza', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  ]),
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _Dato('$enviadas', 'Visitas enviadas')),
                const SizedBox(width: 12),
                Expanded(child: _Dato('$pendientes', 'Pendientes')),
              ]),
              const SizedBox(height: 12),
              Panel(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  ListTile(
                    title: const Text('Datos personales'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => avisar(context, 'Disponible en la próxima versión.'),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Avisos de nuevas solicitudes'),
                    value: avisos,
                    onChanged: (v) => setState(() => avisos = v),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Trabajar sin conexión'),
                    value: sinConexion,
                    onChanged: (v) => setState(() => sinConexion = v),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Ayuda'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => avisar(context, 'Escribinos a soporte para cualquier duda.'),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  comercialTab.value = 0;
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const IngresoScreen()), (_) => false);
                },
                child: const Text('Cerrar sesión'),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.valor, this.texto);

  final String valor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        Text(texto, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
      ]),
    );
  }
}
