# Ledger - Reportes

## Manejo de errores

El programa maneja distintos tipos de errores y muestra mensajes para facilitar la identificación y corrección de problemas. A continuación se listan los errores que se detectan y sus mensajes asociados:

- `:subcomando_invalido`  
  Subcomando inválido. Use `'transacciones'` o `'balance'`.  
  *Generado al validar el subcomando ingresado.*

- `:parametro_invalido`  
  Parámetros inválidos proporcionados.  
  *Generado al validar las opciones o parámetros de entrada.*

- `:falta_cuenta_origen`  
  Falta la cuenta de origen para el balance.  
  *Generado cuando no se especifica la cuenta requerida para el cálculo de balance.*

- `:error_leer_csv`  
  Error al leer el archivo CSV.  
  *Generado si no se puede leer el archivo de entrada.*

- `:error_escribir_csv`  
  Error al escribir el archivo CSV.  
  *Generado si no se puede escribir el archivo de salida.*

- `{:precio_invalido, linea}`  
  Precio inválido en la línea `linea` del archivo CSV.  
  *Generado al parsear los precios de monedas.*

- `{:formato_invalido, linea}`  
  Formato inválido en la línea `linea` del archivo CSV.  
  *Generado al parsear monedas o transacciones con formato incorrecto.*

- `{:moneda_desconocida, linea}`  
  Moneda desconocida en la línea `linea` del archivo CSV.  
  *Generado si la moneda indicada no está en la lista de monedas conocidas.*

- `{:tipo_invalido, linea}`  
  Tipo de transacción inválido en la línea `linea` del archivo CSV.  
  *Generado si el tipo de transacción no es válido.*

- `{:monto_invalido, linea}`  
  Monto inválido en la línea `linea` del archivo CSV.  
  *Generado si el monto no es un número válido o es negativo.*

- `:moneda_no_existente`  
  La moneda objetivo no existe.  
  *Generado al solicitar un balance en una moneda que no está disponible.*

- Otros errores desconocidos  
  Se muestra el mensaje: `Error desconocido: <detalle del error>`.  
  *Para cualquier otro error no previsto.*

Estos mensajes se generan internamente en la función `format_error/1` y se utilizan para informar sobre problemas específicos durante la ejecución del programa.

## Link al repositorio: https://github.com/ifabregat/Ledger
