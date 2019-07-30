defmodule DemoWeb.PixelGridLive do
  use Phoenix.LiveView

  @topic "pixel grid"
  @palette ~w(white black red orange yellow green blue indigo violet)

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
    <div class="palette">
      <%= for colour <- @palette do %>
        <div phx-click="change brush"
             phx-value="<%= colour %>"
             class="colour <%= get_active_class(@brush, colour) %>"
             style="background-color: <%= colour %>">
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_session, socket) do
    socket =
      socket
      |> assign(brush: "black")
      |> assign(palette: @palette)

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

  def handle_event("paint", i, %{assigns: %{brush: colour}} = socket) do
    GlobalPixelGrid.paint_pixel(String.to_integer(i), colour)
    {:noreply, socket}
  end

  def handle_event("change brush", colour, socket) do
    {:noreply, put_brush(socket, colour)}
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

  defp put_brush(socket, colour) do
    assign(socket, brush: colour)
  end

  defp get_active_class(active_colour, colour) do
    if active_colour == colour do
      "active"
    else
      ""
    end
  end
end
