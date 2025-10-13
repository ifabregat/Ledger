defmodule Ledger.Monedas.Monedas do
  alias Ledger.Repo
  alias Ledger.Monedas.Moneda

  def crear_moneda(attrs) do
    %Moneda{}
    |> Moneda.changeset(attrs)
    |> Repo.insert()
  end

  def ver_moneda(id) do
    case Repo.get(Moneda, id) do
      nil -> {:error, "Moneda no encontrada"}
      moneda -> {:ok, moneda}
    end
  end

  def editar_moneda(id, attrs) do
    case ver_moneda(id) do
      {:ok, moneda} ->
        moneda
        |> Moneda.changeset(attrs)
        |> Repo.update()

      {:error, msg} ->
        {:error, msg}
    end
  end

  def borrar_moneda(id) do
    moneda = Repo.get(Moneda, id) |> Repo.preload([:transacciones_origen, :transacciones_destino])

    cond do
      moneda == nil ->
        {:error, "Moneda no encontrada"}

      moneda.transacciones_origen != [] or moneda.transacciones_destino != [] ->
        {:error, "No se puede eliminar la moneda con transacciones asociadas"}

      true ->
        Repo.delete(moneda)
    end
  end
end
