defmodule LedgerTest do
  use ExUnit.Case
  doctest Ledger

  test "validad subcomando" do
    assert Ledger.Parser.validar_subcomando("crear_usuario") == {:ok, :crear_usuario}
    assert Ledger.Parser.validar_subcomando("editar_usuario") == {:ok, :editar_usuario}
    assert Ledger.Parser.validar_subcomando("borrar_usuario") == {:ok, :borrar_usuario}
    assert Ledger.Parser.validar_subcomando("ver_usuario") == {:ok, :ver_usuario}
    assert Ledger.Parser.validar_subcomando("crear_moneda") == {:ok, :crear_moneda}
    assert Ledger.Parser.validar_subcomando("editar_moneda") == {:ok, :editar_moneda}
    assert Ledger.Parser.validar_subcomando("borrar_moneda") == {:ok, :borrar_moneda}
    assert Ledger.Parser.validar_subcomando("ver_moneda") == {:ok, :ver_moneda}
    assert Ledger.Parser.validar_subcomando("alta_cuenta") == {:ok, :alta_cuenta}

    assert Ledger.Parser.validar_subcomando("realizar_transferencia") ==
             {:ok, :realizar_transferencia}

    assert Ledger.Parser.validar_subcomando("realizar_swap") == {:ok, :realizar_swap}

    assert Ledger.Parser.validar_subcomando("deshacer_transaccion") ==
             {:ok, :deshacer_transaccion}

    assert Ledger.Parser.validar_subcomando("ver_transaccion") == {:ok, :ver_transaccion}

    assert Ledger.Parser.validar_subcomando("subcomando_invalido") ==
             {:error, :subcomando_invalido}
  end

  test "validar opciones" do
    assert Ledger.Parser.validar_opciones(["-n=juan", "-b=2000-01-01"], :crear_usuario) ==
             {:ok, %{n: "juan", b: "2000-01-01"}}

    assert Ledger.Parser.validar_opciones(["-n=juan"], :crear_usuario) ==
             {:error, :faltan_parametros_obligatorios}

    assert Ledger.Parser.validar_opciones(["-id=5", "-n=juan2"], :editar_usuario) ==
             {:ok, %{id: 5, n: "juan2"}}

    assert Ledger.Parser.validar_opciones(["-x=5"], :editar_usuario) ==
             {:error, :parametro_invalido}

    assert Ledger.Parser.validar_opciones(["-id=10"], :borrar_usuario) ==
             {:ok, %{id: 10}}

    assert Ledger.Parser.validar_opciones(["-o=1", "-d=2", "-m=3"], :realizar_transferencia) ==
             {:ok, %{o: 1, d: 2, m: 3}}

    assert Ledger.Parser.validar_opciones(["-o=1", "-d=2"], :realizar_transferencia) ==
             {:error, :faltan_parametros_obligatorios}

    assert Ledger.Parser.validar_opciones([], :comando_desconocido) == {:ok, %{}}

    assert Ledger.Parser.validar_opciones(["-n=juan", "-b=2000-01-01"], :crear_usuario) ==
             {:ok, %{n: "juan", b: "2000-01-01"}}

    assert Ledger.Parser.validar_opciones(
             ["-n=juan", "-b=2000-01-01", "--extra=1"],
             :crear_usuario
           ) == {:error, :parametro_invalido}

    assert Ledger.Parser.validar_opciones(["-u=5", "-m=10"], :alta_cuenta) ==
             {:ok, %{u: 5, m: 10}}

    assert Ledger.Parser.validar_opciones(["-u=3", "-mo=1", "-md=2"], :realizar_swap) ==
             {:ok, %{u: 3, mo: 1, md: 2}}

    assert Ledger.Parser.validar_opciones(["-id=123"], :deshacer_transaccion) ==
             {:ok, %{id: 123}}

    assert Ledger.Parser.validar_opciones(["-id=456"], :ver_transaccion) ==
             {:ok, %{id: 456}}

    assert Ledger.Parser.validar_opciones(["-n=USD", "-p=1.0"], :crear_moneda) ==
             {:ok, %{n: "USD", p: 1.0}}

    assert Ledger.Parser.validar_opciones(["-id=2", "-p=123.45"], :editar_moneda) ==
             {:ok, %{id: 2, p: 123.45}}

    assert Ledger.Parser.validar_opciones(["-id=99"], :borrar_moneda) ==
             {:ok, %{id: 99}}

    assert Ledger.Parser.validar_opciones(["-id=77"], :ver_moneda) ==
             {:ok, %{id: 77}}

    assert Ledger.Parser.validar_opciones(["-id=42"], :ver_usuario) ==
             {:ok, %{id: 42}}

    assert Ledger.Parser.validar_opciones(["pepe"], :crear_usuario) ==
             {:error, :parametro_invalido}
  end
end
