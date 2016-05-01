defmodule Mazurka.Resource.Utils.Scope do
  @moduledoc false

  alias Mazurka.Resource.Utils

  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :scope, [accumulate: true])
      @before_compile unquote(__MODULE__)
    end
  end

  def compile(name, block) do
    name = elem(name, 0)
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
