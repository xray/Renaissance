defmodule RenaissanceWeb.AuctionController do
  use RenaissanceWeb, :controller

  alias Renaissance.{Auction, Auctions}
  alias RenaissanceWeb.Helpers.Auth

  def index(conn, _params) do
    if Auth.signed_in?(conn) do
      render(conn, "index.html", auctions: Auctions.get_all_detailed())
    else
      redirect(conn, to: Routes.login_path(conn, :login))
    end
  end

  def new(conn, _params) do
    changeset = Auction.changeset(%Auction{})

    if Auth.signed_in?(conn) do
      render(conn, "new.html", changeset: changeset)
    else
      redirect(conn, to: Routes.login_path(conn, :login))
    end
  end

  def create(conn, %{"auction" => auction}) do
    seller_id = Auth.current_user(conn).id
    params = Map.put(auction, "seller_id", seller_id)

    case Auctions.insert(params) do
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
      id = String.to_integer(id)

      render(conn, "show.html", %{
        auction: Auctions.get_detailed(id),
        user: Auth.current_user(conn),
        changeset: conn
      })
    else
      redirect(conn, to: Routes.login_path(conn, :login))
    end
  end

  def update(conn, params) do
    id = String.to_integer(params["id"])

    with {:ok, _auctions} <- Auctions.update(id, params) do
      conn
      |> put_flash(:info, "Auction Updated!")
      |> render("show.html", %{
        auction: Auctions.get_detailed(id),
        user: Auth.current_user(conn),
        changeset: conn
      })
    else
      {:error, changeset} ->
        render(conn, "show.html", changeset: changeset)
    end
  end
end
