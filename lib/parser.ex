defmodule Ledger.Parser do
  def validar_subcomando(subcomando) do
    case subcomando do
      "transacciones" -> {:ok, :transacciones}
      "balance" -> {:ok, :balance}
      _ -> {:error, :subcomando_invalido}
    end
  end

  def validar_opciones(opciones, subcomando) do
    # opciones = ["-c1=userA", "-c2=userB"]

    opciones = Enum.map(opciones,
    fn "-" <> resto -> "--" <> resto
    other -> other end)

    # opciones = ["--c1=userA", "--c2=userB"]

    {opciones, resto, invalidos} = OptionParser.parse(opciones,
      strict: [t: :string, o: :string, c1: :string, c2: :string, m: :string])

    case {resto, invalidos} do
      {[], []} ->
        mapa_opciones = %{
          archivo_input: opciones[:t] || "test/fixtures/transacciones.csv",
          archivo_output: opciones[:o],
          cuenta_origen: opciones[:c1],
          cuenta_destino: opciones[:c2],
          moneda: opciones[:m]
        }

        case {subcomando, mapa_opciones.cuenta_origen} do
          {:balance, nil} -> {:error, :falta_cuenta_origen}
          _ -> {:ok, mapa_opciones}
        end

      _ ->
        {:error, :parametro_invalido}
    end
  end

  def leer_csv(path) do
    case File.read(path) do
      {:ok, contenido} -> {:ok, contenido}
      {:error, _error} -> {:error, :error_leer_csv}
    end
  end

  def parsear_moneda(contenido) do
    contenido
    |> String.split("\n", trim: true)
    |> Enum.with_index(1) #agregar numero de linea
    |> Enum.reduce_while([], fn {linea, nro_linea}, acc ->
      case String.split(linea, ";") do #separar por ;
        [nombre, precio_str] ->
          case Float.parse(precio_str) do #parsear a float
            {precio_float, ""} -> {:cont, [%Ledger.Moneda{nombre_moneda: nombre, precio_usd: precio_float} | acc]}
            _ -> {:halt, {:error, {:precio_invalido, nro_linea}}} #Si ocurrio algun error -> error
          end
        _ -> {:halt, {:error, {:formato_invalido, nro_linea}}} #Si no tiene 2 partes -> error
      end
    end)
    |> case do
      {:error, _} = error -> error
      lista -> {:ok, Enum.reverse(lista)}
    end
  end

  def parsear_transaccion(contenido) do
    contenido
    |> String.split("\n", trim: true)
    |> Enum.with_index(1)
    |> Enum.reduce_while([], fn {linea, nro_linea}, acc ->
      case String.split(linea, ";") do
        [id, fecha, moneda_origen, moneda_destino, monto_str, cuenta_origen, cuenta_destino, tipo] ->
          case Float.parse(monto_str) do
            {monto_float, ""} when monto_float >= 0 ->
              if tipo in ["transferencia", "swap", "alta_cuenta"] do
                transaccion = %Ledger.Transaccion{
                  id_transaccion: id,
                  timestamp: fecha,
                  moneda_origen: moneda_origen,
                  moneda_destino: moneda_destino,
                  monto: monto_float,
                  cuenta_origen: cuenta_origen,
                  cuenta_destino: cuenta_destino,
                  tipo: tipo
                }

                {:cont, [transaccion | acc]}
              else
                {:halt, {:error, {:tipo_invalido, nro_linea}}}
              end

            _ -> {:halt, {:error, {:monto_invalido, nro_linea}}}
          end

        _ -> {:halt, {:error, {:formato_invalido, nro_linea}}}
      end
    end)
    |> case do
      {:error, _} = error -> error
      lista -> {:ok, Enum.reverse(lista)}
    end
  end

  def string_moneda(%Ledger.Moneda{nombre_moneda: nombre, precio_usd: precio}) do
    precio_str = :erlang.float_to_binary(precio, decimals: 6)
    Enum.join([nombre, precio_str], ";")
  end

  def string_monedas(monedas) do
    monedas
    |> Enum.map(&string_moneda/1)
    |> Enum.join("\n")
  end

  def string_transaccion(%Ledger.Transaccion{
      id_transaccion: id,
      timestamp: fecha,
      moneda_origen: moneda_origen,
      moneda_destino: moneda_destino,
      monto: monto,
      cuenta_origen: cuenta_origen,
      cuenta_destino: cuenta_destino,
      tipo: tipo
    }) do
    monto_str = :erlang.float_to_binary(monto, decimals: 6)

    Enum.join([id, fecha, moneda_origen, moneda_destino, monto_str, cuenta_origen, cuenta_destino, tipo], ";")
  end

  def string_transacciones(transacciones) do
    transacciones
    |> Enum.map(&string_transaccion/1)
    |> Enum.join("\n")
  end

  def mostrar_salida(contenido) do
    IO.puts(contenido)
    {:ok, :mostrado}
  end

  def escribir_salida(path, contenido) do
    case File.write(path, contenido) do
      :ok -> {:ok, :escrito}
      {:error, _error} -> {:error, :error_escribir_csv}
    end
  end
end
