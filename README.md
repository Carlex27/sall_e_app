# sall_e_app

# Metodo para calcular el valor de la bateria 
double calculateLeadAcidPercentage({
required double v1, // sensor 1
required double v2, // sensor 2
}) {
const minVoltage = 46.4;
const maxVoltage = 50.8;

final total = v1 + v2;
final clamped = total.clamp(minVoltage, maxVoltage);
final percent = ((clamped - minVoltage) / (maxVoltage - minVoltage)) * 100.0;
return percent;
}


# Estructura de paquetes

1. main.dart

   Qué es: El punto de entrada de la app.

   Responsabilidad: Iniciar Firebase, configurar rutas y lanzar la primera pantalla.

   Por qué separado: Es el núcleo, aquí no debe haber lógica compleja, solo inicialización y navegación inicial.

2. services/

   Qué es: Carpeta para el código que se conecta con el mundo externo.

   Ejemplos en tu caso:

        firebase_service.dart → inicio de sesión, cerrar sesión, inicializar Firebase.

        telemetry_service.dart → conexión con la base de datos para leer voltajes y geolocalización del ESP32.

        location_service.dart → acceso al GPS del teléfono para mostrar en el mapa.

   Por qué separado: Así todo el código que maneja datos externos queda aislado, y si mañana cambias de Firebase a otro backend, solo modificas aquí.

3. models/

   Qué es: Representaciones de datos de tu app en objetos Dart.

   Ejemplos:

        Telemetry → objeto con v1, v2, percentage, lat, lon, timestamp.

        UserProfile → datos del usuario (nombre, email, etc.).

   Por qué separado: Mantiene el formato de datos claro y evita tener variables sueltas. Además, facilita parsear de JSON a objetos y viceversa.

4. screens/

   Qué es: Las pantallas principales que ve el usuario.

   Ejemplos en tu caso:

        login_screen.dart → inicio de sesión.

        dashboard_screen.dart → voltaje, porcentaje, estado general.

        map_screen.dart → ubicación del triciclo en el mapa.

   Por qué separado: Cada pantalla tiene su archivo para que el código de UI esté organizado.

5. widgets/

   Qué es: Componentes reutilizables de UI.

   Ejemplos:

        battery_gauge.dart → indicador visual de batería.

        custom_app_bar.dart → barra de navegación personalizada.

   Por qué separado: Evita duplicar el mismo diseño en varias pantallas y facilita cambios de diseño globales.

6. utils/

   Qué es: Funciones de ayuda que no dependen de la UI ni de Firebase.

   Ejemplos:

        battery_utils.dart → fórmula para convertir voltaje en porcentaje.

        format_utils.dart → formatear fecha/hora.

   Por qué separado: Agrupa lógica que se reutiliza en varios puntos y no pertenece a un servicio o modelo.
