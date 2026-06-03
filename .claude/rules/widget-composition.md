# Composición de Widgets — 3 Niveles

## Nivel 1: View
Sufijo: View (ej. ProfileView, HomeView)
- Orquesta la pantalla completa
- Escucha Providers / Controllers
- Prepara y formatea datos antes de pasarlos
- Maneja navegación
- No contiene lógica de negocio ni formateo inline

## Nivel 2: Section
Sufijo: Section o Container (ej. ProfileHeaderSection, OrdersListSection)
- Representa un bloque funcional de la UI
- Recibe datos ya preparados como parámetros
- Sin acceso a Providers
- Sin formateo de datos

## Nivel 3: UIWidget
Nombre visual (ej. UserAvatar, PrimaryButton, InfoRow, PriceText)
- 100% declarativo
- Sin lógica, sin formateo, sin estado global
- Recibe datos finales listos para renderizar

## Flujo correcto
Provider/Controller → Formatter → View → Section → UIWidget

## La View prepara los datos
// Correcto
final formattedDate = DateFormatter.format(user.createdAt);
ProfileHeaderSection(joinDate: formattedDate)

// Prohibido en widgets
Text(DateFormat('dd/MM/yyyy').format(user.createdAt))
Text("${price.toStringAsFixed(2)}")

## Límites de complejidad
- Widget >100 líneas → probablemente hace demasiado, considerar división
- Widget >6 parámetros → considerar agrupar en objeto o dividir
- Mucha lógica condicional → no es un UIWidget puro

## Formatters
Ubicación: lib/core/utils/[domain]_formatters/
Ejemplos: date_formatters.dart, currency_formatters.dart, user_formatters.dart