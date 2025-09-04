defmodule Ledger.Parser do
  @moduledoc """
  Modulo para manejar validacion de comandos y archivos
  """

  def obtener_subcomando(sub_comando) do
    case sub_comando do
      "transacciones" -> {:ok, "transacciones"}
      "balance" -> {:ok, "balance"}
      _ -> {:error, "sub comando desconocido"}
    end
  end

  def obtener_flags(flags) do
    # flags = ["-c2=userA", "-c1=userB"]

    flags = Enum.map(flags, fn
      "-" <> rest -> "--" <> rest
      other -> other
    end)

    # flags = ["--c2=userA", "--c1=userB"]

    {opciones, _resto, invalidos} = OptionParser.parse(flags,
      strict: [t: :string, o: :string, c1: :string, c2: :string, m: :string]
    )

    if invalidos != [] do
      {:error, "parametro invalido"}
    else
      mapa = %{
      archivo_input: opciones[:t] || "test/fixtures/transacciones.csv",
      archivo_output: opciones[:o],
      cuenta_origen: opciones[:c1],
      cuenta_destino: opciones[:c2],
      moneda: opciones[:m]
      }

      {:ok, mapa}
    end
  end

  def leer_transacciones(path) do
    case File.read(path) do
      {:ok, contenido} -> {:ok, contenido}
      {:error, error} -> {:error, error}
    end
  end

  def escribir_salida(path, contenido) do
    if path != nil do
      case File.write(path, contenido) do
        :ok -> {:ok, contenido}
        {:error, error} -> {:error, error}
      end
    else
      IO.puts(contenido)
      {:ok, contenido}
    end
  end
end
