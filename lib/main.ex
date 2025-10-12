defmodule ExampleApp.CLI do
  alias Ledger.Usuarios.Usuarios
  alias Ledger.Monedas.Monedas

  def main(args \\ []) do
    args = normalizar_args(args)

    IO.inspect(args, label: "Args normalizados")

    case args do
      [comando | flags] ->
        {opts, _, _invalidos} =
          OptionParser.parse(flags,
            strict: [
              n: :string,
              b: :string,
              id: :integer,
              p: :string
            ]
          )

        ejecutar_comando(comando, opts)

      [] ->
        IO.puts("Falta el comando")
    end
  end

  defp normalizar_args(args) do
    Enum.map(args, fn
      "-" <> resto ->
        if String.contains?(resto, "=") do
          "--" <> resto
        else
          "-" <> resto
        end

      arg ->
        if String.contains?(arg, "=") do
          "--" <> arg
        else
          arg
        end
    end)
  end

  defp ejecutar_comando("crear_usuario", opts) do
    attrs = %{
      "nombre" => Keyword.get(opts, :n),
      "fecha_nacimiento" => Keyword.get(opts, :b)
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
          case Keyword.get(opts, :n) do
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

  defp ejecutar_comando("crear_moneda", opts) do
    IO.inspect(opts, label: "Opciones para crear_moneda")

    precio = Keyword.get(opts, :p)
    precio_decimal = Decimal.new(precio)

    attrs = %{
      nombre: Keyword.get(opts, :n),
      precio_dolares: precio_decimal
    }

    resultado =
      case attrs do
        %{nombre: nil} ->
          {:error, "Falta el nombre de la moneda (-n)"}

        %{precio_dolares: nil} ->
          {:error, "Falta el precio de la moneda (-p)"}

        _ ->
          Monedas.crear_moneda(attrs)
      end

    handle_response(resultado, :crear_moneda)
  end

  defp ejecutar_comando("ver_moneda", opts) do
    case Keyword.get(opts, :id) do
      nil ->
        handle_response({:error, "Falta el id (-id)"}, :ver_moneda)

      id ->
        Monedas.ver_moneda(id)
        |> handle_response(:ver_moneda)
    end
  end

  defp ejecutar_comando("editar_moneda", opts) do
    resultado =
      case Keyword.get(opts, :id) do
        nil ->
          {:error, "Falta el id (-id)"}

        id ->
          case Keyword.get(opts, :p) do
            nil ->
              {:error, "Falta el nuevo precio (-p)"}

            precio ->
              attrs = %{"precio_dolares" => precio}
              Monedas.editar_moneda(id, attrs)
          end
      end

    handle_response(resultado, :editar_moneda)
  end

  defp ejecutar_comando("borrar_moneda", opts) do
    resultado =
      case Keyword.get(opts, :id) do
        nil ->
          {:error, "Falta el parámetro id (-id)"}

        id ->
          Monedas.borrar_moneda(id)
      end

    handle_response(resultado, :borrar_moneda)
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

  defp handle_response({:ok, moneda}, :ver_moneda) do
    IO.puts("--- Detalles de la Moneda ---")
    IO.puts("ID: #{moneda.id}")
    IO.puts("Nombre de la Moneda: #{moneda.nombre}")
    IO.puts("Precio en Dólares: $#{moneda.precio_dolares}")
    IO.puts("Creada en: #{moneda.inserted_at}")
    IO.puts("Última actualización: #{moneda.updated_at}")
    IO.puts("-----------------------------")
  end

  defp handle_response({:ok, moneda}, :editar_moneda) do
    IO.puts("--- Moneda modificada ---")
    IO.puts("ID: #{moneda.id}")
    IO.puts("Nombre de la Moneda: #{moneda.nombre}")
    IO.puts("Precio en Dólares: $#{moneda.precio_dolares}")
    IO.puts("Creada en: #{moneda.inserted_at}")
    IO.puts("Última actualización: #{moneda.updated_at}")
    IO.puts("------------------------")
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
