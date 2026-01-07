defmodule PhilomenaWeb.Profile.DerpedView do
  use PhilomenaWeb, :view

  def ranked(%{rank: rank, ntile: ntile}) do
    cond do
      rank <= 100 ->
        [" ", content_tag(:u, "Ranked ##{rank} among all users!")]

      ntile <= 10 ->
        [" ", content_tag(:u, "Top #{ntile}% among all users!")]

      true ->
        ""
    end
  end

  def rank(rank, ntile) do
    if rank > 100 and ntile <= 10 do
      "##{rank} (Top #{ntile}%)"
    else
      "##{rank}"
    end
  end

  def safe_div(value, total) when is_nil(value) or is_nil(total), do: 0.0
  def safe_div(_value, total) when total == 0, do: 1.0
  def safe_div(value, total), do: value / total

  def increase_stats(value, total) do
    content_tag(:p) do
      [
        "An increase of ",
        content_tag(:span, "#{Float.round(safe_div(value, total - value) * 100, 1)}%",
          class: "stat"
        ),
        ", bringing the overall total to ",
        content_tag(:span, number_with_delimiter(total), class: "stat"),
        "."
      ]
    end
  end

  def stat_with_percent(value, total) do
    content_tag(:span, class: "stat") do
      [
        to_string(Float.round(safe_div(value, total) * 100, 1)),
        "% (",
        to_string(number_with_delimiter(value)),
        ")"
      ]
    end
  end

  def scope(conn) do
    []
    |> scope(conn, "token", :token)
    |> scope(conn, "daily", :daily)
  end

  defp scope(list, conn, key, key_atom) do
    case conn.params[key] do
      nil -> list
      "" -> list
      val -> [{key_atom, val} | list]
    end
  end
end
