defmodule Mazurka.Resource.Utils.Scope do
  @moduledoc false

  alias Mazurka.Resource.Utils

  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :scope, [accumulate: true])
      @before_compile unquote(__MODULE__)
    end
  end

  def define(var, name, block \\ [])
  def define(var, {name, _, _}, block) when is_atom(name) do
    bin_name = to_string(name)
    block = replace_value(var, bin_name, block)
    compile(name, block)
  end

  defp replace_value(var, name, []) do
    var_get(var, name)
  end
  defp replace_value(var, name, [do: block]) do
    replace_value(var, name, block)
  end
  defp replace_value(var, name, block) do
    params_get = var_get(var, name)
    Mazurka.Utils.postwalk(block, fn
      ({:&, _, [{:value, _, _}]}) ->
        params_get
      (other) ->
        other
    end)
  end

  defp var_get(var, name) do
    quote do
      Map.get(unquote(var), unquote(name))
    end
  end

  def compile({name, _, _}, block) when is_atom(name) do
    compile(name, block)
  end
  def compile(name, block) do
    body = Macro.escape(get(name))

    quote do
      @scope unquote(name)
      defmacrop unquote(name)() do
        unquote(body)
      end

      defp unquote(name)(unquote(Utils.mediatype), unquote_splicing(Utils.arguments)) do
        unquote(block)
      end
    end
  end

  defp get(name) do
    quote do
      Map.get(unquote(Utils.scope), unquote(name))
    end
  end

  defmacro __before_compile__(env) do
    variables = Module.get_attribute(env.module, :scope) || []
    quote do
      defp mazurka__scope(unquote(Utils.mediatype), unquote_splicing(Utils.arguments)) do
        %{unquote_splicing(for variable <- variables do
          {variable, {variable, [], [Utils.mediatype | Utils.arguments]}}
        end)}
      end
    end
  end
end
