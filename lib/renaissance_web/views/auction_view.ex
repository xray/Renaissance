defmodule RenaissanceWeb.AuctionView do
  use RenaissanceWeb, :view

  @format "{WDshort}, {D} {Mshort} {YYYY} {h24}:{m} {Zabbr}"

  def default_end do
    current = local_datetime()

    %{
      day: current.day,
      hour: current.hour,
      minute: current.minute,
      month: current.month,
      year: current.year
    }
  end

  def local_datetime do
    DateTime.utc_now() |> local_datetime
  end

  def local_datetime(utc_time) do
    utc_time |> Timex.Timezone.convert(:local)
  end

  def puts_utc_as_local do
    DateTime.utc_now() |> puts_utc_as_local
  end

  def puts_utc_as_local(utc_time) do
    utc_time
    |> local_datetime()
    |> Timex.format!(@format)
  end

  def puts_utc do
    DateTime.utc_now() |> puts_utc
  end

  def puts_utc(utc_time) do
    Timex.format!(utc_time, @format)
  end
end
