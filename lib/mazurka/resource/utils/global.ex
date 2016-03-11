defmodule Mazurka.Resource.Utils.Global do
  defmacro __using__(opts) do
    var_name = opts[:var]

    quote bind_quoted: binding do
      require Mazurka.Resource.Utils

      defmacro __using__(_) do
        quote do
          require unquote(__MODULE__)
          alias unquote(__MODULE__)
        end
      end

      defmacro get() do
        Mazurka.Resource.Utils.unquote(var_name)()
      end

      defmacro get(name) when is_atom(name) do
        value = Mazurka.Resource.Utils.unquote(var_name)()
        name = to_string(name)
        quote do
          unquote(value)[unquote(name)]
        end
      end
      defmacro get(name) when is_binary(name) do
        value = Mazurka.Resource.Utils.unquote(var_name)()
        quote do
          unquote(value)[unquote(name)]
        end
      end
      defmacro get(name) do
        value = Mazurka.Resource.Utils.unquote(var_name)()
        quote do
          unquote(value)[to_string(unquote(name))]
        end
      end

      defmacro get(name, fallback) do
        quote do
          value = unquote(__MODULE__).get(unquote(name))
          if value == nil do
            unquote(fallback)
          else
            value
          end
        end
      end
    end
  end
end
