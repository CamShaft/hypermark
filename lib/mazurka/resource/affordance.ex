defmodule Mazurka.Resource.Affordance do
  use Mazurka.Resource.Utils

  defmacro __using__(_) do
    quote do
      @doc """
      Create an affordance block

          mediatype #{inspect(__MODULE__)} do
            affordance do
              # affordance goes here
            end
          end
      """
      defmacro affordance(block) do
        mediatype = __MODULE__
        quote do
          require Mazurka.Resource.Affordance
          Mazurka.Resource.Affordance.affordance(unquote(mediatype), unquote(block))
        end
      end
    end
  end

  @doc """
  Create an affordance block for a mediatype

      affordance Mazurka.Mediatype.MyCustomMediatype do
        # affordance goes here
      end
  """
  defmacro affordance(mediatype, [do: block]) do
    quote do
      defp mazurka__match_affordance(unquote(mediatype), resource, unquote_splicing(arguments)) do
        affordance = Mazurka.Resource.Link.resolve(resolve, unquote_splicing(arguments))
        props = unquote(block)
        unquote(mediatype).__handle_affordance__(affordance, props)
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      @doc """
      TODO write docs
      """
      def affordance(content_type, unquote_splicing(arguments)) do
        case mazurka__provide_content_type(content_type) do
          nil ->
            ## TODO should we provide a default link if we don't know how to handle this request?
            nil
          mediatype ->
            case mazurka__conditions(unquote_splicing(arguments)) do
              {:error, _} ->
                nil
              :ok ->
                mazurka__match_affordance(mediatype, unquote_splicing(arguments))
            end
        end
      end

      defp mazurka__match_affordance(_, unquote_splicing(arguments)) do
        nil
      end
    end
  end
end
