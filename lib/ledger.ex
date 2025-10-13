defmodule Ledger do
  alias Ledger.Repo
  alias Ledger.Monedas.Monedas
  alias Ledger.Monedas.Moneda
  alias Ledger.Transacciones.Transacciones
  alias Ledger.Transacciones.Transaccion

  def listar_transacciones(filtros) do
    transacciones = Repo.all(Transaccion)

    transacciones
    |> filtrar_cuenta_origen(Map.get(filtros, :cuenta_origen_id))
    |> filtrar_cuenta_destino(Map.get(filtros, :cuenta_destino_id))
    |> filtrar_moneda_por_nombre(Map.get(filtros, :moneda_nombre))
    |> filtrar_tipo(Map.get(filtros, :tipo))
  end

  def filtrar_cuenta_origen(transacciones, nil), do: transacciones

  def filtrar_cuenta_origen(transacciones, cuenta_id) do
    Enum.filter(transacciones, fn t -> t.cuenta_origen_id == cuenta_id end)
  end

  def filtrar_cuenta_destino(transacciones, nil), do: transacciones

  def filtrar_cuenta_destino(transacciones, cuenta_id) do
    Enum.filter(transacciones, fn t -> t.cuenta_destino_id == cuenta_id end)
  end

  def filtrar_moneda_por_nombre(transacciones, nil), do: transacciones

  def filtrar_moneda_por_nombre(transacciones, nombre) do
    mapa_monedas =
      Repo.all(Moneda)
      |> Enum.into(%{}, fn m -> {m.id, m.nombre} end)

    Enum.filter(transacciones, fn t ->
      moneda_origen = mapa_monedas[t.moneda_origen_id]
      moneda_destino = mapa_monedas[t.moneda_destino_id]

      moneda_origen == nombre || moneda_destino == nombre
    end)
  end

  def filtrar_tipo(transacciones, nil), do: transacciones

  def filtrar_tipo(transacciones, tipo) do
    Enum.filter(transacciones, fn t -> t.tipo == tipo end)
  end

  def calcular_balances(cuenta_id) do
    transacciones = Repo.all(Transacciones)
    monedas = Repo.all(Monedas)

    precios =
      Enum.into(monedas, %{}, fn %Moneda{nombre: nombre, precio_dolares: precio} ->
        {nombre, Decimal.to_float(precio)}
      end)

    Enum.reduce(transacciones, %{}, fn t, acc ->
      case t.tipo do
        "transferencia" ->
          acc
          |> actualizar_balance_transferencia(t, cuenta_id)

        "swap" ->
          acc
          |> actualizar_balance_swap(t, cuenta_id, precios)

        "alta" ->
          if t.cuenta_destino_id == cuenta_id do
            Map.update(acc, t.moneda_destino_id, t.monto, &(&1 + t.monto))
          else
            acc
          end

        _ ->
          acc
      end
    end)
  end

  def calcular_balance(cuenta_id, nil) do
    balances = calcular_balances(cuenta_id)

    balances
    |> Enum.map(fn {moneda_id, balance} ->
      moneda = Repo.get(Moneda, moneda_id)
      nombre = (moneda && moneda.nombre) || "Desconocida"
      "#{nombre}=#{:erlang.float_to_binary(balance * 1.0, decimals: 6)}"
    end)
    |> Enum.join(", ")
  end

  def calcular_balance(cuenta_id, moneda_id) do
    balances = calcular_balances(cuenta_id)
    monedas = Repo.all(Monedas)

    precios =
      Enum.into(monedas, %{}, fn %Moneda{nombre: nombre, precio_dolares: precio} ->
        {nombre, Decimal.to_float(precio)}
      end)

    if Map.has_key?(precios, moneda_id) do
      total_usd =
        Enum.reduce(balances, 0.0, fn {moneda_id, balance}, acc ->
          moneda = Repo.get(Moneda, moneda_id)
          precio = if moneda, do: Decimal.to_float(moneda.precio_dolares), else: 0.0
          acc + balance * precio
        end)

      precio_objetivo = precios[moneda_id]
      total_en_objetivo = if precio_objetivo > 0, do: total_usd / precio_objetivo, else: 0.0
      "#{moneda_id}=#{:erlang.float_to_binary(total_en_objetivo, decimals: 6)}"
    else
      {:error, "Moneda no encontrada"}
    end
  end

  defp actualizar_balance_transferencia(acc, t, cuenta_id) do
    cond do
      t.cuenta_origen_id == cuenta_id ->
        Map.update(acc, t.moneda_origen_id, -t.monto, &(&1 - t.monto))

      t.cuenta_destino_id == cuenta_id ->
        Map.update(acc, t.moneda_destino_id, t.monto, &(&1 + t.monto))

      true ->
        acc
    end
  end

  defp actualizar_balance_swap(acc, t, cuenta_id, precios) do
    moneda_origen = Repo.get(Monedas, t.moneda_origen_id)
    moneda_destino = Repo.get(Monedas, t.moneda_destino_id)

    precio_origen = precios[moneda_origen.nombre] || 0.0
    precio_destino = precios[moneda_destino.nombre] || 0.0

    monto_usd = t.monto * precio_origen
    monto_destino = if precio_destino > 0, do: monto_usd / precio_destino, else: 0.0

    if t.cuenta_destino_id == cuenta_id do
      acc
      |> Map.update(t.moneda_origen_id, -t.monto, &(&1 - t.monto))
      |> Map.update(t.moneda_destino_id, monto_destino, &(&1 + monto_destino))
    else
      acc
    end
  end
end
