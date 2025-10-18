# Ledger - Reportes

## Comandos del `Makefile`

| Comando       | Descripción                                                      |
|---------------|------------------------------------------------------------------|
| `up-db`       | Levanta el contenedor de la base de datos.                       |
| `down-db`     | Detiene y elimina el contenedor de la base de datos.             |
| `setup-db`    | Crea la base de datos y ejecuta las migraciones.                |
| `reset-db`    | Elimina la base de datos, la vuelve a crear y ejecuta las migraciones. |
| `migrate`     | Ejecuta las migraciones pendientes.                              |
| `format`      | Corre el formateador de código de *mix*.                         |
| `compile`     | Compila el proyecto y genera el ejecutable.                      |
| `dev`         | Inicia una consola interactiva con el proyecto cargado.          |
| `insert-db`   | Inserta datos iniciales usando `priv/repo/seeds.exs`.            |
| `test`        | Corre los tests del proyecto con cobertura, reseteando la DB e insertando seeds. |


## Comandos para correr el programa

| Comando                  | Parámetros                                                                 | Descripción                                                                 |
|---------------------------|---------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `crear_usuario`           | `-n=Nombre -b=YYYY-MM-DD`                                                 | Crea un usuario con nombre y fecha de nacimiento.                           |
| `ver_usuario`             | `-id=ID`                                                                  | Muestra los detalles de un usuario por su ID.                                |
| `editar_usuario`          | `-id=ID -n=Nombre`                                                        | Modifica el nombre de un usuario existente.                                  |
| `borrar_usuario`          | `-id=ID`                                                                  | Elimina un usuario por su ID.                                               |
| `crear_moneda`            | `-n=Nombre -p=Precio`                                                    | Crea una moneda con nombre y precio en dólares.                             |
| `ver_moneda`              | `-id=ID`                                                                  | Muestra los detalles de una moneda.                                         |
| `editar_moneda`           | `-id=ID -p=Precio`                                                        | Modifica el precio de una moneda existente.                                 |
| `borrar_moneda`           | `-id=ID`                                                                  | Elimina una moneda por su ID.                                               |
| `alta_cuenta`             | `-u=ID_usuario -m=ID_moneda -a=Monto`                                     | Crea una cuenta para un usuario con un monto inicial.                       |
| `realizar_transferencia`  | `-o=ID_origen -d=ID_destino -m=ID_moneda -a=Monto`                        | Realiza una transferencia entre cuentas.                                    |
| `realizar_swap`           | `-u=ID_cuenta -mo=ID_moneda_origen -md=ID_moneda_destino -a=Monto`        | Realiza un intercambio (swap) de monedas en una cuenta.                     |
| `deshacer_transaccion`    | `-id=ID`                                                                  | Revierte una transacción por su ID.                                         |
| `ver_transaccion`         | `-id=ID`                                                                  | Muestra los detalles de una transacción.                                     |
| `transacciones`           | `-c1=ID_origen -c2=ID_destino -t=tipo -mb=moneda -f=archivo`             | Lista todas las transacciones, filtrando según los parámetros indicados.    |
| `balance`                 | `-c1=ID_cuenta [-m=ID_moneda o -mb=Nombre_moneda]`                        | Muestra el balance de una cuenta, opcionalmente por moneda específica.     |
