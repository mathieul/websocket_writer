defmodule WebsocketWriter.Cowboy.Dispatch do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      @dispatch []
      @default { Dynamo.Cowboy.Handler, ApplicationRouter }
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def dispatch do
        paths = [ default_dispatch(@default) | @dispatch ]
        [ { :_, Enum.reverse(paths) } ]
      end
    end
  end

  def default_dispatch({ mod, options }) do
    { :_, mod, options }
  end

  defmacro default(options) do
    to   = Keyword.get options, :to, Dynamo.Cowboy.Handler
    with = Keyword.get options, :with, ApplicationRouter
    quote do: @default { unquote(to), unquote(with) }
  end

  defmacro root([ to: to ]) do
    quote do
      path = { "/", unquote(to), [] }
      @dispatch [ path | @dispatch ]
    end
  end

  defmacro match(path, options) do
    to          = Keyword.get options, :to, nil
    constraints = Keyword.get options, :constraints, nil

    path = cond do
      !Keyword.has_key?(options, :to) ->
        raise ArgumentError, message: "Expected :to to be given as option"
      constraints -> quote do: { unquote(path), unquote(constraints), unquote(to), [] }
      true        -> quote do: { unquote(path), unquote(to), [] }
    end

    quote bind_quoted: [ path: path ] do
      @dispatch [ path | @dispatch ]
    end
  end
end
