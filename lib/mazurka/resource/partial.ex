defmodule Mazurka.Resource.Partial do
  defmacro partial(mediatype, {name, _, arguments}, [do: block]) do
    Mazurka.Compiler.Utils.register(mediatype, __MODULE__, block, {name, arguments})
  end

  def format_name({name, _arguments}) do
    name
  end

  def compile(_mediatype, block, globals, {_, arguments}) do
    arguments = Enum.map(arguments, fn({arg, _, _} = var) ->
      quote do
        unquote(var) = ^Dict.get(prop(:params), unquote(arg |> to_string))
      end
    end)

    quote do
      unquote_splicing(arguments)
      unquote_splicing(globals[:param] || [])
      unquote_splicing(globals[:let] || [])
      unquote(block)
    end
    |> Mazurka.Compiler.Utils.postwalk(fn(expr) ->
      expr
      |> Mazurka.Resource.Param.format(:prop)
      |> Mazurka.Resource.Input.format(:prop)
      |> Mazurka.Resource.Resource.format(:prop)
    end)
  end
end