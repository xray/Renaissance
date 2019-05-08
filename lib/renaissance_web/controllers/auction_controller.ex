defmodule RenaissanceWeb.AuctionController do
  use RenaissanceWeb, :controller

  alias Renaissance.{Auction, Auctions, Helpers}
  alias RenaissanceWeb.Helpers.Auth

  def index(conn, _params) do
    if Auth.signed_in?(conn) do
      render(conn, "index.html", auctions: Auctions.get_all())
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

  def create(conn, params) do
    response =
      conn
      |> get_session(:current_user_id)
      |> Auctions.insert(params["auction"])

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
      id = String.to_integer(id)

      render(conn, "show.html", %{
        auction: Auctions.get!(id),
        user: Auth.current_user(conn),
        current_price: fetch_current_prices(id),
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
        auction: Auctions.get!(id),
        user: Auth.current_user(conn),
        current_price: fetch_current_prices(id),
        changeset: conn
      })
    else
      {:error, changeset} ->
        render(conn, "show.html", changeset: changeset)
    end
  end

  defp fetch_current_prices(id) do
    current = Auctions.get_current_amount(id)

    as_float = Helpers.Money.to_float(current)
    as_string = Money.to_string(current)

    %{
      as_string: as_string,
      as_float: as_float
    }
  end
end
