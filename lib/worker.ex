defmodule Metex.Worker do
  def temperature_of(location) do
    result = location
    |> url_for
    |> HTTPoison.get
    |> parse_response

    case result do
      {:ok, temp} ->
        "#{location}: #{temp}°C"
      :error ->
        "#{location} not found"
    end
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body}}) do
    body
    |> JSON.decode!
    |> compute_temperature
  end

  defp parse_response(_), do: :error

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp apikey, do: "f087bb7b03be3ea9d1c57d97989572d7"
end
