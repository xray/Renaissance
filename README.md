# Renaissance
Auctions web app built with Elixir framework Phoenix

> `:warning:` WIP

Greenfield web app that is similar to the basic functionality of eBay.

### Installation

Clone [`xray/Renaissance`](https://github.com/xray/Renaissance), and then 
install its dependencies.  
```sh
$ cd PROJECT_ROOT
$ mix deps.get
```
  
Create and migrate the database.  
```sh
$ mix ecto.setup
```
  
Finally, install Node.js dependencies.  
```sh
$ cd assets && npm install && cd ..
```
  
### Usage

Start Phoenix endpoint.  
```bash
$ mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
  
### Test

```sh
$ cd PROJECT_ROOT
$ mix test
```
  
### Built With

- [Elixir](https://elixir-lang.org/) 1.7+  
- Web framework – [Phoenix](https://hexdocs.pm/phoenix/Phoenix.html) v1.4  
- Data store – PostgreSQL  
  

### Resources & Acknowledgments
  

##### Phoenix LiveView  

Use of [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) in this project was guided by, and is heavily based on,  

- [A LiveView Dashboard · Kabisa](https://www.theguild.nl/real-world-phoenix-of-groter-dan-a-liveview-dashboard/) _(Oostdijk, Apr 2019)_  
- [chrismccord/phoenix_live_view_example](https://github.com/chrismccord/phoenix_live_view_example)  
  
##### Miscellaneous  

- This file was inspired by [PurpleBooth/README-Template.md](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2).  


