defmodule LedgerTest do
  use ExUnit.Case
  doctest Ledger
  alias Ledger.Parser, as: Parser

  test "Validar subcomandos" do
    assert {:ok, :transacciones} == Parser.validar_subcomando("transacciones")
    assert {:ok, :balance} == Parser.validar_subcomando("balance")
    assert {:error, :subcomando_invalido} == Parser.validar_subcomando("otro")
  end
  end
