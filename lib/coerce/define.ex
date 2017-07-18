defmodule Coerce.Define do
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
