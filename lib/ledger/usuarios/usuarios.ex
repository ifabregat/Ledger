defmodule Ledger.Usuarios.Usuarios do
  import Ecto.Query
  alias Ledger.Repo
  alias Ledger.Usuarios.Usuario

  def crear_usuario(attrs) do
    %Usuario{}
    |> Usuario.changeset(attrs)
    |> Repo.insert()
  end

  def ver_usuario(id) do
    case Repo.get(Usuario, id) do
      nil -> {:error, "Usuario no encontrado"}
      usuario -> {:ok, usuario}
    end
  end

  def editar_usuario(id, attrs) do
    case ver_usuario(id) do
      {:ok, usuario} ->
        usuario
        |> Usuario.changeset(attrs)
        |> Repo.update()

      {:error, msg} ->
        {:error, msg}
    end
  end

  def borrar_usuario(id) do
    usuario =
      Repo.get(Usuario, id)
      |> Repo.preload([:transacciones_origen, :transacciones_destino])

    cond do
      usuario == nil ->
        {:error, "Usuario no encontrado"}

      usuario.transacciones_origen != [] or usuario.transacciones_destino != [] ->
        {:error, "No se puede eliminar el usuario con transacciones asociadas"}

      true ->
        Repo.delete(usuario)
    end
  end
end
