defmodule Ledger.Parser do
  def validar_subcomando(subcomando) do
    case subcomando do
      "transacciones" -> {:ok, :transacciones}
      "balance" -> {:ok, :balance}
      _ -> {:error, :subcomando_invalido}
    end
  end
end
