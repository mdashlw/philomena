defmodule PhilomenaWeb.Profile.DerpedView do
  use PhilomenaWeb, :view

  def ranked(%{rank: rank, ntile: ntile}) do
    cond do
      rank <= 100 ->
        [" ", content_tag(:span, "Ranked ##{rank} among all users!", class: "underline")]

      ntile <= 10 ->
        [" ", content_tag(:span, "Top #{ntile}% among all users!", class: "underline")]

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

  def safe_div(value, total) do
    if total != 0 do
      value / total
    else
      0.0
    end
  end
end
