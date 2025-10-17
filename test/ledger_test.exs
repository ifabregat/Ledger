defmodule Ledger.UsuariosTest do
  use ExUnit.Case, async: true
  alias Ledger.Usuarios.Usuarios
  alias Ledger.Usuarios.Usuario
  alias Ledger.Monedas.Monedas
  alias Ledger.Monedas.Moneda

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

  defp nombre_unico_letras(length \\ 3) do
    for _ <- 1..length, into: "", do: <<Enum.random(?A..?Z)>>
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
end
