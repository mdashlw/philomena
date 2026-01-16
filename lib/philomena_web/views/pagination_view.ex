defmodule PhilomenaWeb.PaginationView do
  use PhilomenaWeb, :view

  def first_page?(page) do
    page.page_number == 1
  end

  def last_page?(page) do
    page.page_number == page.total_pages
  end

  def page_path(page, route, params, number) do
    total_pages = page.total_pages

    case number do
      1 ->
        route.(Keyword.merge(params, page: number))

      ^total_pages ->
        route.(Keyword.merge(params, page: number, rel: 1))

      _ ->
        rel = number - page.page_number

        if rel == 1 do
          route.(Keyword.merge(params, page: number, cursor: cursor(page, rel)))
        else
          route.(Keyword.merge(params, page: number, cursor: cursor(page, rel), rel: rel))
        end
    end
  end

  defp cursor(%{entries: []}, _rel), do: nil

  defp cursor(%{entries: entries}, rel) when rel > 0, do: hit_sort(List.last(entries))
  defp cursor(%{entries: entries}, rel) when rel < 0, do: hit_sort(List.first(entries))
  defp cursor(_page, _rel), do: nil

  defp hit_sort({_, hit}), do: hit["sort"]
  defp hit_sort(_entry), do: nil

  def first_page_path(page, route, params), do: page_path(page, route, params, 1)

  def prev_page_path(page, route, params),
    do: page_path(page, route, params, page.page_number - 1)

  def next_page_path(page, route, params),
    do: page_path(page, route, params, page.page_number + 1)

  def last_page_path(page, route, params), do: page_path(page, route, params, page.total_pages)

  def left_gap?(page) do
    page.page_number >= 7
  end

  def left_page_numbers(page) do
    number = page.page_number
    min = 1
    max = page.total_pages

    (number - 5)..number
    |> Enum.filter(&(&1 >= min and &1 != number and &1 <= max))
  end

  def right_gap?(page) do
    page.total_pages - page.page_number >= 6
  end

  def right_page_numbers(page) do
    number = page.page_number
    min = 1
    max = page.total_pages

    number..(number + 5)
    |> Enum.filter(&(&1 >= min and &1 != number and &1 <= max))
  end
end
