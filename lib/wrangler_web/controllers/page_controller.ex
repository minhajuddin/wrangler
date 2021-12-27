defmodule WranglerWeb.PageController do
  use WranglerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
