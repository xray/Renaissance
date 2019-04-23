defmodule RenaissanceWeb.AuctionController do
  use RenaissanceWeb, :controller
  alias Renaissance.Auctions
  alias RenaissanceWeb.Helpers.Auth
  alias RenaissanceWeb.AuctionView

  def index(conn, _params) do
    if Auth.signed_in?(conn) do
      render(conn, "index.html", auctions: Auctions.get_all())
    else
      redirect(conn, to: Routes.login_path(conn, :login))
    end
  end

  def new(conn, _params) do
    if Auth.signed_in?(conn) do
      render(conn, "new.html", changeset: conn)
    else
      redirect(conn, to: Routes.login_path(conn, :login))
    end
  end

  def create(conn, params) do
    response =
      conn
      |> get_session(:current_user_id)
      |> Auctions.create_auction(params)

    case response do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Auction Created!")
        |> redirect(to: Routes.auction_path(conn, :index))

      {:error, changeset} ->
        render(conn, "create.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    if Auth.signed_in?(conn) do
      {id, _} = Integer.parse(id)

      auction = Auctions.get(id)
      end_time = auction.end_auction_at

      render(conn, "show.html", %{
        auction: auction,
        time_remaining: AuctionView.time_remaining(end_time),
        end_time: AuctionView.pretty_time(end_time)
      })
    else
      redirect(conn, to: Routes.login_path(conn, :login))
    end
  end
end
