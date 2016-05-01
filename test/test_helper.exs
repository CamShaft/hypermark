defmodule Test.Mazurka.Case do
  defmacro __using__(_) do
    quote do
      use ExUnit.Case
      import unquote(__MODULE__)
    end
  end

  defmacro context(name, [do: body, after: tests]) do
    {name, _} = Code.eval_quoted(name)
    cname = Module.concat([__CALLER__.module, name])
    quote do
      defmodule unquote(cname) do
        Module.register_attribute(__MODULE__, :aliases, accumulate: true)
        unquote(body)
        @before_compile Test.Mazurka.Case
      end
      unquote(for {:->, _, [[test_name | args], body]} <- tests do
        quote do
          test unquote_splicing(["#{test_name} | #{inspect(name)}" | args]) do
            use unquote(cname)
            unquote(body)
            true
          end
        end
      end)
    end
  end

  defmacro resource(name, [do: body]) do
    quote do
      defmodule unquote(name) do
        use Mazurka.Resource
        unquote(body)
      end

      @aliases unquote(name)
    end
  end

  defmacro router(name, [do: body]) do
    quote do
      defmodule unquote(name) do
        unquote(body)
        def resolve(_, _, _, _, _) do
          throw :undefined_route
        end
      end

      @aliases unquote(name)
    end
  end

  defmacro route(method, path, resource) do
    quote do
      def resolve(unquote(resource), params, input, _conn, opts) do
        %Mazurka.Affordance{
          resource: unquote(resource),
          method: unquote(method),
          params: params,
          path: "/" <> Enum.join(Enum.map(unquote(path), fn
            (param) when is_atom(param) ->
              Map.get(params, to_string(param))
            (part) ->
              part
          end), "/"),
          input: input,
          query: case URI.encode_query(input) do
                   "" -> nil
                   other -> other
                 end,
          fragment: opts[:fragment]
        }
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      defmacro __using__(_) do
        for alias <- @aliases do
          {:alias, [warn: false], [alias]}
        end
        ++ for alias <- @aliases do
          ## so we don't get unused alias warnings
          {:__aliases__, [], [Module.split(alias) |> List.last |> String.to_atom()]}
        end
      end
    end
  end
end

ExUnit.start()
