defmodule LedgerTest do
  use ExUnit.Case
  doctest Ledger
  alias Ledger.Parser, as: Parser

  test "Comprobar sub-comando validos" do
    arg = ["transacciones"]
    assert {:ok, "transacciones"} = Parser.obtener_subcomando(arg)

    arg = ["balance"]
    assert {:ok, "balance"} = Parser.obtener_subcomando(arg)
  end

  test "Comprobar sub-comando invalidos" do
    arg = ["otra cosa"]
    assert {:error, "sub comando desconocido"} = Parser.obtener_subcomando(arg)
  end
end
