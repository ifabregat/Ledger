defmodule Ledger.Parser do
  def validar_subcomando(subcomando) do
    case subcomando do
      "transacciones" -> {:ok, :transacciones}
      "balance" -> {:ok, :balance}
      _ -> {:error, :subcomando_invalido}
    end
  end

  def validar_opciones(opciones, subcomando) do
    # opciones = ["-c1=userA", "-c2=userB"]

    opciones = Enum.map(opciones,
    fn "-" <> resto -> "--" <> resto
    other -> other end)

    # opciones = ["--c1=userA", "--c2=userB"]

    {opciones, resto, invalidos} = OptionParser.parse(opciones,
      strict: [t: :string, o: :string, c1: :string, c2: :string, m: :string])

    case {resto, invalidos} do
      {[], []} ->
        mapa_opciones = %{
          archivo_input: opciones[:t] || "test/fixtures/transacciones.csv",
          archivo_output: opciones[:o],
          cuenta_origen: opciones[:c1],
          cuenta_destino: opciones[:c2],
          moneda: opciones[:m]
        }

        case {subcomando, mapa_opciones.cuenta_origen} do
          {:balance, nil} -> {:error, :falta_cuenta_origen}
          _ -> {:ok, mapa_opciones}
        end

      _ ->
        {:error, :parametro_invalido}
    end
  end

  def leer_csv(path) do
    case File.read(path) do
      {:ok, contenido} -> {:ok, contenido}
      {:error, _error} -> {:error, :error_leer_csv}
    end
  end
end
