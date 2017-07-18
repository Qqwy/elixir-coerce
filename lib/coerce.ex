defmodule Coerce do
  @moduledoc """
  Documentation for Coerce.
  """

  @builtin_guards_list [
    {:is_success_tuple,  FunLand.Builtin.SuccessTuple},
    is_tuple: FunLand.Builtin.Tuple,
    is_atom: FunLand.Builtin.Atom,
    is_list: FunLand.Builtin.List,
    is_map: FunLand.Builtin.Map,
    is_bitstring: FunLand.Builtin.BitString,
    is_integer: FunLand.Builtin.Integer,
    is_float: FunLand.Builtin.Float,
    is_function: FunLand.Builtin.Function,
    is_pid: FunLand.Builtin.PID,
    is_port: FunLand.Builtin.Port,
    is_reference: FunLand.Builtin.Reference]

  def coerce(a = %a_mod{}, b = %a_mod{}) do
    {a, a}
  end
  def coerce(a = %a_mod{}, b = %b_mod{}) do
    # :"Elixir.Coerce.Implementations.#{a_mod}.#{b_mod}".coerce(a, b)
    Module.concat([Coerce.Implementations, a_mod, b_mod]).coerce(a, b)
  end

  for {guard_a, a_mod} <- @builtin_guards_list, {guard_b, b_mod} <- @builtin_guards_list do
    if guard_a == guard_b do
      def coerce(a, b) when guard_a(a) and guard_a(b) do
        {a, b}
      end
    else
      def coerce(a, b) when guard_a(a) and guard_b(b) do
        Module.concat([Coerce.Implementations, a_mod, b_mod]).coerce(a, b)
      end
    end
  end


  defmacro defcoercion(first_module, second_module, [do: block]) do
    # primary_module = :"Elixir.Coerce.Implementations.#{first_module}.#{second_module}"
    # secondary_module = :"Elixir.Coerce.Implementations.#{second_module}.#{first_module}"
    primary_module = Module.concat(Coerce.Implementations, first_module, second_module)
    secundary_module = Module.concat(Coerce.Implementations, second_module, first_module)
    quote bind_quoted: [primary_module: primary_module, secondary_module: secondary_module] do
      defmodule primary_module do
        @behaviour Coerce.Behaviour
        unquote(block)
      end
      unless Module.defines?(primary_module, :coerce, 2) do
        raise "Error: `Coerce.defcoercion` implementation does not implement `coerce/2`."
      end

      defmodule secondary_module do
        def coerce(lhs, rhs) do
          {rhs, lhs} = primary_module.coerce(rhs, lhs)
          {lhs, rhs}
        end
      end
    end
  end
  defmacro defcoercion(_, _, _), do: raise "Error: `Coerce.defcoercion` called with improper parameters."

  defmodule Behaviour do
    @callback coerce(a, b) :: {a, a} when a: any, b: any
  end
end
