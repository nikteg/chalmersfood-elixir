defmodule ChalmersfoodWeb.PageView do
  use ChalmersfoodWeb, :view

  @weekdays ["Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag"]

  def render_restaurant_item(%{type: type, name: name}) do
    ~E(<b><%= type %></b> <%= name %>)
  end

  def render_restaurant_item(name) do
    ~E(<%= name %>)
  end

  def weekdays_with_index() do
    Enum.with_index(@weekdays)
  end

  def current_week() do
    {_year, week} = :calendar.iso_week_number()
    week
  end

  def translate_restaurant_error(:nxdomain), do: "Could not connect to server. DNS could not resolve the hostname."
  def translate_restaurant_error(:timeout), do: "Connection to server timed out. Try forcing a refetch."
  def translate_restaurant_error(error), do: error
end
