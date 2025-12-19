defmodule PhilomenaWeb.DerpedController do
  use PhilomenaWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: ~p"/profiles/#{conn.assigns.current_user}/derped")
  end
end
