defmodule WebsocketWriter.Cowboy.HandlerBuilderTest do
  use ExUnit.Case, async: true

  defmodule WebsocketBasic do
    use WebsocketWriter.Cowboy.HandlerBuilder
    make_handler :websocket, protocol: :https
  end

  test "generate websocket init callback with #make_handler(:websocket)" do
    assert WebsocketBasic.init({ :tcp, :https }, :req, :opts) ==
           { :upgrade, :protocol, :cowboy_websocket, :req, [ init: :opts ] }
  end
end
