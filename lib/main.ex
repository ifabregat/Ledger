defmodule ExampleApp.CLI do
  alias Ledger.Parser, as: Parser
  alias Ledger

  def main(args \\ []) do
    case args do
      [subcomando | opciones] ->
        iniciar_programa(subcomando, opciones)

      [] ->
        IO.puts("Error: Recibo ledger <subcomando> <flags>")
        {:error, :faltan_argumentos}
    end
  end

  defp iniciar_programa(subcomando, opciones) do
    with {:ok, comando} <- Parser.validar_subcomando(subcomando),
         {:ok, opciones} <- Parser.validar_opciones(opciones, comando),
         {:ok, contenido} <- Parser.leer_csv(opciones.archivo_input),
         {:ok, monedas} <- cargar_monedas(),
         {:ok, transacciones} <-
           Parser.parsear_transaccion(contenido, Enum.map(monedas, & &1.nombre_moneda)) do
      case comando do
        :transacciones ->
          manejar_transacciones(transacciones, opciones)

        :balance ->
          manejar_balance(transacciones, opciones, monedas)
      end
    else
      {:error, motivo} ->
        IO.puts("Error: #{format_error(motivo)}")
        {:error, motivo}
    end
  end

  defp manejar_transacciones(transacciones, opciones) do
    resultado =
      {:ok, transacciones}
      |> aplicar_filtro(:origen, opciones.cuenta_origen)
      |> aplicar_filtro(:destino, opciones.cuenta_destino)
      |> aplicar_filtro(:moneda, opciones.moneda)
      |> aplicar_filtro(:tipo, opciones.tipo)

    case resultado do
      {:ok, transacciones_filtradas} ->
        contenido = Parser.string_transacciones(transacciones_filtradas)
        manejar_salida(contenido, opciones.archivo_output)
        {:ok, :exito}

      {:error, motivo} ->
        IO.puts("Error al filtrar: #{format_error(motivo)}")
        {:error, motivo}
    end
  end

  defp manejar_balance(transacciones, opciones, monedas) do
    with {:ok, transacciones_filtradas} <-
           {:ok, transacciones}
           |> aplicar_filtro(:origen, opciones.cuenta_origen)
           |> aplicar_filtro(:destino, opciones.cuenta_destino)
           |> aplicar_filtro(:moneda, opciones.moneda)
           |> aplicar_filtro(:tipo, opciones.tipo),
         balance =
           Ledger.calcular_balance(
             transacciones_filtradas,
             opciones.cuenta_origen,
             opciones.moneda,
             monedas
           ),
         contenido when is_binary(balance) <- balance do
      manejar_salida(contenido, opciones.archivo_output)
      {:ok, :exito}
    else
      {:error, motivo} ->
        IO.puts("Error al calcular balance: #{format_error(motivo)}")
        {:error, motivo}
    end
  end

  defp cargar_monedas do
    with {:ok, contenido} <- Parser.leer_csv("test/fixtures/moneda.csv"),
         {:ok, monedas} <- Parser.parsear_moneda(contenido) do
      {:ok, monedas}
    else
      {:error, motivo} -> {:error, motivo}
    end
  end

  defp aplicar_filtro({:ok, transacciones}, :origen, nil), do: {:ok, transacciones}

  defp aplicar_filtro({:ok, transacciones}, :origen, cuenta) do
    Ledger.filtrar_cuenta_origen(transacciones, cuenta)
  end

  defp aplicar_filtro({:ok, transacciones}, :destino, nil), do: {:ok, transacciones}

  defp aplicar_filtro({:ok, transacciones}, :destino, cuenta) do
    Ledger.filtrar_cuenta_destino(transacciones, cuenta)
  end

  defp aplicar_filtro({:ok, transacciones}, :moneda, nil), do: {:ok, transacciones}

  defp aplicar_filtro({:ok, transacciones}, :moneda, moneda) do
    Ledger.filtrar_moneda(transacciones, moneda)
  end

  defp aplicar_filtro({:ok, transacciones}, :tipo, nil), do: {:ok, transacciones}

  defp aplicar_filtro({:ok, transacciones}, :tipo, tipo) do
    Ledger.filtrar_tipo(transacciones, tipo)
  end

  defp aplicar_filtro(resultado, _, _), do: resultado

  defp manejar_salida(contenido, nil) do
    Parser.mostrar_salida(contenido)
  end

  defp manejar_salida(contenido, path) do
    Parser.escribir_salida(path, contenido)
  end

  defp format_error(:subcomando_invalido),
    do: "Subcomando inválido. Use 'transacciones' o 'balance'."

  defp format_error(:parametro_invalido), do: "Parámetros inválidos proporcionados."
  defp format_error(:falta_cuenta_origen), do: "Falta la cuenta de origen para el balance."
  defp format_error(:error_leer_csv), do: "Error al leer el archivo CSV."
  defp format_error(:error_escribir_csv), do: "Error al escribir el archivo CSV."
  defp format_error({:precio_invalido, linea}), do: "Precio inválido en la línea #{linea}."
  defp format_error({:formato_invalido, linea}), do: "Formato inválido en la línea #{linea}."
  defp format_error({:moneda_desconocida, linea}), do: "Moneda desconocida en la línea #{linea}."

  defp format_error({:tipo_invalido, linea}),
    do: "Tipo de transacción inválido en la línea #{linea}."

  defp format_error({:monto_invalido, linea}), do: "Monto inválido en la línea #{linea}."
  defp format_error(:moneda_no_existente), do: "La moneda objetivo no existe."
  defp format_error(motivo), do: "Error desconocido: #{inspect(motivo)}."
end
