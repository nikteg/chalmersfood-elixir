defmodule ChalmersfoodWeb.PageView do
  use ChalmersfoodWeb, :view

  def render_restaurant_items(%{type: type, name: name}) do
    ~E(<b><%= type %></b> <%= name %>)
  end

  def render_restaurant_items(name) do
    ~E(<%= name %>)
  end
end
