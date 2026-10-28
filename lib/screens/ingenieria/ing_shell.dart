import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../ingreso_screen.dart';
import 'clientes_pages.dart';
import 'historial_page.dart';
import 'inicio_page.dart';
import 'solicitudes_page.dart';

/// Sección activa de Ingeniería (0 Inicio, 1 Solicitudes, 2 Clientes, 3 Proyectos, 4 Historial).
final ingTab = ValueNotifier<int>(0);

const _destinos = [
  ('Inicio', Icons.home_outlined),
  ('Solicitudes', Icons.list_alt),
  ('Clientes', Icons.apartment),
  ('Proyectos', Icons.folder_outlined),
  ('Historial', Icons.history),
];

/// En pantallas anchas se usa el menú lateral (como en el Figma de escritorio);
/// en el celular, barra de navegación abajo.
bool esAncho(BuildContext context) => MediaQuery.sizeOf(context).width >= 1000;

EdgeInsets margenPagina(BuildContext context) =>
    esAncho(context) ? const EdgeInsets.fromLTRB(32, 28, 32, 32) : const EdgeInsets.all(16);

class IngenieriaShell extends StatelessWidget {
  const IngenieriaShell({super.key});

  static const routeName = '/ingenieria';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ingTab,
      builder: (context, tab, _) => IngScaffold(
        tab: tab,
        body: switch (tab) {
          0 => const InicioPage(),
          1 => const SolicitudesPage(),
          2 => const ClientesPage(),
          3 => const ProyectosPage(),
          _ => const HistorialPage(),
        },
      ),
    );
  }
}

/// Marco común de todas las pantallas de Ingeniería.
class IngScaffold extends StatelessWidget {
  const IngScaffold({super.key, required this.tab, required this.body, this.title});

  final int tab;
  final Widget body;

  /// Título de la barra superior en el celular (pantallas de detalle).
  final String? title;

  static void irA(BuildContext context, int i) {
    ingTab.value = i;
    Navigator.of(context).popUntil(ModalRoute.withName(IngenieriaShell.routeName));
  }

  static void salir(BuildContext context) {
    ingTab.value = 0;
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const IngresoScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (esAncho(context)) {
      return Scaffold(
        body: Row(children: [
          _Sidebar(tab: tab),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const _TopBar(),
              if (title != null && Navigator.of(context).canPop())
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 0, 0),
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Volver'),
                  ),
                ),
              Expanded(child: body),
            ]),
          ),
        ]),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: title == null ? const Logo() : Text(title!, style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          PopupMenuButton<int>(
            tooltip: 'Cuenta',
            onSelected: (_) => salir(context),
            itemBuilder: (_) => const [PopupMenuItem(value: 0, child: Text('Cerrar sesión'))],
            child: const Padding(padding: EdgeInsets.only(right: 12), child: Avatar('JP')),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => irA(context, i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [for (final (t, i) in _destinos) NavigationDestination(icon: Icon(i), label: t)],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.tab});

  final int tab;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => IngScaffold.irA(context, 0),
            child: const Padding(padding: EdgeInsets.fromLTRB(8, 0, 8, 24), child: Logo(light: true)),
          ),
        ),
        for (var i = 0; i < _destinos.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: i == tab ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => IngScaffold.irA(context, i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [
                    Icon(_destinos[i].$2, size: 20, color: i == tab ? Colors.white : const Color(0xFFA9B4C6)),
                    const SizedBox(width: 12),
                    Text(_destinos[i].$1,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: i == tab ? FontWeight.w600 : FontWeight.w500,
                          color: i == tab ? Colors.white : Colors.white70,
                        )),
                  ]),
                ),
              ),
            ),
          ),
        const Spacer(),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.white70, alignment: Alignment.centerLeft),
          onPressed: () => IngScaffold.salir(context),
          icon: const Icon(Icons.logout, size: 20),
          label: const Text('Cerrar sesión'),
        ),
      ]),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        const SizedBox(
          width: 360,
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Icon(Icons.search, size: 20),
              hintText: 'Buscar cliente, proyecto o código',
              fillColor: AppColors.bg,
            ),
          ),
        ),
        const Spacer(),
        const Avatar('JP'),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(app.usuarioIngenieria, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Text('Ingeniería', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
      ]),
    );
  }
}

/// Título de página con acciones (a la derecha en compu, debajo en celular).
class PageHeader extends StatelessWidget {
  const PageHeader(this.title, {super.key, this.subtitle, this.actions = const []});

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textos = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: esAncho(context) ? 26 : 22, fontWeight: FontWeight.w700)),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle!, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
      ],
    ]);
    final botones = Wrap(spacing: 12, runSpacing: 8, children: actions);
    if (esAncho(context)) {
      return Row(children: [Expanded(child: textos), botones]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      textos,
      if (actions.isNotEmpty) ...[const SizedBox(height: 12), botones],
    ]);
  }
}

/// Dos columnas en compu (la derecha de ancho fijo); una debajo de otra en celular.
class DosColumnas extends StatelessWidget {
  const DosColumnas({super.key, required this.izquierda, required this.derecha, this.anchoDerecha = 400});

  final Widget izquierda;
  final Widget derecha;
  final double anchoDerecha;

  @override
  Widget build(BuildContext context) {
    if (!esAncho(context)) {
      return Column(children: [izquierda, const SizedBox(height: 16), derecha]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: izquierda),
      const SizedBox(width: 24),
      SizedBox(width: anchoDerecha, child: derecha),
    ]);
  }
}

/// Fila de lista con título, subtítulo y algo a la derecha.
class FilaLista extends StatelessWidget {
  const FilaLista({super.key, required this.titulo, required this.subtitulo, this.trailing, this.leading, this.onTap, this.primera = false});

  final String titulo;
  final String subtitulo;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool primera;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration:
            primera ? null : const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
        child: Row(children: [
          if (leading != null) ...[leading!, const SizedBox(width: 14)],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(subtitulo, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ]),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ]),
      ),
    );
  }
}

/// Tabla simple para compu; todas las columnas con flex para no desbordar.
class Tabla extends StatelessWidget {
  const Tabla({super.key, required this.columnas, required this.filas, this.onTap});

  final List<(String, int)> columnas;
  final List<List<Widget>> filas;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    Widget fila(List<Widget> celdas) => Row(children: [
          for (var i = 0; i < celdas.length; i++)
            Expanded(flex: columnas[i].$2, child: Padding(padding: const EdgeInsets.only(right: 12), child: celdas[i])),
        ]);
    return Panel(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: fila([
            for (final (t, _) in columnas)
              Text(t.toUpperCase(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
          ]),
        ),
        for (var i = 0; i < filas.length; i++)
          InkWell(
            onTap: onTap == null ? null : () => onTap!(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              child: fila(filas[i]),
            ),
          ),
      ]),
    );
  }
}

Widget celda(String t, {bool fuerte = false, bool suave = false}) => Text(
      t,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: fuerte ? FontWeight.w600 : FontWeight.w400,
        color: suave ? AppColors.muted : AppColors.ink,
      ),
    );
