defmodule ChalmersfoodWeb.MenuView do
  use ChalmersfoodWeb, :view

  @weekdays ["Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag"]

  def weekdays_with_index() do
    Enum.with_index(@weekdays)
  end

  def header_text() do
    {_year, week} = :calendar.iso_week_number()

    now = DateTime.utc_now()
    weekday = Date.day_of_week(now) - 1
    monday = Date.add(now, -weekday)
    friday = Date.add(monday, 4)

    "Lunch v. #{week} (#{monday.day}/#{monday.month} - #{friday.day}/#{friday.month})"
  end

  def render_restaurant_item(%{type: type, name: name}) do
    ~E(<b><%= type %></b> <%= name %>)
  end

  def render_restaurant_item(name) do
    ~E(<%= name %>)
  end

  def translate_restaurant_error(:nxdomain), do: "Kunde inte ansluta till servern. DNS kunde inte hitta adressen."
  def translate_restaurant_error(:timeout), do: "Anslutningen till servern tog för lång tid. Testa 'tvinga omladdning'."
  def translate_restaurant_error(error), do: error
end