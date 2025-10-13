defmodule Ledger do
  import Ecto.Query
  alias Ledger.Repo
  alias Ledger.Monedas.Monedas
  alias Ledger.Monedas.Moneda
  alias Ledger.Transacciones.Transacciones
  alias Ledger.Transacciones.Transaccion

  def filtrar_cuenta_origen(nil), do: Repo.all(Transacciones)

  def filtrar_cuenta_origen(cuenta_id) do
    query =
      from t in Transaccion,
        where: t.cuenta_origen_id == ^cuenta_id,
        select: t

    Repo.all(query)
  end

  def filtrar_cuenta_destino(nil), do: Repo.all(Transacciones)

  def filtrar_cuenta_destino(cuenta_id) do
    query =
      from t in Transaccion,
        where: t.cuenta_destino_id == ^cuenta_id,
        select: t

    Repo.all(query)
  end

  def filtrar_moneda(nil), do: Repo.all(Transacciones)

  def filtrar_moneda(moneda_id) do
    query =
      from t in Transaccion,
        where: t.moneda_origen_id == ^moneda_id or t.moneda_destino_id == ^moneda_id,
        select: t

    Repo.all(query)
  end

  def filtrar_tipo(tipo) do
    query =
      from t in Transaccion,
        where: t.tipo == ^tipo,
        select: t

    Repo.all(query)
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
