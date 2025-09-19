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
    assert {:ok, %{archivo_input: "test/fixtures/transacciones.csv"}} =
             Parser.validar_opciones([], :transacciones)

    assert {:ok, %{archivo_input: "input.csv"}} =
             Parser.validar_opciones(["-t=input.csv"], :transacciones)

    assert {:ok,
            %{
              archivo_input: "test/fixtures/transacciones.csv",
              archivo_output: "output.csv",
              cuenta_origen: "userA",
              cuenta_destino: "userB",
              moneda: "USD"
            }} =
             Parser.validar_opciones(
               ["-o=output.csv", "-c1=userA", "-c2=userB", "-m=USD"],
               :transacciones
             )

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

    assert {:ok,
            [
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

  test "Parsear transaccion" do
    {:ok, contenido} = Parser.leer_csv("test/fixtures/transacciones.csv")

    assert {:ok,
            [
              %Ledger.Transaccion{
                id_transaccion: "1",
                timestamp: "1754937004",
                moneda_origen: "USDT",
                moneda_destino: "USDT",
                monto: 100.50,
                cuenta_origen: "userA",
                cuenta_destino: "userB",
                tipo: "transferencia"
              },
              %Ledger.Transaccion{
                id_transaccion: "2",
                timestamp: "1755541804",
                moneda_origen: "BTC",
                moneda_destino: "USDT",
                monto: 0.1,
                cuenta_origen: "userB",
                cuenta_destino: "",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "3",
                timestamp: "1756751404",
                moneda_origen: "BTC",
                moneda_destino: "",
                monto: 50000.0,
                cuenta_origen: "userC",
                cuenta_destino: "",
                tipo: "alta_cuenta"
              },
              %Ledger.Transaccion{
                id_transaccion: "4",
                timestamp: "1757002204",
                moneda_origen: "ETH",
                moneda_destino: "BTC",
                monto: 1.25,
                cuenta_origen: "userA",
                cuenta_destino: "userC",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "5",
                timestamp: "1757105804",
                moneda_origen: "EUR",
                moneda_destino: "USDT",
                monto: 250.0,
                cuenta_origen: "userD",
                cuenta_destino: "userB",
                tipo: "transferencia"
              },
              %Ledger.Transaccion{
                id_transaccion: "6",
                timestamp: "1757209404",
                moneda_origen: "ARS",
                moneda_destino: "",
                monto: 150_000.0,
                cuenta_origen: "userE",
                cuenta_destino: "",
                tipo: "alta_cuenta"
              },
              %Ledger.Transaccion{
                id_transaccion: "7",
                timestamp: "1757303004",
                moneda_origen: "USDT",
                moneda_destino: "ETH",
                monto: 75.0,
                cuenta_origen: "userB",
                cuenta_destino: "userD",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "8",
                timestamp: "1757406604",
                moneda_origen: "BTC",
                moneda_destino: "BTC",
                monto: 0.005,
                cuenta_origen: "userC",
                cuenta_destino: "userA",
                tipo: "transferencia"
              }
            ]} = Parser.parsear_transaccion(contenido)

    {:ok, contenido2} = Parser.leer_csv("test/fixtures/transacciones_mal.csv")
    assert {:error, {:formato_invalido, 3}} = Parser.parsear_transaccion(contenido2)
    {:ok, contenido3} = Parser.leer_csv("test/fixtures/transacciones_mal2.csv")
    assert {:error, {:monto_invalido, 5}} = Parser.parsear_transaccion(contenido3)
    {:ok, contenido4} = Parser.leer_csv("test/fixtures/transacciones_mal3.csv")
    assert {:error, {:tipo_invalido, 4}} = Parser.parsear_transaccion(contenido4)
    {:ok, contenido5} = Parser.leer_csv("test/fixtures/transacciones_mal4.csv")

    assert {:error, {:moneda_desconocida, 2}} =
             Parser.parsear_transaccion(contenido5, ["BTC", "USDT", "ETH", "ARS", "EUR"])
  end

  test "Mostrar salida" do
    assert {:ok, :mostrado} = Parser.mostrar_salida("Esto es una prueba")
  end

  test "Escribir salida" do
    assert {:ok, :escrito} =
             Parser.escribir_salida("test/fixtures/salida_test.csv", "Esto es una prueba")

    assert {:error, :error_escribir_csv} =
             Parser.escribir_salida("/ruta/invalida/salida_test.csv", "Esto es una prueba")
  end

  test "String moneda" do
    moneda = %Ledger.Moneda{nombre_moneda: "BTC", precio_usd: 55000.0}
    assert "BTC;55000.000000" = Parser.string_moneda(moneda)

    monedas = [
      %Ledger.Moneda{nombre_moneda: "BTC", precio_usd: 55000.0},
      %Ledger.Moneda{nombre_moneda: "ETH", precio_usd: 3000.0},
      %Ledger.Moneda{nombre_moneda: "ARS", precio_usd: 0.0012}
    ]

    assert "BTC;55000.000000\nETH;3000.000000\nARS;0.001200" = Parser.string_monedas(monedas)
  end

  test "String transaccion" do
    transaccion = %Ledger.Transaccion{
      id_transaccion: "1",
      timestamp: "1754937004",
      moneda_origen: "USDT",
      moneda_destino: "USDT",
      monto: 100.50,
      cuenta_origen: "userA",
      cuenta_destino: "userB",
      tipo: "transferencia"
    }

    assert "1;1754937004;USDT;USDT;100.500000;userA;userB;transferencia" =
             Parser.string_transaccion(transaccion)

    transacciones = [
      %Ledger.Transaccion{
        id_transaccion: "1",
        timestamp: "1754937004",
        moneda_origen: "USDT",
        moneda_destino: "USDT",
        monto: 100.50,
        cuenta_origen: "userA",
        cuenta_destino: "userB",
        tipo: "transferencia"
      },
      %Ledger.Transaccion{
        id_transaccion: "2",
        timestamp: "1755541804",
        moneda_origen: "BTC",
        moneda_destino: "USDT",
        monto: 0.1,
        cuenta_origen: "userB",
        cuenta_destino: "",
        tipo: "swap"
      },
      %Ledger.Transaccion{
        id_transaccion: "3",
        timestamp: "1756751404",
        moneda_origen: "BTC",
        moneda_destino: "",
        monto: 50000.0,
        cuenta_origen: "userC",
        cuenta_destino: "",
        tipo: "alta_cuenta"
      }
    ]

    assert "1;1754937004;USDT;USDT;100.500000;userA;userB;transferencia\n2;1755541804;BTC;USDT;0.100000;userB;;swap\n3;1756751404;BTC;;50000.000000;userC;;alta_cuenta" =
             Parser.string_transacciones(transacciones)
  end

  test "Filtrar cuenta origen" do
    {:ok, contenido} = Parser.leer_csv("test/fixtures/transacciones.csv")
    {:ok, transacciones} = Parser.parsear_transaccion(contenido)

    {:ok, filtradas} = Ledger.filtrar_cuenta_origen(transacciones, "userA")

    assert {:ok,
            [
              %Ledger.Transaccion{
                id_transaccion: "1",
                timestamp: "1754937004",
                moneda_origen: "USDT",
                moneda_destino: "USDT",
                monto: 100.5,
                cuenta_origen: "userA",
                cuenta_destino: "userB",
                tipo: "transferencia"
              },
              %Ledger.Transaccion{
                id_transaccion: "4",
                timestamp: "1757002204",
                moneda_origen: "ETH",
                moneda_destino: "BTC",
                monto: 1.25,
                cuenta_origen: "userA",
                cuenta_destino: "userC",
                tipo: "swap"
              }
            ]} = {:ok, filtradas}

    {:ok, todas} = Ledger.filtrar_cuenta_origen(transacciones, nil)

    assert {:ok,
            [
              %Ledger.Transaccion{
                id_transaccion: "1",
                timestamp: "1754937004",
                moneda_origen: "USDT",
                moneda_destino: "USDT",
                monto: 100.5,
                cuenta_origen: "userA",
                cuenta_destino: "userB",
                tipo: "transferencia"
              },
              %Ledger.Transaccion{
                id_transaccion: "2",
                timestamp: "1755541804",
                moneda_origen: "BTC",
                moneda_destino: "USDT",
                monto: 0.1,
                cuenta_origen: "userB",
                cuenta_destino: "",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "3",
                timestamp: "1756751404",
                moneda_origen: "BTC",
                moneda_destino: "",
                monto: 50000.0,
                cuenta_origen: "userC",
                cuenta_destino: "",
                tipo: "alta_cuenta"
              },
              %Ledger.Transaccion{
                id_transaccion: "4",
                timestamp: "1757002204",
                moneda_origen: "ETH",
                moneda_destino: "BTC",
                monto: 1.25,
                cuenta_origen: "userA",
                cuenta_destino: "userC",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "5",
                timestamp: "1757105804",
                moneda_origen: "EUR",
                moneda_destino: "USDT",
                monto: 250.0,
                cuenta_origen: "userD",
                cuenta_destino: "userB",
                tipo: "transferencia"
              },
              %Ledger.Transaccion{
                id_transaccion: "6",
                timestamp: "1757209404",
                moneda_origen: "ARS",
                moneda_destino: "",
                monto: 150_000.0,
                cuenta_origen: "userE",
                cuenta_destino: "",
                tipo: "alta_cuenta"
              },
              %Ledger.Transaccion{
                id_transaccion: "7",
                timestamp: "1757303004",
                moneda_origen: "USDT",
                moneda_destino: "ETH",
                monto: 75.0,
                cuenta_origen: "userB",
                cuenta_destino: "userD",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "8",
                timestamp: "1757406604",
                moneda_origen: "BTC",
                moneda_destino: "BTC",
                monto: 0.005,
                cuenta_origen: "userC",
                cuenta_destino: "userA",
                tipo: "transferencia"
              }
            ]} = {:ok, todas}

    assert {:ok, []} =
             Ledger.filtrar_cuenta_origen(transacciones, "cuenta_inexistente")
  end

  test "Filtrar cuenta destino" do
    {:ok, contenido} = Parser.leer_csv("test/fixtures/transacciones.csv")
    {:ok, transacciones} = Parser.parsear_transaccion(contenido)

    {:ok, filtradas} = Ledger.filtrar_cuenta_destino(transacciones, "userB")

    assert {:ok,
            [
              %Ledger.Transaccion{
                id_transaccion: "1",
                timestamp: "1754937004",
                moneda_origen: "USDT",
                moneda_destino: "USDT",
                monto: 100.5,
                cuenta_origen: "userA",
                cuenta_destino: "userB",
                tipo: "transferencia"
              },
              %Ledger.Transaccion{
                id_transaccion: "5",
                timestamp: "1757105804",
                moneda_origen: "EUR",
                moneda_destino: "USDT",
                monto: 250.0,
                cuenta_origen: "userD",
                cuenta_destino: "userB",
                tipo: "transferencia"
              }
            ]} = {:ok, filtradas}

    {:ok, todas} = Ledger.filtrar_cuenta_destino(transacciones, nil)

    assert {:ok,
            [
              %Ledger.Transaccion{
                id_transaccion: "1",
                timestamp: "1754937004",
                moneda_origen: "USDT",
                moneda_destino: "USDT",
                monto: 100.5,
                cuenta_origen: "userA",
                cuenta_destino: "userB",
                tipo: "transferencia"
              },
              %Ledger.Transaccion{
                id_transaccion: "2",
                timestamp: "1755541804",
                moneda_origen: "BTC",
                moneda_destino: "USDT",
                monto: 0.1,
                cuenta_origen: "userB",
                cuenta_destino: "",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "3",
                timestamp: "1756751404",
                moneda_origen: "BTC",
                moneda_destino: "",
                monto: 50000.0,
                cuenta_origen: "userC",
                cuenta_destino: "",
                tipo: "alta_cuenta"
              },
              %Ledger.Transaccion{
                id_transaccion: "4",
                timestamp: "1757002204",
                moneda_origen: "ETH",
                moneda_destino: "BTC",
                monto: 1.25,
                cuenta_origen: "userA",
                cuenta_destino: "userC",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "5",
                timestamp: "1757105804",
                moneda_origen: "EUR",
                moneda_destino: "USDT",
                monto: 250.0,
                cuenta_origen: "userD",
                cuenta_destino: "userB",
                tipo: "transferencia"
              },
              %Ledger.Transaccion{
                id_transaccion: "6",
                timestamp: "1757209404",
                moneda_origen: "ARS",
                moneda_destino: "",
                monto: 150_000.0,
                cuenta_origen: "userE",
                cuenta_destino: "",
                tipo: "alta_cuenta"
              },
              %Ledger.Transaccion{
                id_transaccion: "7",
                timestamp: "1757303004",
                moneda_origen: "USDT",
                moneda_destino: "ETH",
                monto: 75.0,
                cuenta_origen: "userB",
                cuenta_destino: "userD",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "8",
                timestamp: "1757406604",
                moneda_origen: "BTC",
                moneda_destino: "BTC",
                monto: 0.005,
                cuenta_origen: "userC",
                cuenta_destino: "userA",
                tipo: "transferencia"
              }
            ]} = {:ok, todas}

    assert {:ok, []} =
             Ledger.filtrar_cuenta_destino(transacciones, "otra_cuenta_inexistente")
  end

  test "Filtrar moneda" do
    {:ok, contenido} = Parser.leer_csv("test/fixtures/transacciones.csv")
    {:ok, transacciones} = Parser.parsear_transaccion(contenido)

    {:ok, filtradas} = Ledger.filtrar_moneda(transacciones, "BTC")

    assert {:ok,
            [
              %Ledger.Transaccion{
                id_transaccion: "2",
                timestamp: "1755541804",
                moneda_origen: "BTC",
                moneda_destino: "USDT",
                monto: 0.1,
                cuenta_origen: "userB",
                cuenta_destino: "",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "3",
                timestamp: "1756751404",
                moneda_origen: "BTC",
                moneda_destino: "",
                monto: 50000.0,
                cuenta_origen: "userC",
                cuenta_destino: "",
                tipo: "alta_cuenta"
              },
              %Ledger.Transaccion{
                id_transaccion: "4",
                timestamp: "1757002204",
                moneda_origen: "ETH",
                moneda_destino: "BTC",
                monto: 1.25,
                cuenta_origen: "userA",
                cuenta_destino: "userC",
                tipo: "swap"
              },
              %Ledger.Transaccion{
                id_transaccion: "8",
                timestamp: "1757406604",
                moneda_origen: "BTC",
                moneda_destino: "BTC",
                monto: 0.005,
                cuenta_origen: "userC",
                cuenta_destino: "userA",
                tipo: "transferencia"
              }
            ]} = {:ok, filtradas}

    {:ok, todas} = Ledger.filtrar_moneda(transacciones, nil)

    assert {:ok, []} = {:ok, todas}
  end

  test "Calcular balances" do
    monedas = [
      %Ledger.Moneda{nombre_moneda: "BTC", precio_usd: 55000.0},
      %Ledger.Moneda{nombre_moneda: "ETH", precio_usd: 3000.0},
      %Ledger.Moneda{nombre_moneda: "ARS", precio_usd: 0.0012},
      %Ledger.Moneda{nombre_moneda: "USDT", precio_usd: 1.0},
    ]

    balance = Ledger.calcular_balances([], "userA", monedas)
    assert %{} = balance

    transacciones = [
      %Ledger.Transaccion{
        id_transaccion: "1",
        timestamp: "1754937004",
        moneda_origen: "USDT",
        moneda_destino: "USDT",
        monto: 100.50,
        cuenta_origen: "userA",
        cuenta_destino: "userB",
        tipo: "transferencia"
      },
      %{
        id_transaccion: "2",
        timestamp: "1754937004",
        moneda_origen: "USDT",
        moneda_destino: "USDT",
        monto: 100.50,
        cuenta_origen: "userA",
        cuenta_destino: "userC",
        tipo: "transferencia"
      },
      %{
        id_transaccion: "3",
        timestamp: "1754937004",
        moneda_origen: "USDT",
        moneda_destino: "USDT",
        monto: 100.50,
        cuenta_origen: "userB",
        cuenta_destino: "userA",
        tipo: "transferencia"
      }
    ]

    balance = Ledger.calcular_balances(transacciones, "userA", monedas)
    assert %{"USDT" => -100.5} = balance

    balance = Ledger.calcular_balances(transacciones, "userB", monedas)
    assert %{"USDT" => 0.0} = balance

    balance = Ledger.calcular_balances(transacciones, "userD", monedas)
    assert %{} = balance

    transacciones = [
      %Ledger.Transaccion{
        id_transaccion: "1",
        timestamp: "1754937004",
        moneda_origen: "USDT",
        moneda_destino: "USDT",
        monto: 100.50,
        cuenta_origen: "userA",
        cuenta_destino: "userB",
        tipo: "transferencia"
      },
      %Ledger.Transaccion{
        id_transaccion: "2",
        timestamp: "1755541804",
        moneda_origen: "BTC",
        moneda_destino: "USDT",
        monto: 0.1,
        cuenta_origen: "userB",
        cuenta_destino: "",
        tipo: "swap"
      }
    ]

    balance = Ledger.calcular_balances(transacciones, "userB", monedas)
    assert %{"USDT" => 5600.5} = balance

    balance = Ledger.calcular_balances(transacciones, "userC", monedas)
    assert %{} = balance

    transacciones = [
      %Ledger.Transaccion{
        id_transaccion: "1",
        timestamp: "1754000000",
        moneda_origen: "BTC",
        moneda_destino: "BTC",
        monto: 1000.0,
        cuenta_origen: "otra_cuenta",
        cuenta_destino: "userC",
        tipo: "transferencia"
      },
      %Ledger.Transaccion{
        id_transaccion: "2",
        timestamp: "1756751404",
        moneda_origen: "BTC",
        moneda_destino: "BTC",
        monto: 50000.0,
        cuenta_origen: "userC",
        cuenta_destino: "",
        tipo: "alta_cuenta"
      },
      %Ledger.Transaccion{
        id_transaccion: "3",
        timestamp: "1754937004",
        moneda_origen: "USDT",
        moneda_destino: "USDT",
        monto: 100.50,
        cuenta_origen: "userA",
        cuenta_destino: "userB",
        tipo: "transferencia"
      },
      %Ledger.Transaccion{
        id_transaccion: "4",
        timestamp: "1755541804",
        moneda_origen: "BTC",
        moneda_destino: "USDT",
        monto: 0.1,
        cuenta_origen: "userB",
        cuenta_destino: "",
        tipo: "swap"
      }
    ]

    balance = Ledger.calcular_balances(transacciones, "userA", monedas)
    assert %{} = balance

    balance = Ledger.calcular_balances(transacciones, "userC", monedas)
    assert %{} = balance

    balance = Ledger.calcular_balance(transacciones, "userA", nil, monedas)
    assert "USDT=-100.500000" = balance

    balance = Ledger.calcular_balance(transacciones, "userA", "USDT", monedas)
    assert "USDT=-100.500000" = balance

    transacciones = [
      %Ledger.Transaccion{
        tipo: "transferencia",
        cuenta_origen: "userA",
        cuenta_destino: "userB",
        moneda_origen: "PEPE",
        moneda_destino: "USDT",
        monto: 100.0
      }
    ]

    balance = Ledger.calcular_balance(transacciones, "userA", "USDT", monedas)
    assert "USDT=0.000000" = balance

    balance = Ledger.calcular_balance(transacciones, "userA", "EUR", monedas)
    assert {:error, :moneda_no_existente} = balance
  end
end
