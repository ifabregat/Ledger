defmodule Ledger.Parser do
  @moduledoc """
  Modulo para manejar validacion de comandos y archivos
  """

  def obtener_subcomando([sub_comando | _flags]) do
    case sub_comando do
      "transacciones" -> {:ok, "transacciones"}
      "balance" -> {:ok, "balance"}
      _ -> {:error, "sub comando desconocido"}
    end
  end
end
