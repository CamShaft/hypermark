defmodule Mazurka.Resource.Param do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro param(name, opts \\ []) do
    to_quoted(name, opts)
  end

  defp to_quoted(name, [do: block]) do
    block = replace_value(name, block)

    {:defmacrop, [], [name, [
      do: {:quote, [], [[
        do: block]]}]]}
  end

  defp replace_value(name, block) do
    params_get = params_get(name)
    Mazurka.Compiler.Utils.postwalk(block, fn
      ({:&, _, [{:value, _, _}]}) ->
        params_get
      (other) ->
        other
    end)
  end

  defp params_get({name, _meta, _context}) when is_atom(name) do
    params_get(name)
  end
  defp params_get(name) when is_atom(name) do
    quote do
      require Mazurka.Resource.Params
      Mazurka.Resource.Params.get(unquote(to_string(name)))
    end
  end
end
