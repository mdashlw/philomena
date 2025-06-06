defmodule PhilomenaWeb.Admin.BanView do
  alias PhilomenaWeb.ProfileView

  def user_abbrv(user),
    do: ProfileView.user_abbrv(user)

  def ban_row_class(%{valid_until: until, enabled: enabled}) do
    now = DateTime.utc_now()

    if enabled and DateTime.diff(until, now) > 0 do
      "success"
    else
      "danger"
    end
  end

  def page_params(params) do
    case params["bq"] do
      nil -> []
      "" -> []
      q -> [bq: q]
    end
  end
end
