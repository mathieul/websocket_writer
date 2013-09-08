Code.require_file "../test_helper.exs", __DIR__

defmodule Cowboy.DispatchTest do
  use ExUnit.Case, async: true

  defmodule NoRoutes do
    use WebsocketWriter.Cowboy.Dispatch
  end

  defmodule Handler1 do
  end
  defmodule OneRoute do
    use WebsocketWriter.Cowboy.Dispatch
    match "/one", to: Handler1
  end

  defmodule Handler2 do
  end
  defmodule TwoRoutes do
    use WebsocketWriter.Cowboy.Dispatch
    match "/one", to: Handler1
    match "/two", to: Handler2
  end

  test "no routes defaults to the application router" do
    assert NoRoutes.dispatch == [{ :_, [{ :_, Dynamo.Cowboy.Handler, ApplicationRouter }] }]
  end

  test "#match insert a dispatch route, 1 route" do
    assert OneRoute.dispatch == [{ :_, [
      { "/one", Handler1, [] },
      { :_, Dynamo.Cowboy.Handler, ApplicationRouter }
    ] }]
  end

  test "#match insert a dispatch route, 2 routes" do
    assert TwoRoutes.dispatch == [{ :_, [
      { "/one", Handler1, [] },
      { "/two", Handler2, [] },
      { :_, Dynamo.Cowboy.Handler, ApplicationRouter }
    ] }]
  end
end
