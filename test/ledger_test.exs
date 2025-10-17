defmodule Ledger.UsuariosTest do
  use ExUnit.Case, async: false
  alias Ledger.Repo
  alias Ledger.Usuarios.Usuarios
  alias Ledger.Usuarios.Usuario
  alias Ledger.Monedas.Monedas
  alias Ledger.Monedas.Moneda
  alias Ledger.Transacciones.Transacciones

  defp nombre_unico_letras(length \\ 3) do
    for _ <- 1..length, into: "", do: <<Enum.random(?A..?Z)>>
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ledger.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Ledger.Repo, {:shared, self()})
    :ok
  end

  defp ecto_errores(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end

  test "crear usuario válido" do
    nombre = "Naruto Uzumaki #{System.unique_integer([:positive])}"
    attrs = %{nombre: nombre, fecha_nacimiento: ~D[1990-01-01]}

    assert {:ok, %Usuario{} = usuario} = Usuarios.crear_usuario(attrs)
    assert usuario.nombre == nombre
  end

  test "crear usuario con nombre ya existente" do
    nombre = "Naruto Uzumaki #{System.unique_integer([:positive])}"
    attrs = %{nombre: nombre, fecha_nacimiento: ~D[1990-01-01]}
    {:ok, _} = Usuarios.crear_usuario(attrs)

    {:error, changeset} = Usuarios.crear_usuario(attrs)
    assert %{nombre: [_]} = ecto_errores(changeset)
  end

  test "ver usuario existente" do
    nombre = "Naruto Uzumaki #{System.unique_integer([:positive])}"
    {:ok, usuario} = Usuarios.crear_usuario(%{nombre: nombre, fecha_nacimiento: ~D[1990-01-01]})

    assert {:ok, ^usuario} = Usuarios.ver_usuario(usuario.id)
  end

  test "ver usuario inexistente" do
    assert {:error, "Usuario no encontrado"} = Usuarios.ver_usuario(-1)
  end

  test "editar usuario existente" do
    nombre = "Naruto Uzumaki #{System.unique_integer([:positive])}"
    {:ok, usuario} = Usuarios.crear_usuario(%{nombre: nombre, fecha_nacimiento: ~D[1990-01-01]})

    nombre_nuevo = nombre <> " Sasuke"
    {:ok, updated} = Usuarios.editar_usuario(usuario.id, %{nombre: nombre_nuevo})
    assert updated.nombre == nombre_nuevo
  end

  test "editar usuario inexistente" do
    assert {:error, "Usuario no encontrado"} =
             Usuarios.editar_usuario(-1, %{nombre: "Naruto Uzumaki"})
  end

  test "borrar usuario sin transacciones" do
    nombre = "Naruto Uzumaki #{System.unique_integer([:positive])}"
    {:ok, usuario} = Usuarios.crear_usuario(%{nombre: nombre, fecha_nacimiento: ~D[1990-01-01]})

    assert {:ok, _} = Usuarios.borrar_usuario(usuario.id)
    assert {:error, "Usuario no encontrado"} = Usuarios.ver_usuario(usuario.id)
  end

  test "borrar usuario inexistente" do
    assert {:error, "Usuario no encontrado"} = Usuarios.borrar_usuario(-1)
  end

  test "validar mayor de edad" do
    menor = %{nombre: "Joven", fecha_nacimiento: Date.utc_today() |> Date.add(-365 * 17)}
    changeset = Usuario.changeset(%Usuario{}, menor)
    assert "El usuario debe ser mayor de edad" in ecto_errores(changeset).fecha_nacimiento

    mayor = %{nombre: "Adulto", fecha_nacimiento: Date.utc_today() |> Date.add(-365 * 20)}
    changeset = Usuario.changeset(%Usuario{}, mayor)
    assert changeset.valid?
  end

  test "validar cambio de nombre" do
    nombre = "Naruto Uzumaki #{System.unique_integer([:positive])}"
    {:ok, usuario} = Usuarios.crear_usuario(%{nombre: nombre, fecha_nacimiento: ~D[1990-01-01]})

    {:error, changeset} = Usuarios.editar_usuario(usuario.id, %{nombre: nombre})
    assert %{nombre: [_]} = ecto_errores(changeset)

    nombre_nuevo = nombre <> " Sasuke"
    {:ok, changeset2} = Usuarios.editar_usuario(usuario.id, %{nombre: nombre_nuevo})
    assert changeset2.nombre == nombre_nuevo
  end

  test "validar cambio de nombre con params nil" do
    usuario = %Usuario{id: 1, nombre: "Kakashi"}
    changeset = Usuario.changeset(usuario, %{})
    assert !changeset.valid?
  end

  test "crear moneda válida" do
    attrs = %{nombre: nombre_unico_letras(), precio_dolares: Decimal.new("50000")}
    assert {:ok, %Moneda{} = moneda} = Monedas.crear_moneda(attrs)
    assert moneda.nombre == attrs.nombre
  end

  test "crear moneda con nombre ya existente" do
    nombre = nombre_unico_letras()
    attrs = %{nombre: nombre, precio_dolares: Decimal.new("3500")}
    {:ok, _} = Monedas.crear_moneda(attrs)

    {:error, changeset} = Monedas.crear_moneda(attrs)
    assert %{nombre: [_]} = ecto_errores(changeset)
  end

  test "editar moneda válida" do
    nombre = nombre_unico_letras()
    {:ok, moneda} = Monedas.crear_moneda(%{nombre: nombre, precio_dolares: Decimal.new("2")})
    {:ok, updated} = Monedas.editar_moneda(moneda.id, %{precio_dolares: Decimal.new("2.5")})
    assert updated.precio_dolares == Decimal.new("2.5")
  end

  test "editar moneda intentando cambiar nombre" do
    nombre = nombre_unico_letras()
    {:ok, moneda} = Monedas.crear_moneda(%{nombre: nombre, precio_dolares: Decimal.new("150")})
    {:error, changeset} = Monedas.editar_moneda(moneda.id, %{nombre: "XRP"})
    assert %{nombre: [_]} = ecto_errores(changeset)
  end

  test "editar moneda inexistente" do
    assert {:error, "Moneda no encontrada"} =
             Monedas.editar_moneda(-1, %{precio_dolares: Decimal.new("1")})
  end

  test "ver moneda existente" do
    nombre = nombre_unico_letras()
    {:ok, moneda} = Monedas.crear_moneda(%{nombre: nombre, precio_dolares: Decimal.new("35")})

    {:ok, moneda_leida} = Monedas.ver_moneda(moneda.id)
    assert moneda_leida.id == moneda.id
    assert moneda_leida.nombre == moneda.nombre
    assert Decimal.compare(moneda_leida.precio_dolares, moneda.precio_dolares) == :eq
  end

  test "ver moneda inexistente" do
    assert {:error, "Moneda no encontrada"} = Monedas.ver_moneda(-1)
  end

  test "borrar moneda sin transacciones" do
    nombre = nombre_unico_letras()
    {:ok, moneda} = Monedas.crear_moneda(%{nombre: nombre, precio_dolares: Decimal.new("180")})
    assert {:ok, _} = Monedas.borrar_moneda(moneda.id)
    assert {:error, "Moneda no encontrada"} = Monedas.ver_moneda(moneda.id)
  end

  test "borrar moneda inexistente" do
    assert {:error, "Moneda no encontrada"} = Monedas.borrar_moneda(-1)
  end

  test "alta de cuenta" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    attrs = %{
      cuenta_destino_id: usuario.id,
      moneda_destino_id: moneda.id,
      monto: 10.0,
      tipo: "alta"
    }

    assert {:ok, _} = Ledger.Transacciones.Transacciones.alta_cuenta(attrs)
  end

  test "alta de cuenta con moneda ya existente e ingresada" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    attrs = %{
      cuenta_destino_id: usuario.id,
      moneda_destino_id: moneda.id,
      monto: 10.0,
      tipo: "alta"
    }

    assert {:ok, _} = Ledger.Transacciones.Transacciones.alta_cuenta(attrs)

    assert {:error, "El usuario ya tiene una cuenta en esta moneda"} ==
             Ledger.Transacciones.Transacciones.alta_cuenta(attrs)
  end

  test "alta cuenta sin usuario" do
    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    attrs = %{cuenta_destino_id: -1, moneda_destino_id: moneda.id, monto: 10.0, tipo: "alta"}

    assert {:error, "Usuario no encontrado"} ==
             Ledger.Transacciones.Transacciones.alta_cuenta(attrs)
  end

  test "alta cuenta sin moneda" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    attrs = %{cuenta_destino_id: usuario.id, moneda_destino_id: -1, monto: 10.0, tipo: "alta"}

    assert {:error, "Moneda no encontrada"} ==
             Ledger.Transacciones.Transacciones.alta_cuenta(attrs)
  end

  test "realizar transferencia" do
    {:ok, usuario_origen} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, usuario_destino} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Sasuke Uchiha #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    {:ok, _} =
      Ledger.Transacciones.Transacciones.alta_cuenta(%{
        cuenta_destino_id: usuario_origen.id,
        moneda_destino_id: moneda.id,
        monto: 100.0,
        tipo: "alta"
      })

    attrs = %{
      cuenta_origen_id: usuario_origen.id,
      cuenta_destino_id: usuario_destino.id,
      moneda_origen_id: moneda.id,
      tipo: "transferencia",
      monto: 50.0
    }

    assert {:ok, _transaccion} = Ledger.Transacciones.Transacciones.realizar_transferencia(attrs)
  end

  test "realizar transferencia con usuario origen igual a destino" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    attrs = %{
      cuenta_origen_id: usuario.id,
      cuenta_destino_id: usuario.id,
      moneda_origen_id: moneda.id,
      tipo: "transferencia",
      monto: 10.0
    }

    assert {:error, "El usuario origen y destino no pueden ser el mismo"} ==
             Ledger.Transacciones.Transacciones.realizar_transferencia(attrs)
  end

  test "realizar swap saldo insuficiente" do
    {:ok, usuario_origen} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, usuario_destino} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Sasuke Uchiha #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    attrs = %{
      cuenta_origen_id: usuario_origen.id,
      cuenta_destino_id: usuario_destino.id,
      moneda_origen_id: moneda.id,
      tipo: "transferencia",
      monto: 50.0
    }

    assert {:error, "Saldo insuficiente"} ==
             Ledger.Transacciones.Transacciones.realizar_transferencia(attrs)
  end

  test "realizar swap" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda_origen} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    {:ok, moneda_destino} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("2")
      })

    {:ok, _} =
      Ledger.Transacciones.Transacciones.alta_cuenta(%{
        cuenta_destino_id: usuario.id,
        moneda_destino_id: moneda_origen.id,
        monto: 100.0,
        tipo: "alta"
      })

    attrs = %{
      cuenta_destino_id: usuario.id,
      moneda_origen_id: moneda_origen.id,
      moneda_destino_id: moneda_destino.id,
      tipo: "swap",
      monto: 50.0
    }

    assert {:ok, _transaccion} = Ledger.Transacciones.Transacciones.realizar_swap(attrs)
  end

  test "realizar swap con moneda origen igual a destino" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    attrs = %{
      cuenta_destino_id: usuario.id,
      moneda_origen_id: moneda.id,
      moneda_destino_id: moneda.id,
      tipo: "swap",
      monto: 10.0
    }

    assert {:error, "La moneda de origen y destino no pueden ser la misma"} ==
             Ledger.Transacciones.Transacciones.realizar_swap(attrs)
  end

  test "realizar swap con saldo insuficiente" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda_origen} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    {:ok, moneda_destino} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("2")
      })

    attrs = %{
      cuenta_destino_id: usuario.id,
      moneda_origen_id: moneda_origen.id,
      moneda_destino_id: moneda_destino.id,
      tipo: "swap",
      monto: 50.0
    }

    assert {:error, "Saldo insuficiente para realizar el swap"} ==
             Ledger.Transacciones.Transacciones.realizar_swap(attrs)
  end

  test "deshacer transacción alta" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    {:ok, transaccion} =
      Ledger.Transacciones.Transacciones.alta_cuenta(%{
        cuenta_destino_id: usuario.id,
        moneda_destino_id: moneda.id,
        monto: 50.0,
        tipo: "alta"
      })

    assert {:ok, _} =
             Ledger.Transacciones.Transacciones.deshacer_transaccion(%{id: transaccion.id})

    assert {:error, "Transacción no encontrada"} =
             Ledger.Transacciones.Transacciones.ver_transaccion(%{id: transaccion.id})
  end

  test "deshacer transaccion transferencia" do
    {:ok, u1} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, u2} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Sasuke Uchiha #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    {:ok, _} =
      Ledger.Transacciones.Transacciones.alta_cuenta(%{
        cuenta_destino_id: u1.id,
        moneda_destino_id: moneda.id,
        monto: 100.0,
        tipo: "alta"
      })

    {:ok, transaccion} =
      Ledger.Transacciones.Transacciones.realizar_transferencia(%{
        cuenta_origen_id: u1.id,
        cuenta_destino_id: u2.id,
        moneda_origen_id: moneda.id,
        tipo: "transferencia",
        monto: 50.0
      })

    assert {:ok, inversa} =
             Ledger.Transacciones.Transacciones.deshacer_transaccion(%{id: transaccion.id})

    assert inversa.cuenta_origen_id == transaccion.cuenta_destino_id
    assert inversa.cuenta_destino_id == transaccion.cuenta_origen_id
    assert inversa.monto == transaccion.monto
  end

  test "deshacer transaccion no encontrada" do
    assert {:error, "Transacción no encontrada"} =
             Ledger.Transacciones.Transacciones.deshacer_transaccion(%{id: -1})
  end

  test "falla si no es la última transacción" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    {:ok, moneda2} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("2")
      })

    {:ok, t1} =
      Transacciones.alta_cuenta(%{
        cuenta_destino_id: usuario.id,
        moneda_destino_id: moneda.id,
        monto: 100.0,
        tipo: "alta"
      })

    {:ok, _t2} =
      Transacciones.realizar_swap(%{
        cuenta_destino_id: usuario.id,
        moneda_origen_id: moneda.id,
        moneda_destino_id: moneda2.id,
        monto: 50.0,
        tipo: "swap"
      })

    assert {:error, "Solo se puede deshacer la última transacción de las cuentas"} =
             Transacciones.deshacer_transaccion(%{id: t1.id})
  end

  test "deshacer transaccion swap" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda_origen} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    {:ok, moneda_destino} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("2")
      })

    {:ok, _} =
      Ledger.Transacciones.Transacciones.alta_cuenta(%{
        cuenta_destino_id: usuario.id,
        moneda_destino_id: moneda_origen.id,
        monto: 100.0,
        tipo: "alta"
      })

    {:ok, transaccion} =
      Ledger.Transacciones.Transacciones.realizar_swap(%{
        cuenta_destino_id: usuario.id,
        moneda_origen_id: moneda_origen.id,
        moneda_destino_id: moneda_destino.id,
        tipo: "swap",
        monto: 50.0
      })

    assert {:ok, _inversa} =
             Ledger.Transacciones.Transacciones.deshacer_transaccion(%{id: transaccion.id})
  end

  test "deshacer transaccion con tipo desconocido" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Test #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    attrs = %{
      cuenta_destino_id: usuario.id,
      moneda_destino_id: moneda.id,
      monto: 100.0,
      tipo: "rasengan"
    }

    {:ok, t} = Transacciones.alta_cuenta(attrs)

    {:error, _} = Transacciones.deshacer_transaccion(%{id: t.id})
  end

  test "deshacer transaccion con tipo ya es un átomo" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    transaccion =
      %Ledger.Transacciones.Transaccion{
        cuenta_destino_id: usuario.id,
        moneda_destino_id: moneda.id,
        monto: 100.0,
        tipo: "alta"
      }
      |> Ledger.Repo.insert!()

    {:ok, _resultado} = Transacciones.deshacer_transaccion(%{id: transaccion.id})

    assert Repo.get(Ledger.Transacciones.Transaccion, transaccion.id) == nil
  end

  test "deshacer transaccion sin transacciones en la db" do
    transaccion_fake = %Ledger.Transacciones.Transaccion{
      id: 9999,
      cuenta_origen_id: nil,
      cuenta_destino_id: 12345
    }

    assert Ledger.Transacciones.Transacciones.deshacer_transaccion(%{id: transaccion_fake.id}) ==
             {:error, "Transacción no encontrada"}
  end

  test "ver transacción existente" do
    {:ok, usuario} =
      Ledger.Usuarios.Usuarios.crear_usuario(%{
        nombre: "Naruto Uzumaki #{System.unique_integer([:positive])}",
        fecha_nacimiento: ~D[1990-01-01]
      })

    {:ok, moneda} =
      Ledger.Monedas.Monedas.crear_moneda(%{
        nombre: nombre_unico_letras(),
        precio_dolares: Decimal.new("1")
      })

    {:ok, transaccion} =
      Ledger.Transacciones.Transacciones.alta_cuenta(%{
        cuenta_destino_id: usuario.id,
        moneda_destino_id: moneda.id,
        monto: 50.0,
        tipo: "alta"
      })

    assert {:ok, ^transaccion} =
             Ledger.Transacciones.Transacciones.ver_transaccion(%{id: transaccion.id})
  end

  test "ver transacción inexistente" do
    assert {:error, "Transacción no encontrada"} =
             Ledger.Transacciones.Transacciones.ver_transaccion(%{id: -1})
  end

  test "sin filtros devuelve todas las transacciones" do
    result = Ledger.listar_transacciones(%{})
    assert length(result) == 30
  end

  test "filtra por cuenta_origen_id correctamente" do
    result = Ledger.listar_transacciones(%{cuenta_origen_id: 1})
    assert Enum.all?(result, &(&1.cuenta_origen_id == 1))
    assert length(result) == 1
  end

  test "filtra por cuenta_destino_id correctamente" do
    result = Ledger.listar_transacciones(%{cuenta_destino_id: 2})
    assert Enum.all?(result, &(&1.cuenta_destino_id == 2))
    assert length(result) == 4
  end

  test "filtra por moneda_nombre correctamente" do
    result = Ledger.listar_transacciones(%{moneda_nombre: "BTC"})

    assert Enum.all?(result, fn t ->
             ids = [t.moneda_origen_id, t.moneda_destino_id] |> Enum.reject(&is_nil/1)

             Enum.any?(ids, fn id ->
               Ledger.Repo.get(Ledger.Monedas.Moneda, id).nombre == "BTC"
             end)
           end)

    assert length(result) == 4
  end

  test "filtra por tipo correctamente" do
    result_alta = Ledger.listar_transacciones(%{tipo: "alta"})
    result_transf = Ledger.listar_transacciones(%{tipo: "transferencia"})

    assert length(result_alta) == 10
    assert length(result_transf) == 10
  end

  test "calcula el balance total de la cuenta 1 (en todas las monedas)" do
    result = Ledger.calcular_balance(1, nil)
    assert String.contains?(result, "BTC=")
  end

  test "calcula el balance de una cuenta en una moneda específica" do
    result = Ledger.calcular_balance(1, "BTC")
    assert String.starts_with?(result, "BTC=")
  end

  test "calcular balance con id como entero" do
    result = Ledger.calcular_balance(2, 2)
    assert String.starts_with?(result, "ETH=")
  end

  test "calcular balance con moneda no valida" do
    result = Ledger.calcular_balance(1, :moneda_invalida)
    assert result == {:error, "Moneda no encontrada"}
  end

  test "calcular_balances ignora transacciones de tipo desconocido" do
    cuenta_id = 1
    moneda_id = 1

    %Ledger.Transacciones.Transaccion{}
    |> Ecto.Changeset.cast(
      %{
        tipo: "desconocido",
        cuenta_destino_id: cuenta_id,
        moneda_destino_id: moneda_id,
        monto: 9999
      },
      [:tipo, :cuenta_destino_id, :moneda_destino_id, :monto]
    )
    |> Ledger.Repo.insert!()

    balances = Ledger.calcular_balances(cuenta_id)

    assert balances[moneda_id] != 9999
  end
end
