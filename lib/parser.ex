defmodule Ledger.Parser do
  def validar_subcomando(subcomando) do
    case subcomando do
      "crear_usuario" -> {:ok, :crear_usuario}
      "editar_usuario" -> {:ok, :editar_usuario}
      "borrar_usuario" -> {:ok, :borrar_usuario}
      "ver_usuario" -> {:ok, :ver_usuario}
      "crear_moneda" -> {:ok, :crear_moneda}
      "editar_moneda" -> {:ok, :editar_moneda}
      "borrar_moneda" -> {:ok, :borrar_moneda}
      "ver_moneda" -> {:ok, :ver_moneda}
      "alta_cuenta" -> {:ok, :alta_cuenta}
      "realizar_transferencia" -> {:ok, :realizar_transferencia}
      "realizar_swap" -> {:ok, :realizar_swap}
      "deshacer_transaccion" -> {:ok, :deshacer_transaccion}
      "ver_transaccion" -> {:ok, :ver_transaccion}
      _ -> {:error, :subcomando_invalido}
    end
  end

  def validar_opciones(opciones, subcomando) do
    opciones =
      Enum.map(opciones, fn
        "-" <> resto -> "--" <> resto
        other -> other
      end)

    {estrictos, obligatorios} =
      case subcomando do
        :crear_usuario -> {[n: :string, b: :string], [:n, :b]}
        :editar_usuario -> {[id: :integer, n: :string], [:id, :n]}
        :borrar_usuario -> {[id: :integer], [:id]}
        :ver_usuario -> {[id: :integer], [:id]}
        :crear_moneda -> {[n: :string, p: :float], [:n, :p]}
        :editar_moneda -> {[id: :integer, p: :float], [:id, :p]}
        :borrar_moneda -> {[id: :integer], [:id]}
        :ver_moneda -> {[id: :integer], [:id]}
        :alta_cuenta -> {[u: :integer, m: :integer], [:u, :m]}
        :realizar_transferencia -> {[o: :integer, d: :integer, m: :integer], [:o, :d, :m]}
        :realizar_swap -> {[u: :integer, mo: :integer, md: :integer], [:u, :mo, :md]}
        :deshacer_transaccion -> {[id: :integer], [:id]}
        :ver_transaccion -> {[id: :integer], [:id]}
        _ -> {[], []}
      end

    {opciones, resto, invalidos} = OptionParser.parse(opciones, strict: estrictos)

    opciones = Enum.into(opciones, %{})

    IO.inspect(opciones, label: "Opciones parseadas")

    cond do
      resto != [] or invalidos != [] ->
        {:error, :parametro_invalido}

      not Enum.all?(obligatorios, &Map.has_key?(opciones, &1)) ->
        {:error, :faltan_parametros_obligatorios}

      true ->
        {:ok, opciones}
    end
  end
end
