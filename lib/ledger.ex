defmodule Ledger do
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
end
