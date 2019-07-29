defmodule DemoWeb.PixelGridLive do
  use Phoenix.LiveView

  @topic "pixel grid"

  alias Demo.GlobalPixelGrid

  def render(assigns) do
    ~L"""
    <div class="grid">
      <%= for {value, index} <- Enum.with_index(@grid) do %>
        <div phx-click="paint"
             phx-value="<%= index %>"
             class="pixel"
             style="background-color: <%= value %>">
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket) do
      initial_grid = GlobalPixelGrid.register()
      {:ok, put_grid(socket, initial_grid)}
    else
      {:ok, put_grid(socket, List.duplicate("white", 100))}
    end
  end

  def terminate(_, _) do
    GlobalPixelGrid.unregister()
  end

  def handle_event("paint", i, socket) do
    GlobalPixelGrid.paint_pixel(String.to_integer(i))
    {:noreply, socket}
  end

  def handle_info(%{topic: @topic, payload: %{grid: grid}}, socket) do
    {:noreply, put_grid(socket, grid)}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg)
    {:noreply, socket}
  end

  defp put_grid(socket, grid) do
    assign(socket, grid: grid)
  end
end
