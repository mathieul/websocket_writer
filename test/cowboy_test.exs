Code.require_file "test_helper.exs", __DIR__

defmodule CowboyTest do
  use ExUnit.Case, async: true
  alias WebsocketWriter.Cowboy

  defmodule NoRoutes do
  end

  test "#make_dispatch with an empty module routes to the application router" do
    assert Cowboy.make_dispatch(NoRoutes) == [{ :_, [{ :_, Dynamo.Cowboy.Handler, ApplicationRouter }] }]
  end
end
