defmodule WebsocketWriter.Cowboy.HandlerBuilder do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro make_handler(type, options // []) do
    unless type == :websocket do
      raise ArgumentError, message: "Expected handler type to be :websocket."
    end
    protocol = Keyword.get options, :protocol, :http
    quote do
      def init({ :tcp, unquote(protocol) }, req, opts) do
        state = [ init: opts ]
        { :upgrade, :protocol, :cowboy_websocket, req, state }
      end
    end
  end
end
