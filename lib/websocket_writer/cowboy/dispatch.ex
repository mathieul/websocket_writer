defmodule WebsocketWriter.Cowboy.Dispatch do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      @dispatch []
      @default_dispatch { :_, Dynamo.Cowboy.Handler, ApplicationRouter }
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def dispatch do
        [ { :_, List.insert_at(@dispatch, -1, @default_dispatch) }]
      end
    end
  end

  defmacro match(path, [ to: to ]) do
    quote do
      @dispatch List.insert_at(@dispatch, -1, { unquote(path), unquote(to), [] })
    end
  end
end
