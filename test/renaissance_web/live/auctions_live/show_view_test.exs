defmodule RenaissanceWeb.AuctionsLive.ShowViewTest do
  use RenaissanceWeb.ConnCase, async: true
  import RenaissanceWeb.AuctionsLive.Show

  @ny_2030 Timex.to_datetime({{2030, 1, 1}, {0, 0, 0}}, "UTC")

  describe "time_remaining/2" do
    test "returns zero if start time is after end time" do
      nye_2029 = Timex.to_datetime({{2029, 12, 31}, {23, 59, 59}}, "UTC")
      assert 0 == time_remaining(@ny_2030, nye_2029)
    end

    test "returns zero if both start & end time are in the past" do
      nye_2018 = Timex.to_datetime({{2018, 12, 31}, {23, 59, 59}}, "UTC")
      ny_2019 = Timex.to_datetime({{2019, 1, 1}, {0, 0, 0}}, "UTC")
      assert 0 == time_remaining(nye_2018, ny_2019)
    end

    test "returns time remaining for valid inputs" do
      july4th_2030_random_time = Timex.to_datetime({{2030, 7, 4}, {12, 30, 7}}, "UTC")
      expected = "6 months, 4 days, 12 hours, 30 minutes, 7 seconds"
      assert expected == time_remaining(@ny_2030, july4th_2030_random_time)
    end

    test "returns updated time remaining for valid inputs" do
      end_time =
        Timex.add(DateTime.utc_now(), %Timex.Duration{
          megaseconds: 0,
          seconds: 10,
          microseconds: 0
        })

      before_sleep = time_remaining(end_time)
      :timer.sleep(2000)
      after_sleep = time_remaining(end_time)

      assert before_sleep > after_sleep
    end
  end
end
