defmodule Mazurka.Resource do
  @doc """
  Initialize a module as a mazurka resource

      defmodule My.Resource do
        use Mazurka.Resource
      end
  """
  defmacro __using__(_opts) do
    quote do
      use Mazurka.Resource.Condition
      use Mazurka.Resource.Event
      use Mazurka.Resource.Input
      use Mazurka.Resource.Let
      use Mazurka.Resource.Mediatype
      use Mazurka.Resource.Param
      use Mazurka.Resource.Params
      use Mazurka.Resource.Test
      use Mazurka.Resource.Validation

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      @behaviour Plug

      @doc """
      Initialize the plug
      """
      def init(opts), do: opts
      defoverridable init: 1

      @doc """
      Execute a plug request against the #{inspect(__MODULE__)} resource
      """
      def call(conn, opts) do
        conn = Plug.Conn.fetch_query_params(conn)
        accept = Mazurka.Resource.Utils.Accept.handle(Plug.Conn.get_req_header(conn, "accept"))
        router = mazurka__plug_router(conn)
        params = conn.params
        input = Map.merge(conn.query_params, conn.body_params)
        call(accept, router, params, input, conn, opts)
      end
      defoverridable call: 2

      defp mazurka__plug_router(conn) do
        conn.private[:mazurka_router]
      end
      defoverridable mazurka__plug_router: 1

      @doc """
      Execute a request against the #{inspect(__MODULE__)} resource

          accept = [
            {"application", "json", %{}},
            {"text", "*", %{}}
          ]
          router = My.Router
          params = %{"user" => "123"}
          input = %{"name" => "Joe"}
          conn = %Plug.Conn{}

          #{inspect(__MODULE__)}.call(accept, router, params, input, conn)
      """
      def call(content_types, router, params, input, conn, opts \\ []) do
        case mazurka__select_content_type(content_types) do
          nil ->
            raise Mazurka.UnacceptableContentTypeException, [
              content_type: content_types,
              acceptable: mazurka__acceptable_content_types()
            ]
          content_type ->
            {content_type, action(content_type, router, params, input, conn, opts)}
        end
      end
    end
  end
end
