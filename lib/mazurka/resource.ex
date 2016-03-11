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
      @doc """
      Execute a request against the #{inspect(__MODULE__)} resource

          accept = [
            {"application", "json", %{}},
            {"text", "*", %{}}
          ]
          router = My.Router
          params = %{"user" => "123"}
          input = %{"name" => "Joe"}

          #{inspect(__MODULE__)}.call(accept, router, params, input)
      """
      def call(content_types, router, params, input) do
        case mazurka__select_content_type(content_types) do
          nil ->
            raise Mazurka.UnacceptableContentTypeException, [
              content_type: content_types,
              acceptable: mazurka__acceptable_content_types()
            ]
          content_type ->
            {content_type, action(content_type, router, params, input)}
        end
      end
    end
  end
end
