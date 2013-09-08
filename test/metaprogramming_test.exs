Code.require_file "test_helper.exs", __DIR__

defmodule Foo do
  defmacro make_tst(value) do
    quote do
      def tst, do: unquote(value)
    end
  end
end

defmodule Stuff do
  defmacro __using__(_) do
    quote do
      import Foo
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def my_val, do: @my_val
    end
  end

  defmacro init_val(value) do
    quote do: @my_val unquote(value)
  end

  defmacro add_val(value) do
    quote do: @my_val @my_val + unquote(value)
  end
end

defmodule Bar do
  import Foo
  make_tst 12
end

defmodule Machin do
  use Stuff
  make_tst 42
end

defmodule VarTst1 do
  use Stuff
  init_val 19
  add_val 2
end

defmodule VarTst2 do
  use Stuff
  init_val 42
  add_val 100
end

defmodule MetaprogrammingTest do
  use ExUnit.Case, async: true

  test "require" do
    assert Bar.tst == 12
  end

  test "use" do
    assert Machin.tst == 42
  end

  test "instance var" do
    assert VarTst1.my_val == 21
    assert VarTst2.my_val == 142
  end
end
