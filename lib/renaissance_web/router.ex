defmodule RenaissanceWeb.Router do
  use RenaissanceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {RenaissanceWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RenaissanceWeb do
    pipe_through :browser

    get "/", AuctionController, :index
    get "/login", LoginController, :login
    post "/login", LoginController, :verify

    resources "/register", RegisterController, only: [:new, :create]
    resources "/auctions", AuctionController, only: [:index, :create, :new, :show, :update]
    resources "/bids", BidController, only: [:create]
  end
end
