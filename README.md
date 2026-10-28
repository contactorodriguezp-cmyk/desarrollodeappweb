# Relevo — App de visitas técnicas comerciales

TP de Desarrollo de Apps Web (UCA). App web responsive en Flutter para registrar visitas técnicas en empresas industriales: Ingeniería pide los datos que necesita y el ejecutivo comercial los carga durante la visita.

Diseño en Figma: https://www.figma.com/design/SROONlApRT85liVys9vaQ0

## Ver la app online

https://contactorodriguezp-cmyk.github.io/desarrollodeappweb/

Se publica sola con GitHub Actions (`.github/workflows/publicar-web.yml`) cada vez que se sube algo a `main`.

## Descargar el APK (Android)

Cada vez que se sube algo a `main`, GitHub compila el APK. Para descargarlo: pestaña **Actions** → la última ejecución de "Publicar web y APK" → abajo, en **Artifacts**, `relevo-apk` (viene en un .zip con `app-release.apk` adentro).

## Cómo correrla en la compu

Hace falta tener Flutter instalado (https://docs.flutter.dev/get-started/install).

```bash
flutter pub get
flutter run -d chrome
```

## Cómo probarla

En el ingreso se elige el perfil (es una versión de prueba, sin contraseñas reales):

- **Comercial** (Martina López): mis solicitudes, notificaciones, detalle de la solicitud, registro de la visita en 4 pasos (datos, mediciones, fotos, necesidades), revisar y enviar, historial y perfil.
- **Ingeniería** (Juan Pérez): inicio, solicitudes, nueva solicitud en 3 pasos (datos generales, datos a relevar, asignar comercial), detalle del relevamiento, clientes, proyectos e historial.

Recorrido de punta a punta: entrá como Ingeniería, creá una solicitud asignada a Martina López, cerrá sesión, entrá como Comercial y vas a ver la notificación y la solicitud nueva. Registrá la visita, enviala y volvé a entrar como Ingeniería: el relevamiento aparece en Historial.

La app se adapta al ancho: en la compu Ingeniería usa menú lateral y en el celular, barra de navegación abajo.

## Estructura

```
lib/
  main.dart                    app y tema
  theme.dart                   colores del Figma y estilos
  data/
    models.dart                Solicitud, DatoRelevar, Relevamiento, Cliente, etc.
    app_state.dart             estado en memoria con datos de ejemplo
  widgets/
    common.dart                componentes: estado, tarjeta, campo, panel, grilla
    relevamiento_view.dart     vista de un relevamiento enviado
  screens/
    ingreso_screen.dart        ingreso y recuperar contraseña
    comercial/                 pantallas del ejecutivo comercial
    ingenieria/                pantallas de Ingeniería
test/widget_test.dart
```

## Límites de esta versión

- Los datos viven en memoria: al recargar la página vuelven los de ejemplo. El paso siguiente es conectar un backend (por ejemplo Firebase Auth + Firestore + Storage).
- Las fotos y los planos se simulan; la versión final usa la cámara y el selector de archivos (`image_picker`, `file_picker`).
- Descargar PDF, exportar y alta de clientes o proyectos muestran un aviso de "próxima versión".
