# NOTE tests that call :timer.sleep/1 are tagged as `:sleeps`;
#      excluding them significantly decreases run time
# ExUnit.start(exclude: [:sleeps])
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Renaissance.Repo, :manual)
