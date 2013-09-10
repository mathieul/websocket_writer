defmodule WebsocketWriter.Cowboy.HandlerBuilder do

  defmodule Websocket do
    defmacro on_init(options // []) do
      protocol = Keyword.get options, :protocol, :http
      quote do
        def init({ :tcp, unquote(protocol) }, req, opts) do
          state = [ init: opts ]
          { :upgrade, :protocol, :cowboy_websocket, req, state }
        end
      end
    end
  end

  defmacro __using__(options) do
    builder = case Keyword.get(options, :type) do
      :websocket -> Websocket
      _ -> raise ArgumentError, message: "Expected handler type to be :websocket."
    end
    quote do
      import unquote(builder)
    end
  end
end
