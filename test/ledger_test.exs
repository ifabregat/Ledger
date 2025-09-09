defmodule LedgerTest do
  use ExUnit.Case
  doctest Ledger
  alias Ledger.Parser, as: Parser

  test "Comprobar sub-comando validos" do
    arg = "transacciones"
    assert {:ok, :transacciones} = Parser.obtener_subcomando(arg)

    arg = "balance"
    assert {:ok, :balance} = Parser.obtener_subcomando(arg)
  end

  test "Comprobar sub-comando invalidos" do
    arg = ["otra cosa"]
    assert {:error, :sub_comando_invalido} = Parser.obtener_subcomando(arg)

    arg = "otra cosa"
    assert {:error, :sub_comando_invalido} = Parser.obtener_subcomando(arg)
  end

  test "Comprobar parametros validos" do
    flag = ["-t=/home/ifabregat/Escritorio/prueba.csv", "-o=salida.txt", "-c1=A", "-c2=B", "-m=USD"]
    {:ok, mapa} = Parser.obtener_flags(flag, :transacciones)
    assert mapa == %{
      archivo_input: "/home/ifabregat/Escritorio/prueba.csv",
      archivo_output: "salida.txt",
      cuenta_origen: "A",
      cuenta_destino: "B",
      moneda: "USD"
    }

    flag = []
    {:ok, mapa} = Parser.obtener_flags(flag, :transacciones)
    assert mapa == %{
      archivo_input: "transacciones.csv",
      archivo_output: nil,
      cuenta_origen: nil,
      cuenta_destino: nil,
      moneda: nil
    }

    {:ok, mapa} = Parser.obtener_flags(["archivo_suelto.csv"], :transacciones)
    assert mapa.archivo_input == "transacciones.csv"

    {:ok, mapa} = Parser.obtener_flags(["-c1=A"], :balance)
    assert mapa.archivo_input == "transacciones.csv"
  end

  test "Comprobar parametros invalidos" do
    flag = ["-c3=B"]
    assert {:error, :parametro_invalido} = Parser.obtener_flags(flag, nil)

    flag = ["-c1=A", "-c3=A"]
    assert {:error, :parametro_invalido} = Parser.obtener_flags(flag, nil)

    assert {:error, :c1_obligatorio} = Parser.obtener_flags([], :balance)
  end

  test "Comprobar lectura de archivo valido" do
    path = "test/fixtures/transacciones.csv"
    assert {:ok, _contenido} = Parser.leer_transacciones(path)
  end

  test "Comprobar lectura de archivo invalido" do
    path = "/home/ifabregat/Escritorio/prueba.csv"
    assert {:error, _error} = Parser.leer_transacciones(path)
  end

  test "Comprobar escritura en archivo" do
    path = "test/fixtures/salida_prueba.txt"
    contenido = "Hola mundo"
    assert {:ok, _mensaje} = Parser.escribir_salida(path, contenido)

    path = nil
    assert {:ok, _mensaje} = Parser.escribir_salida(path, contenido)
  end

  test "Comprobar escritura en archivo invalido" do
    path = "/root/salida_prueba.txt"
    contenido = "Hola mundo"
    assert {:error, _mensaje} = Parser.escribir_salida(path, contenido)
  end
  end
