defmodule WebsocketWriter.Cowboy do
  def make_dispatch(routes) do
    [{ :_, [{ :_, Dynamo.Cowboy.Handler, ApplicationRouter }] }]
  end
end
