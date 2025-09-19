defmodule Ledger do
  alias Ledger.{Moneda}

  def filtrar_cuenta_origen(transacciones, nil), do: {:ok, transacciones}

  def filtrar_cuenta_origen(transacciones, cuenta) do
    filtradas =
      Enum.filter(transacciones, fn transaccion -> transaccion.cuenta_origen == cuenta end)

    case filtradas do
      [] -> {:ok, []}
      _ -> {:ok, filtradas}
    end
  end

  def filtrar_cuenta_destino(transacciones, nil), do: {:ok, transacciones}

  def filtrar_cuenta_destino(transacciones, cuenta) do
    filtradas =
      Enum.filter(transacciones, fn transaccion -> transaccion.cuenta_destino == cuenta end)

    case filtradas do
      [] -> {:ok, []}
      _ -> {:ok, filtradas}
    end
  end

  def filtrar_moneda(transacciones, moneda) do
    filtradas =
      Enum.filter(transacciones, fn transaccion ->
        transaccion.moneda_origen == moneda || transaccion.moneda_destino == moneda
      end)

    case filtradas do
      [] -> {:ok, []}
      _ -> {:ok, filtradas}
    end
  end

  def filtrar_tipo(transacciones, tipo) do
    filtradas =
      Enum.filter(transacciones, fn transaccion ->
        transaccion.tipo == tipo
      end)
  end

  def calcular_balances(transacciones, cuenta, monedas) do
    # [%Moneda{nombre_moneda: "BTC", precio_usd: 30000.0}] -> %{"BTC" => 30000.0}
    precios =
      Enum.into(monedas, %{}, fn %Ledger.Moneda{nombre_moneda: nombre, precio_usd: precio} ->
        {nombre, precio}
      end)

    Enum.reduce(transacciones, %{}, fn transaccion, acc ->
      case transaccion.tipo do
        "transferencia" ->
          acc =
            if transaccion.cuenta_origen == cuenta do
              Map.update(
                acc,
                transaccion.moneda_origen,
                -transaccion.monto,
                &(&1 - transaccion.monto)
              )
            else
              acc
            end

          acc =
            if transaccion.cuenta_destino == cuenta do
              Map.update(
                acc,
                transaccion.moneda_destino,
                transaccion.monto,
                &(&1 + transaccion.monto)
              )
            else
              acc
            end

          # IO.inspect(acc)
          acc

        "swap" ->
          if transaccion.cuenta_origen == cuenta do
            precio_origen = Map.get(precios, transaccion.moneda_origen)
            precio_destino = Map.get(precios, transaccion.moneda_destino)

            monto_usd = transaccion.monto * precio_origen
            monto_destino = monto_usd / precio_destino

            acc =
              acc
              |> Map.update(transaccion.moneda_origen, 0, &(&1 - transaccion.monto))

            nuevo_valor_destino = Map.get(acc, transaccion.moneda_destino, 0) + monto_destino

            Map.put(acc, transaccion.moneda_destino, nuevo_valor_destino)
          else
            acc
          end

        "alta_cuenta" ->
          acc =
            if transaccion.cuenta_origen == cuenta do
              Map.update(
                acc,
                transaccion.moneda_destino,
                transaccion.monto,
                &(&1 + transaccion.monto)
              )
            else
              acc
            end

          # IO.inspect(acc)
          acc
      end
    end)
  end

  def calcular_balance(transacciones, cuenta, nil, monedas) do
    balances = calcular_balances(transacciones, cuenta, monedas)

    balances
    |> Enum.map(fn {moneda, balance} ->
      "#{moneda}=#{:erlang.float_to_binary(balance, decimals: 6)}"
    end)
    |> Enum.join("\n")
  end

  def calcular_balance(transacciones, cuenta, moneda_objetivo, monedas) do
    balances = calcular_balances(transacciones, cuenta, monedas)

    precios =
      Enum.into(monedas, %{}, fn %Moneda{nombre_moneda: nombre, precio_usd: precio} ->
        {nombre, precio}
      end)

    if Map.has_key?(precios, moneda_objetivo) do
      total_en_objetivo =
        Enum.reduce(balances, 0.0, fn {moneda, balance}, acc ->
          if Map.has_key?(precios, moneda) do
            usd = balance * precios[moneda]
            acc + usd / precios[moneda_objetivo]
          else
            acc
          end
        end)

      "#{moneda_objetivo}=#{:erlang.float_to_binary(total_en_objetivo, decimals: 6)}"
    else
      {:error, :moneda_no_existente}
    end
  end
end
