defmodule Demo.ConnectionsRegistry do
  @name :connections
  def start_link(_) do
    Registry.start_link(
      keys: :duplicate,
      name: __MODULE__,
      partitions: System.schedulers_online()
    )
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[]]}
    }
  end

  def register() do
    Registry.register(__MODULE__, @name, [])
    broadcast()
  end

  def unregister() do
    Registry.unregister(__MODULE__, @name)
    broadcast()
  end

  def count() do
    Registry.count(__MODULE__)
  end

  defp broadcast() do
    Registry.dispatch(
      __MODULE__,
      @name,
      fn entries ->
        for {pid, _} <- entries, do: send(pid, {:connections, count()})
      end,
      parallel: true
    )
  end
end
