defmodule ExampleApp.CLI do
  alias Ledger.Usuarios.Usuarios
  alias Ledger.Monedas.Monedas
  alias Ledger.Transacciones.Transacciones
  alias Ledger.Repo
  alias Ledger

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
              md: :integer,
              c1: :integer,
              c2: :integer,
              t: :string,
              f: :string,
              mb: :string
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

  defp ejecutar_comando("transacciones", opts) do
    attrs = %{
      cuenta_origen_id: Keyword.get(opts, :c1),
      cuenta_destino_id: Keyword.get(opts, :c2),
      tipo: Keyword.get(opts, :t),
      moneda_nombre: Keyword.get(opts, :mb),
      archivo: Keyword.get(opts, :f)
    }

    resultado = Ledger.listar_transacciones(attrs)

    handle_response_transacciones(resultado, :filtrar_transacciones, attrs.archivo)
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
    transaccion =
      Repo.preload(transaccion, [
        :cuenta_origen,
        :cuenta_destino,
        :moneda_origen,
        :moneda_destino
      ])

    cuenta_origen_nombre =
      if transaccion.cuenta_origen, do: transaccion.cuenta_origen.nombre, else: "null"

    moneda_origen_nombre =
      if transaccion.moneda_origen, do: transaccion.moneda_origen.nombre, else: "null"

    cuenta_destino_nombre =
      if transaccion.cuenta_destino, do: transaccion.cuenta_destino.nombre, else: "null"

    moneda_destino_nombre =
      if transaccion.moneda_destino, do: transaccion.moneda_destino.nombre, else: "null"

    IO.puts("--- Detalles de la Transacción ---")
    IO.puts("ID: #{transaccion.id}")
    IO.puts("Tipo de Transacción: #{transaccion.tipo}")
    IO.puts("Monto: #{transaccion.monto}")
    IO.puts("Cuenta Origen: #{cuenta_origen_nombre}")
    IO.puts("Moneda Origen: #{moneda_origen_nombre}")
    IO.puts("Cuenta Destino: #{cuenta_destino_nombre}")
    IO.puts("Moneda Destino: #{moneda_destino_nombre}")
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

  defp handle_response_transacciones(transacciones, :filtrar_transacciones, archivo) do
    transacciones =
      Repo.preload(transacciones, [
        :cuenta_origen,
        :cuenta_destino,
        :moneda_origen,
        :moneda_destino
      ])

    lineas =
      Enum.map(transacciones, fn t ->
        Enum.join(
          [
            t.id,
            t.inserted_at,
            t.moneda_origen && t.moneda_origen.nombre,
            t.moneda_destino && t.moneda_destino.nombre,
            t.monto,
            t.cuenta_origen && t.cuenta_origen.nombre,
            t.cuenta_destino && t.cuenta_destino.nombre,
            t.tipo
          ],
          ";"
        )
      end)

    contenido =
      lineas
      |> Enum.join("\n")

    if archivo do
      File.write!(archivo, contenido)
      IO.puts("Archivo generado: #{archivo}")
    else
      IO.puts(contenido)
    end
  end
end
