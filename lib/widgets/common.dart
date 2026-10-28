import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.straighten, size: 18, color: Colors.white),
      ),
      const SizedBox(width: 8),
      Text('Relevo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: light ? Colors.white : AppColors.ink)),
    ]);
  }
}

class EstadoBadge extends StatelessWidget {
  const EstadoBadge(this.estado, {super.key});

  final Estado estado;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (estado) {
      Estado.pendiente => (AppColors.pending, AppColors.pendingBg),
      Estado.enCurso => (AppColors.primary, AppColors.primarySoft),
      Estado.completada => (AppColors.done, AppColors.doneBg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(estado.label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

/// Tarjeta blanca con borde, opcionalmente tocable.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color == null ? AppColors.border : Colors.transparent),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class SolicitudCard extends StatelessWidget {
  const SolicitudCard(this.s, {super.key, this.onTap});

  final Solicitud s;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final linea = switch (s.estado) {
      Estado.pendiente => 'Visitar antes del ${fmt(s.limite)}',
      Estado.enCurso => 'Visita en curso · vence el ${fmt(s.limite)}',
      Estado.completada => 'Enviada el ${fmt(s.relevamiento?.enviado ?? s.limite)}',
    };
    return Panel(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(s.codigo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
          const Spacer(),
          EstadoBadge(s.estado),
        ]),
        const SizedBox(height: 8),
        Text(s.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${s.cliente} · ${s.proyecto}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        const SizedBox(height: 4),
        Text(linea, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class KvRow extends StatelessWidget {
  const KvRow(this.k, this.v, {super.key, this.first = false});

  final String k;
  final String v;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: first ? null : const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip(this.text, {super.key, this.highlight = false});

  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primarySoft : AppColors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: highlight ? AppColors.primary : AppColors.muted)),
    );
  }
}

/// Campo con etiqueta arriba, como el componente "Campo" del Figma.
class LabeledField extends StatelessWidget {
  const LabeledField(
    this.label, {
    super.key,
    this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.obscure = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        obscureText: obscure,
        onChanged: onChanged,
        decoration: InputDecoration(hintText: hint),
      ),
    ]);
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
      if (trailing != null) trailing!,
    ]);
  }
}

/// Recuadro de color suave con un aviso o las indicaciones de Ingeniería.
class InfoBox extends StatelessWidget {
  const InfoBox({super.key, this.title, required this.text, this.icon, this.color = AppColors.primarySoft, this.fg = AppColors.primary});

  final String? title;
  final String text;
  final IconData? icon;
  final Color color;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 10)],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (title != null) ...[
              Text(title!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
              const SizedBox(height: 4),
            ],
            Text(text, style: TextStyle(fontSize: 14, color: title != null ? AppColors.ink : fg, fontWeight: title != null ? FontWeight.w400 : FontWeight.w500)),
          ]),
        ),
      ]),
    );
  }
}

/// Barra de pasos de la visita (celular).
class MobileStepper extends StatelessWidget {
  const MobileStepper({super.key, required this.labels, required this.active, this.onTap});

  final List<String> labels;
  final int active;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: onTap == null ? null : () => onTap!(i),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= active ? AppColors.primary : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(labels[i],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: i == active ? FontWeight.w600 : FontWeight.w500,
                      color: i <= active ? AppColors.primary : AppColors.muted,
                    )),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

/// Miniatura de foto o plano (sin imagen real en esta versión).
class Miniatura extends StatelessWidget {
  const Miniatura(this.nombre, {super.key, this.documento = false, this.height = 100});

  final String nombre;
  final bool documento;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
        child: Icon(documento ? Icons.description_outlined : Icons.image_outlined, color: AppColors.primary, size: 28),
      ),
      const SizedBox(height: 6),
      Text(nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    ]);
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.iniciales, {super.key, this.size = 34, this.color = AppColors.primarySoft});

  final String iniciales;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Text(iniciales,
          style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeight.w700, color: AppColors.primary)),
    );
  }
}

/// Grilla que acomoda columnas según el ancho disponible.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.minItemWidth = 220, this.spacing = 16});

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final cols = math.max(1, ((box.maxWidth + spacing) / (minItemWidth + spacing)).floor());
      final w = (box.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final c in children) SizedBox(width: w, child: c)],
      );
    });
  }
}

void avisar(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating));
}
