defmodule Mazurka.Resource.Link do
  @moduledoc false

  use Mazurka.Resource.Utils

  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :mazurka_links, accumulate: true)
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  @doc """
  Link to another resource
  """
  defmacro link_to(resource, params \\ nil, input \\ nil, opts \\ []) do
    params = format_params(params)
    input = format_params(input)
    Module.put_attribute(__CALLER__.module, :mazurka_links, resource)
    quote do
      link = unquote(resource).affordance(
        unquote(Utils.mediatype),
        unquote(params),
        unquote(input),
        unquote(Utils.conn),
        unquote(Utils.router),
        unquote(opts)
      )
      case link do
        nil ->
          unquote(Utils.mediatype).__undefined_link__
        _ ->
          link
      end
    end
  end

  @doc """
  Transition to another resource
  """
  defmacro transition_to(resource, params \\ nil, input \\ nil, opts \\ []) do
    params = format_params(params)
    input = format_params(input)
    quote do
      conn = unquote(Utils.conn)

      target = Mazurka.Resource.Link.resolve(
        unquote(resource),
        unquote(params),
        unquote(input),
        conn,
        unquote(Utils.router),
        unquote(opts)
      )

      private = Map.put(conn.private, :mazurka_transition, target)

      unquote(Utils.conn) = %{conn | private: private}
    end
  end

  @doc """
  Invalidate another resource
  """
  defmacro invalidates(resource, params \\ nil, input \\ nil, opts \\ []) do
    params = format_params(params)
    input = format_params(input)
    quote do
      conn = unquote(Utils.conn)

      target = Mazurka.Resource.Link.resolve(
        unquote(resource),
        unquote(params),
        unquote(input),
        conn,
        unquote(Utils.router),
        unquote(opts)
      )

      private = Map.update(conn.private, :mazurka_invalidations, [target], &[target | &1])

      unquote(Utils.conn) = %{conn | private: private}
    end
  end

  defp format_params(nil) do
    {:%{}, [], []}
  end
  defp format_params({:%{}, meta, items}) do
    {:%{}, meta, Enum.map(items, fn({name, value}) ->
      {to_string(name), value}
    end)}
  end
  defp format_params(items) when is_list(items) do
    {:%{}, [], Enum.map(items, fn({name, value}) ->
      {to_string(name), value}
    end)}
  end
  defp format_params(other) do
    quote do
      Enum.reduce(unquote(other), %{}, fn({name, value}, acc) ->
        Map.put(acc, to_string(name), value)
      end)
    end
  end

  defmacro resolve(resource, params, input, conn, router, opts) do
    quote bind_quoted: binding do
      case router do
        nil ->
          raise Mazurka.MissingRouterException, resource: resource, params: params, input: input, conn: conn, opts: opts
        router ->
          router.resolve(resource, params, input, conn, opts)
      end
    end
  end

  defmacro self_link do
    quote do
      unquote(__MODULE__).resolve(__MODULE__, unquote(Utils.params), unquote(Utils.input), unquote(Utils.conn), unquote(Utils.router), unquote(Utils.opts))
    end
  end

  defmacro __before_compile__(_) do
    quote unquote: false do
      links = @mazurka_links |> Enum.uniq() |> Enum.sort()
      def links do
        unquote(links)
      end
    end
  end
end
