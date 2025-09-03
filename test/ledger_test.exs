defmodule LedgerTest do
  use ExUnit.Case
  doctest Ledger
  alias Ledger.Parser, as: Parser

  test "Comprobar sub-comando validos" do
    arg = "transacciones"
    assert {:ok, _mensaje} = Parser.obtener_subcomando(arg)

    arg = "balance"
    assert {:ok, _mensaje} = Parser.obtener_subcomando(arg)
  end

  test "Comprobar sub-comando invalidos" do
    arg = ["otra cosa"]
    assert {:error, _mensaje} = Parser.obtener_subcomando(arg)
  end

  test "Comprobar parametros validos" do
    flag = ["-c1=A"]
    assert {:ok, _mensaje} = Parser.obtener_flags(flag)

    flag = ["-t=/home/ifabregat/Escritorio/prueba.csv", "-c1=A"]
    assert {:ok, _mensaje} = Parser.obtener_flags(flag)

    flag = []
    assert {:ok, _mensaje} = Parser.obtener_flags(flag)
  end

  test "Comprobar parametros invalidos" do
    flag = ["-c3=B"]
    assert {:error, _mensaje} = Parser.obtener_flags(flag)

    flag = ["-c1=A", "-c3=A"]
    assert {:error, _mensaje} = Parser.obtener_flags(flag)
  end
  end
