defmodule CoerceTest do
  use ExUnit.Case
  doctest Coerce

  test "Basic coercion works" do
    require Coerce
    Coerce.defcoercion(Integer, BitString) do
      def coerce(int, string) do
        {inspect(int), string}
      end
    end

    assert Coerce.coerce(1, "foo") == {"1", "foo"}
    assert Coerce.coerce("foo", 1) == {"foo", "1"}
  end

  test "Error raised when block without `def coerce(a, b)`" do
    assert_raise(Coerce.CompileError, fn ->
      require Coerce
      Coerce.defcoercion(BitString, Atom) do
        "Bla"
      end
    end)
  end

  test "Error raised when defcoercion called with non-atom as argument, already during compilation" do
    assert_raise(Coerce.CompileError, fn ->
      Code.eval_quoted(quote do
        require Coerce
        Coerce.defcoercion("improper", Tuple) do
          def coerce(int, string) do
            {inspect(int), string}
          end
        end
      end)
    end)
  end

  # TODO Sad path tests.
end
