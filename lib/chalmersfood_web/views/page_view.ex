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
end
