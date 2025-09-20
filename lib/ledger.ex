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

    case filtradas do
      [] -> {:ok, []}
      _ -> {:ok, filtradas}
    end
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

          acc

        "swap" ->
          acc =
            if transaccion.cuenta_origen == cuenta do
              precio_origen = Map.get(precios, transaccion.moneda_origen, 0)
              precio_destino = Map.get(precios, transaccion.moneda_destino, 0)

              monto_usd = transaccion.monto * precio_origen
              monto_destino = if precio_destino > 0, do: monto_usd / precio_destino, else: 0

              origen_actual = Map.get(acc, transaccion.moneda_origen, 0)
              destino_actual = Map.get(acc, transaccion.moneda_destino, 0)

              acc
              |> Map.put(transaccion.moneda_origen, origen_actual - transaccion.monto)
              |> Map.put(transaccion.moneda_destino, destino_actual + monto_destino)
            else
              acc
            end

          acc =
            if transaccion.cuenta_destino == cuenta do
              precio_origen = Map.get(precios, transaccion.moneda_origen, 0)
              precio_destino = Map.get(precios, transaccion.moneda_destino, 0)

              monto_usd = transaccion.monto * precio_origen
              monto_destino = if precio_destino > 0, do: monto_usd / precio_destino, else: 0

              origen_actual = Map.get(acc, transaccion.moneda_origen, 0)
              destino_actual = Map.get(acc, transaccion.moneda_destino, 0)

              acc
              |> Map.put(transaccion.moneda_origen, origen_actual + transaccion.monto)
              |> Map.put(transaccion.moneda_destino, destino_actual - monto_destino)
            else
              acc
            end

          acc

        "alta_cuenta" ->
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
      end
    end)
  end

  def calcular_balance(transacciones, cuenta, nil, monedas) do
    balances = calcular_balances(transacciones, cuenta, monedas)

    balances
    |> Enum.map(fn {moneda, balance} ->
      "#{moneda}=#{:erlang.float_to_binary(balance * 1.0, decimals: 6)}"
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
      total_usd =
        Enum.reduce(balances, 0.0, fn {moneda, balance}, acc ->
          precio = Map.get(precios, moneda, 0)

          acc + balance * precio
        end)

      precio_objetivo = precios[moneda_objetivo]

      total_en_objetivo = if precio_objetivo > 0, do: total_usd / precio_objetivo, else: 0

      "#{moneda_objetivo}=#{:erlang.float_to_binary(total_en_objetivo, decimals: 6)}"
    else
      {:error, :moneda_no_existente}
    end
  end
end
