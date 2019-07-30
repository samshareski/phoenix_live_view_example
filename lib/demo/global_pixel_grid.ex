defmodule Demo.GlobalPixelGrid do
  use GenServer

  alias DemoWeb.Endpoint

  @topic "pixel grid"

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    initial_state = List.duplicate("white", 100)
    Endpoint.broadcast(@topic, "new_grid", %{grid: initial_state})
    {:ok, initial_state}
  end

  def register() do
    Endpoint.subscribe(@topic)
    GenServer.call(__MODULE__, :get_grid)
  end

  def unregister() do
    Endpoint.unsubscribe(@topic)
  end

  def paint_pixel(i, colour) do
    GenServer.cast(__MODULE__, {:paint_pixel, i, colour})
  end

  def handle_call(:get_grid, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:paint_pixel, i, colour}, state) do
    new_state = List.replace_at(state, i, colour)
    Endpoint.broadcast(@topic, "new_grid", %{grid: new_state})
    {:noreply, new_state}
  end
end
