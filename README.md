# NorthwestBank-Frontend

Aplicacion de banca movil desarrollada en Flutter. Permite a los usuarios gestionar sus cuentas bancarias, realizar transferencias, consultar transacciones, pagar servicios y administrar su perfil desde un dispositivo movil.

## Estructura del proyecto

El codigo fuente se encuentra en la carpeta lib/ y esta organizado de la siguiente manera:

### Punto de entrada

main.dart es el archivo principal de la aplicacion. Define las rutas de navegacion y la configuracion inicial del MaterialApp. La ruta inicial es /login.

### Pantallas (lib/screens/)

login_screen.dart - Pantalla de inicio de sesion. Permite autenticarse con correo electronico y contrasena, o mediante biometria (huella dactilar). Si el dispositivo no soporta biometria, muestra un mensaje informativo.

dashboard_screen.dart - Pantalla principal despues del login. Muestra un resumen de las cuentas del usuario y accesos rapidos a las funcionalidades principales.

transfers_screen.dart - Modulo de transferencias. Permite enviar dinero entre cuentas.

transactions_screen.dart - Historial de transacciones. Muestra los movimientos realizados en las cuentas.

payments_screen.dart - Modulo de pagos. Permite realizar pagos de servicios.

notifications_screen.dart - Centro de notificaciones. Muestra alertas y avisos relevantes para el usuario.

profile_screen.dart - Perfil del usuario. Incluye configuraciones como activar/desactivar biometria y la opcion de cerrar sesion.

### Servicios (lib/services/)

biometric_service.dart - Servicio que encapsula la logica de autenticacion biometrica usando el paquete local_auth. Verifica si el dispositivo soporta biometria y gestiona el proceso de autenticacion con huella dactilar.

### Widgets reutilizables (lib/widgets/)

account_card.dart - Tarjeta que muestra el saldo y la informacion de una cuenta bancaria.

quick_action_button.dart - Boton de accion rapida utilizado en el dashboard para acceder a las funcionalidades principales.

transaction_tile.dart - Elemento de lista que representa una transaccion individual en el historial.

### Tema (lib/theme/)

app_theme.dart - Define el tema visual de la aplicacion. Incluye la paleta de colores (azul oscuro como color primario, verde como acento), tipografia y estilos de botones e inputs. Utiliza Material 3.

## Dependencias principales

- flutter - Framework de desarrollo multiplataforma
- cupertino_icons - Iconos estilo iOS
- local_auth - Autenticacion biometrica (huella dactilar / Face ID)

## Configuracion Android

La aplicacion requiere el permiso USE_BIOMETRIC en AndroidManifest.xml. La MainActivity extiende FlutterFragmentActivity para soportar el dialogo nativo de autenticacion biometrica.

## Ramas

- main - Rama principal con el codigo estable
- feature/auth - Autenticacion y login
- feature/dashboard - Pantalla principal
- feature/transfers - Transferencias
- feature/transactions - Historial de transacciones
- feature/payments - Pagos de servicios
- feature/notifications - Notificaciones
- feature/profile - Perfil del usuario