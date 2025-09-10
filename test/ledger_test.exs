defmodule LedgerTest do
  use ExUnit.Case
  doctest Ledger
  alias Ledger.Parser, as: Parser

  test "Validar subcomandos" do
    assert {:ok, :transacciones} == Parser.validar_subcomando("transacciones")
    assert {:ok, :balance} == Parser.validar_subcomando("balance")
    assert {:error, :subcomando_invalido} == Parser.validar_subcomando("otro")
  end

  test "Validar opciones" do
    assert {:ok, %{archivo_input: "test/fixtures/transacciones.csv"}} = Parser.validar_opciones([], :transacciones)
    assert {:ok, %{archivo_input: "input.csv"}} = Parser.validar_opciones(["-t=input.csv",], :transacciones)
    assert {:ok, %{archivo_input: "test/fixtures/transacciones.csv",
    archivo_output: "output.csv",
    cuenta_origen: "userA",
    cuenta_destino: "userB",
    moneda: "USD"}} = Parser.validar_opciones(["-o=output.csv", "-c1=userA", "-c2=userB", "-m=USD"], :transacciones)
    assert {:ok, %{cuenta_origen: "userA"}} = Parser.validar_opciones(["-c1=userA"], :balance)
    assert {:error, :parametro_invalido} = Parser.validar_opciones(["--c1=userA"], :transacciones)
    assert {:error, :parametro_invalido} = Parser.validar_opciones(["-x=algo"], :transacciones)
    assert {:error, :parametro_invalido} = Parser.validar_opciones(["dadada"], :transacciones)
    assert {:error, :falta_cuenta_origen} = Parser.validar_opciones([], :balance)
  end
end
