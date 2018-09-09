defmodule Bep.PageController do
  use Bep.Web, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: search_path(conn, :index))
    else
      bg_colour = get_client_colour(conn, :login_page_bg_colour)
      render(conn, "index.html", bg_colour: bg_colour)
    end
  end

  def cat(conn, _params) do
    bg_colour = get_client_colour(conn, :login_page_bg_colour)

    pdf_content =
      Phoenix.View.render_to_string(Bep.PageView, "index.html", conn: conn, bg_colour: bg_colour)
      |> PdfGenerator.generate_binary!()

    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header("content-disposition", "attachment; filename=\"BEAR.pdf\"")
    |> send_resp(200, pdf_content)
  end
end
