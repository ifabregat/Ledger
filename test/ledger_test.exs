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

  test "Leer csv" do
    assert {:ok, "Hola mundo"} = Parser.leer_csv("test/fixtures/leer1.csv")
    assert {:error, :error_leer_csv} = Parser.leer_csv("test/fixtures/inexistente.csv")
  end

  test "Parsear moneda" do
    {:ok, contenido} = Parser.leer_csv("test/fixtures/moneda.csv")
    assert {:ok, [
      %Ledger.Moneda{nombre_moneda: "BTC", precio_usd: 55000.0},
      %Ledger.Moneda{nombre_moneda: "ETH", precio_usd: 3000.0},
      %Ledger.Moneda{nombre_moneda: "ARS", precio_usd: 0.0012},
      %Ledger.Moneda{nombre_moneda: "USDT", precio_usd: 1.0},
      %Ledger.Moneda{nombre_moneda: "EUR", precio_usd: 1.18},
      %Ledger.Moneda{nombre_moneda: "DODGE", precio_usd: 0.08},
      %Ledger.Moneda{nombre_moneda: "SOL", precio_usd: 600.0},
      %Ledger.Moneda{nombre_moneda: "BRL", precio_usd: 0.2}
    ]} = Parser.parsear_moneda(contenido)
    {:ok, contenido2} = Parser.leer_csv("test/fixtures/moneda_mal.csv")
    assert {:error, {:precio_invalido, 3}} = Parser.parsear_moneda(contenido2)
    {:ok, contenido3} = Parser.leer_csv("test/fixtures/moneda_mal2.csv")
    assert {:error, {:formato_invalido, 2}} = Parser.parsear_moneda(contenido3)
  end
end
