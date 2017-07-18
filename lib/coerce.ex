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

  for {guard, mod} <- @builtin_guards_list do
    def coerce(a = %a_struct_mod{}, b) when unquote(guard)(b) do
      Module.concat([Coerce.Implementations, a_struct_mod, unquote(mod)]).coerce(a, b)
    end

    def coerce(a, b = %b_struct_mod{}) when unquote(guard)(a) do
      Module.concat([Coerce.Implementations, unquote(mod), b_struct_mod]).coerce(a, b)
    end
  end

  for {guard_a, a_mod} <- @builtin_guards_list, {guard_b, b_mod} <- @builtin_guards_list do
    if guard_a == guard_b do
      def coerce(a, b) when unquote(guard_a)(a) and unquote(guard_a)(b) do
        {a, b}
      end

    else
      primary_module = Module.concat([Coerce.Implementations, a_mod, b_mod])
      def coerce(a, b) when unquote(guard_a)(a) and unquote(guard_b)(b) do
        # Uses Kernel.apply to mitigate warning if module does not exist...
        apply(unquote(primary_module), :coerce, [a, b])
      end
    end
  end

  defmodule Behaviour do
    @callback coerce(a, b) :: {a, a} when a: any, b: any
  end

  defmodule Implementations do
  end

  defmacro defcoercion(first_module, second_module, [do: block]) do
    primary_module = Module.concat([Coerce.Implementations, Macro.expand_once(first_module, __CALLER__), Macro.expand_once(second_module, __CALLER__)])
    secondary_module = Module.concat([Coerce.Implementations, Macro.expand_once(second_module, __CALLER__), Macro.expand_once(first_module, __CALLER__)])
    res = quote do
      defmodule unquote(primary_module) do
        unquote(block)
      end
      unless function_exported?(unquote(primary_module), :coerce, 2) do
        raise "Error: `Coerce.defcoercion` implementation does not implement `coerce/2`."
      end

      defmodule unquote(secondary_module) do
        def coerce(lhs, rhs) do
          {rhs, lhs} = unquote(primary_module).coerce(rhs, lhs)
          {lhs, rhs}
        end
      end
    end
    IO.puts(Macro.to_string(res))
    res
  end
  defmacro defcoercion(_, _, _), do: raise "Error: `Coerce.defcoercion` called with improper parameters."
end
