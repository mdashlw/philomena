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
  def safe_div(value, total) when total == 0, do: 0.0
  def safe_div(value, total), do: value / total
end
