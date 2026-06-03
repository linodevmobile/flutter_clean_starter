# Actions — Extracción de comportamiento

## Principio
Los widgets emiten **intenciones**; el comportamiento repetible (modal de confirmación
+ use case + toast/snackbar) vive en módulos **sin UI** llamados *actions*. Cada caller
mantiene su propio side effect específico (navegación, invalidación de providers, estado local).

## Regla de tres
- **1ª ocurrencia** → escribir inline en la view/section. Está bien.
- **2ª ocurrencia** → dejarlas separadas. Pueden divergir legítimamente.
- **3ª ocurrencia** → **extraer a una action**. Copiar de nuevo es spaghetti.

Antes de aceptar un "copia tal cual de X", contar cuántas copias del mismo
patrón existen. Si ya son 2, proponer extracción en el plan.

## Estructura

```
lib/features/[feature]/presentation/actions/[feature]_actions.dart
```

## Contrato

```dart
class TripActions {
  TripActions._(); // no se instancia; solo métodos estáticos

  /// Retorna el dato útil si la operación tuvo éxito; false/null si se canceló
  /// o falló (el toast ya lo mostró la action).
  static Future<bool> cancel(
    WidgetRef ref,
    BuildContext context, {
    required String tripId,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDialog(message: '¿Cancelar el viaje?'),
    );
    if (confirm != true) return false;

    final result = await AsyncValue.guard(
      () => ref.read(cancelTripUseCaseProvider)(tripId),
    );
    if (!context.mounted) return false;

    return result.when(
      data: (_) {
        showToast(context, 'Viaje cancelado');
        return true;
      },
      error: (e, _) {
        showToast(context, e is Failure ? e.message : 'Error desconocido');
        return false;
      },
      loading: () => false,
    );
  }
}
```

Una action **debe**:
1. Recibir `WidgetRef` y `BuildContext` explícitamente.
2. Encapsular: modal de confirmación + llamada al use case (vía `AsyncValue.guard`) + toast (éxito/error).
3. Verificar `context.mounted` tras cada `await`.
4. Retornar el resultado para que el caller decida qué hacer.

Una action **no debe**:
- Hacer pop/navegar (`context.pop`, `context.go`) — es side effect del caller.
- Invalidar providers que pertenecen a otras features (mapa, listas) — el
  caller los conoce, la action no.
- Tocar el estado local del caller (notifiers, flags `_changed`).
- Recibir dependencias por singleton/global. Todo explícito.

## Side effects del caller

Cada caller aplica lo que es propio de su pantalla:

```dart
// TripDetailView: tras cancelar, vuelve al home
final ok = await TripActions.cancel(ref, context, tripId: trip.id);
if (ok && context.mounted) context.go(AppRoutes.home);

// MapTripCalloutSection: tras cancelar, limpia el marcador e invalida el mapa
final ok = await TripActions.cancel(ref, context, tripId: trip.id);
if (ok) { selectedTrip.clear(); ref.invalidate(mapTripsProvider); }
```

## Relación con UseCase
La action **no reemplaza** al use case: lo **usa**. El use case es regla de negocio pura
(no conoce Flutter ni `BuildContext`); la action es el "pegamento de UX" entre el botón y
el use case (modal + toast). Ver [`layers.md`](layers.md) para la frontera entre capas.

## Cuándo NO crear una action
- Si el flujo solo aparece **una vez** en toda la app.
- Si el flujo es trivial (sin modal, sin use case, sin toast).
- Si extraer obliga a recibir 6+ parámetros — probablemente el flujo no es
  uniforme y la "abstracción" sería forzada.
