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

    get "/", PageController, :index
    get "/register", RegisterController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RenaissanceWeb do
  #   pipe_through :api
  # end
end
