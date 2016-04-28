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
      defp mazurka__match_affordance(unquote(mediatype) = unquote(Utils.mediatype), unquote_splicing(arguments), unquote(scope)) do
        affordance = Mazurka.Resource.Link.resolve(__MODULE__, unquote(mediatype), unquote_splicing(arguments))
        props = unquote(block)
        {unquote(mediatype).__handle_affordance__(affordance, props), unquote(conn)}
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def affordance(content_type = {_, _, _}, unquote_splicing(arguments)) do
        case mazurka__provide_content_type(content_type) do
          nil ->
            ## TODO should we provide a default link if we don't know how to handle this request?
            {nil, unquote(conn)}
          mediatype ->
            case mazurka__check_params(unquote(params)) do
              {[], []} ->
                scope = mazurka__scope(mediatype, unquote_splicing(arguments))
                case mazurka__conditions(unquote_splicing(arguments), scope) do
                  {:error, _} ->
                    {nil, unquote(conn)}
                  :ok ->
                    mazurka__match_affordance(mediatype, unquote_splicing(arguments), scope)
                end
              {missing, _} when length(missing) > 0 ->
                raise Mazurka.MissingParametersException, params: missing
              _ ->
                {nil, unquote(conn)}
            end
        end
      end

      defp mazurka__match_affordance(_, unquote_splicing(arguments), _) do
        {nil, unquote(conn)}
      end
    end
  end
end
