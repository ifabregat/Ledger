defmodule ExampleApp.CLI do
  alias Ledger.Parser, as: Parser

  def main(args \\ []) do
    [sub_comando | flags] = args
    Parser.obtener_subcomando(sub_comando) |> IO.inspect()
    Parser.obtener_flags(flags) |> IO.inspect()
  end
end
