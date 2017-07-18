defmodule CoerceTest do
  use ExUnit.Case
  doctest Coerce

  test "greets the world" do
    assert Coerce.hello() == :world
  end

  test "Basic coercion works" do
    Coerce.coerce(1, "foo")
  end
end
