# Renaissance
Auctions web app built with Elixir framework Phoenix

Greenfield web app that is similar to the basic functionality of Ebay.

## Run App

After cloning [`xray/Renaissance`](https://github.com/xray/Renaissance):  

```sh
$ cd PROJECT_ROOT
# Install dependencies
$ mix deps.get
# Create and migrate database
$ mix ecto.setup
# Install Node.js dependencies
$ cd assets && npm install && cd ..
# Start Phoenix endpoint
$ mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
  
## Test

```sh
$ cd PROJECT_ROOT
$ mix test
```
  
## Built With

- [Elixir](https://elixir-lang.org/) 1.5+  
- Web framework – [Phoenix](https://hexdocs.pm/phoenix/Phoenix.html)  
- Data store – PostgreSQL  
  
## Resources
