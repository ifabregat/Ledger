defmodule ExampleApp.CLI do
  alias Ledger.Usuarios.Usuarios
  alias Ledger.Monedas.Monedas
  alias Ledger.Transacciones.Transacciones

  def main(args \\ []) do
    args = normalizar_args(args)

    case args do
      [comando | flags] ->
        {opts, _, _invalidos} =
          OptionParser.parse(flags,
            strict: [
              n: :string,
              b: :string,
              id: :integer,
              p: :string,
              u: :integer,
              m: :integer,
              a: :float,
              o: :integer,
              d: :integer,
              mo: :integer,
              md: :integer
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
          {:error, "Falta el id (-id)"}

        id ->
          Usuarios.borrar_usuario(id)
      end

    handle_response(resultado, :borrar_usuario)
  end

  defp ejecutar_comando("crear_moneda", opts) do
    if Keyword.get(opts, :p) == nil do
      {:error, "Falta el precio de la moneda (-p)"}
    else
      precio_decimal = Decimal.new(Keyword.get(opts, :p))

      attrs = %{
        nombre: Keyword.get(opts, :n),
        precio_dolares: precio_decimal
      }

      case attrs do
        %{nombre: nil} -> {:error, "Falta el nombre de la moneda (-n)"}
        _ -> Monedas.crear_moneda(attrs)
      end
    end
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
          {:error, "Falta el id (-id)"}

        id ->
          Monedas.borrar_moneda(id)
      end

    handle_response(resultado, :borrar_moneda)
  end

  defp ejecutar_comando("alta_cuenta", opts) do
    attrs = %{
      monto: Keyword.get(opts, :a),
      tipo: "alta",
      cuenta_destino_id: Keyword.get(opts, :u),
      moneda_destino_id: Keyword.get(opts, :m)
    }

    resultado =
      case attrs do
        %{cuenta_destino_id: nil} ->
          {:error, "Falta el id de usuario (-u)"}

        %{moneda_destino_id: nil} ->
          {:error, "Falta el id de moneda (-m)"}

        %{monto: nil} ->
          {:error, "Falta el monto inicial (-a)"}

        _ ->
          Transacciones.alta_cuenta(attrs)
      end

    handle_response(resultado, :alta_cuenta)
  end

  defp ejecutar_comando("realizar_transferencia", opts) do
    attrs = %{
      cuenta_origen_id: Keyword.get(opts, :o),
      cuenta_destino_id: Keyword.get(opts, :d),
      moneda_origen_id: Keyword.get(opts, :m),
      monto: Keyword.get(opts, :a),
      tipo: "transferencia"
    }

    resultado =
      case attrs do
        %{cuenta_origen_id: nil} ->
          {:error, "Falta el id de la cuenta origen (-o)"}

        %{cuenta_destino_id: nil} ->
          {:error, "Falta el id de la cuenta destino (-d)"}

        %{moneda_origen_id: nil} ->
          {:error, "Falta el id de la moneda (-m)"}

        %{monto: nil} ->
          {:error, "Falta el monto a transferir (-a)"}

        _ ->
          Transacciones.realizar_transferencia(attrs)
      end

    handle_response(resultado, :realizar_transferencia)
  end

  defp ejecutar_comando("realizar_swap", opts) do
    attrs = %{
      cuenta_destino_id: Keyword.get(opts, :u),
      moneda_origen_id: Keyword.get(opts, :mo),
      moneda_destino_id: Keyword.get(opts, :md),
      monto: Keyword.get(opts, :a),
      tipo: "swap"
    }

    resultado =
      case attrs do
        %{cuenta_destino_id: nil} ->
          {:error, "Falta el id de la cuenta (-u)"}

        %{moneda_origen_id: nil} ->
          {:error, "Falta el id de la moneda de origen (-mo)"}

        %{moneda_destino_id: nil} ->
          {:error, "Falta el id de la moneda de destino (-md)"}

        %{monto: nil} ->
          {:error, "Falta el monto a swapear (-a)"}

        _ ->
          Transacciones.realizar_swap(attrs)
      end

    handle_response(resultado, :realizar_swap)
  end

  defp ejecutar_comando("deshacer_transaccion", opts) do
    attrs = %{
      id: Keyword.get(opts, :id)
    }

    resultado =
      case attrs do
        %{id: nil} ->
          {:error, "Falta el id de la transacción (-id)"}

        _ ->
          Transacciones.deshacer_transaccion(attrs)
      end

    handle_response(resultado, :deshacer_transaccion)
  end

  defp ejecutar_comando("ver_transaccion", opts) do
    attrs = %{
      id: Keyword.get(opts, :id)
    }

    resultado =
      case attrs do
        %{id: nil} ->
          {:error, "Falta el id de la transacción (-id)"}

        _ ->
          Transacciones.ver_transaccion(attrs)
      end

    handle_response(resultado, :ver_transaccion)
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

  defp handle_response({:ok, transaccion}, :ver_transaccion) do
    IO.puts("--- Detalles de la Transacción ---")
    IO.puts("ID: #{transaccion.id}")
    IO.puts("Tipo de Transacción: #{transaccion.tipo}")
    IO.puts("Monto: #{transaccion.monto}")
    IO.puts("Cuenta Origen ID: #{transaccion.cuenta_origen_id || "N/A"}")
    IO.puts("Moneda Origen ID: #{transaccion.moneda_origen_id || "N/A"}")
    IO.puts("Cuenta Destino ID: #{transaccion.cuenta_destino_id || "N/A"}")
    IO.puts("Moneda Destino ID: #{transaccion.moneda_destino_id || "N/A"}")
    IO.puts("Realizada en: #{transaccion.inserted_at}")
    IO.puts("----------------------------------")
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
