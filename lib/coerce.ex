defmodule Coerce do
  @moduledoc """
  Documentation for Coerce.
  """

  @builtin_guards_list [
    is_tuple: Tuple,
    is_atom: Atom,
    is_list: List,
    is_map: Map,
    is_bitstring: BitString,
    is_integer: Integer,
    is_float: Float,
    is_function: Function,
    is_pid: PID,
    is_port: Port,
    is_reference: Reference]

  def coerce(a = %a_mod{}, b = %a_mod{}) do
    {a, b}
  end
  def coerce(a = %a_mod{}, b = %b_mod{}) do
    Module.concat([Coerce.Implementations, a_mod, b_mod]).coerce(a, b)
  end

  for {guard_a, a_mod} <- @builtin_guards_list, {guard_b, b_mod} <- @builtin_guards_list do
    if guard_a == guard_b do
      def coerce(a, b) when unquote(guard_a)(a) and unquote(guard_a)(b) do
        {a, b}
      end
    else
      primary_module = Module.concat([Coerce.Implementations, a_mod, b_mod])
      IO.puts(primary_module)
      if Code.ensure_compiled?(primary_module) do
        IO.puts("TEST")
        def coerce(a, b) when unquote(guard_a)(a) and unquote(guard_b)(b) do
          unquote(primary_module).coerce(a, b)
        end
      end
    end
  end

  defmodule Behaviour do
    @callback coerce(a, b) :: {a, a} when a: any, b: any
  end

  defmodule Implementations do
  end
end
