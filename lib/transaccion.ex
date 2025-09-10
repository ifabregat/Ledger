defmodule Ledger.Transaccion do
  defstruct [
    :id_transaccion,
    :timestamp,
    :moneda_origen,
    :moneda_destino,
    :monto,
    :cuenta_origen,
    :cuenta_destino,
    :tipo
  ]
end
