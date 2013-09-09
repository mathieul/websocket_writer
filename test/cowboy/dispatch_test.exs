Code.require_file "../test_helper.exs", __DIR__

defmodule Cowboy.DispatchTest do
  use ExUnit.Case, async: true

  defmodule NoRoutes do
    use WebsocketWriter.Cowboy.Dispatch
  end

  test "no routes defaults to the application router" do
    assert NoRoutes.dispatch == [{ :_, [{ :_, Dynamo.Cowboy.Handler, ApplicationRouter }] }]
  end

  defmodule Handler1 do; end
  defmodule Handler2 do; end
  defmodule TwoRoutes do
    use WebsocketWriter.Cowboy.Dispatch
    match "/one", to: Handler1
    match "/two", to: Handler2
  end

  test "#match inserts a dispatch route" do
    assert TwoRoutes.dispatch == [{ :_, [
      { "/one", Handler1, [] },
      { "/two", Handler2, [] },
      { :_, Dynamo.Cowboy.Handler, ApplicationRouter }
    ] }]
  end

  defmodule RootRoute do
    use WebsocketWriter.Cowboy.Dispatch
    root to: Handler1
  end

  test "#root inserts a dispatch route to '/'" do
    assert RootRoute.dispatch == [{ :_, [
      { "/", Handler1, [] },
      { :_, Dynamo.Cowboy.Handler, ApplicationRouter }
    ] }]
  end

  defmodule IntConstraint do
    use WebsocketWriter.Cowboy.Dispatch
    match "/:version", to: Handler1, constraints: [ version: :int ]
  end

  test "#match with an 'int' constraint" do
    assert IntConstraint.dispatch == [{ :_, [
      { "/:version", [ { :version, :int } ], Handler1, [] },
      { :_, Dynamo.Cowboy.Handler, ApplicationRouter }
    ] }]
  end
end
