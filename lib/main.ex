defmodule ExampleApp.CLI do
  alias Ledger.Usuarios.Usuarios

  def main(args \\ []) do
    args = normalizar_args(args)

    case args do
      [comando | flags] ->
        {opts, _, _invalidos} =
          OptionParser.parse(flags,
            strict: [nombre: :string, fecha_nacimiento: :string, id: :integer],
            aliases: [n: :nombre, b: :fecha_nacimiento]
          )

        ejecutar_comando(comando, opts)

      [] ->
        IO.puts("Falta el comando")
    end
  end

  defp normalizar_args(args) do
    Enum.flat_map(args, fn
      # solo id necesita ser convertido a opción larga
      "-id=" <> valor -> ["--id", valor]
      # otras letras se mantienen como están
      <<"-", _::binary>> = flag -> [flag]
      otro -> [otro]
    end)
  end

  defp ejecutar_comando("crear_usuario", opts) do
    attrs = %{
      "nombre" => Keyword.get(opts, :nombre),
      "fecha_nacimiento" => Keyword.get(opts, :fecha_nacimiento)
    }

    resultado =
      case attrs do
        %{"nombre" => nil} ->
          {:error, "Falta el nombre de usuario (-n)"}

        %{"fecha_nacimiento" => nil} ->
          {:error, "Falta la fecha de nacimiento (-b)"}

        _ ->
          Usuarios.crear_usuario(attrs)
      end

    handle_response(resultado, :crear_usuario)
  end

  defp ejecutar_comando("ver_usuario", opts) do
    case Keyword.get(opts, :id) do
      nil ->
        handle_response({:error, "Falta el id (-id)"}, :ver_usuario)

      id ->
        Usuarios.ver_usuario(id)
        |> handle_response(:ver_usuario)
    end
  end

  defp ejecutar_comando("editar_usuario", opts) do
    resultado =
      case Keyword.get(opts, :id) do
        nil ->
          {:error, "Falta el id (-id)"}

        id ->
          case Keyword.get(opts, :nombre) do
            nil ->
              {:error, "Falta el nombre (-n)"}

            nombre ->
              attrs = %{"nombre" => nombre}
              Usuarios.editar_usuario(id, attrs)
          end
      end

    handle_response(resultado, :editar_usuario)
  end

  defp ejecutar_comando("borrar_usuario", opts) do
    resultado =
      case Keyword.get(opts, :id) do
        nil ->
          {:error, "Falta el parámetro id (-id)"}

        id ->
          Usuarios.borrar_usuario(id)
      end

    handle_response(resultado, :borrar_usuario)
  end

  defp handle_response({:ok, usuario}, :ver_usuario) do
    IO.puts("--- Detalles del Usuario ---")
    IO.puts("ID: #{usuario.id}")
    IO.puts("Nombre de Usuario: #{usuario.nombre}")
    IO.puts("Fecha de Nacimiento: #{usuario.fecha_nacimiento}")
    IO.puts("Miembro desde: #{usuario.inserted_at}")
    IO.puts("Última actualización: #{usuario.updated_at}")
    IO.puts("--------------------------")
  end

  defp handle_response({:ok, usuario}, :editar_usuario) do
    IO.puts("--- Usuario modificado ---")
    IO.puts("ID: #{usuario.id}")
    IO.puts("Nombre de Usuario: #{usuario.nombre}")
    IO.puts("Fecha de Nacimiento: #{usuario.fecha_nacimiento}")
    IO.puts("Miembro desde: #{usuario.inserted_at}")
    IO.puts("Última actualización: #{usuario.updated_at}")
    IO.puts("--------------------------")
  end

  defp handle_response({:ok, _result}, _comando) do
  end

  defp handle_response({:error, %Ecto.Changeset{} = changeset}, comando) do
    reason_string =
      Ecto.Changeset.traverse_errors(changeset, fn {message, _opts} -> message end)
      |> Map.values()
      |> List.flatten()
      |> Enum.join(", ")

    IO.puts("{:error, #{comando}: \"#{reason_string}\"}")
  end

  defp handle_response({:error, reason}, comando) do
    IO.puts("{:error, #{comando}: #{inspect(reason)}}")
  end
end
