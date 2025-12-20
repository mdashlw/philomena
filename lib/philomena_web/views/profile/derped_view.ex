defmodule PhilomenaWeb.Profile.DerpedView do
  use PhilomenaWeb, :view

  def ranked(%{rank: rank, ntile: ntile}) do
    cond do
      rank <= 100 -> " Ranked ##{rank} among all users!"
      ntile <= 10 -> " Top #{ntile}% among all users!"
      true -> ""
    end
  end

  def rank(rank, ntile) do
    if rank > 100 and ntile <= 10 do
      "##{rank} (Top #{ntile}%)"
    else
      "##{rank}"
    end
  end
end
