defmodule RenaissanceWeb.Router do
  use RenaissanceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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
    resources "/auctions", AuctionController, only: [:index, :create, :new, :show]
  end
end
