defmodule Ledger.Usuarios.Usuarios do
  import Ecto.Query
  alias Ledger.Repo
  alias Ledger.Usuarios.Usuario

  def crear_usuario(attrs) do
    %Usuario{}
    |> Usuario.changeset(attrs)
    |> Repo.insert()
    |> handle_result()
  end

  def ver_usuario(id) do
    case Repo.get(Usuario, id) do
      nil -> {:error, "Usuario no encontrado"}
      usuario -> {:ok, usuario}
    end
  end

  def editar_usuario(id, attrs) do
    with {:ok, usuario} <- ver_usuario(id) do
      usuario
      |> Usuario.changeset(attrs)
      |> Repo.update()
      |> handle_result()
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

  defp handle_result({:ok, usuario}), do: {:ok, usuario}

  defp handle_result({:error, changeset}) do
    {:error, format_errors(changeset)}
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map(fn {field, errors} -> "#{field}: #{Enum.join(errors, ", ")}" end)
    |> Enum.join("; ")
  end
end
