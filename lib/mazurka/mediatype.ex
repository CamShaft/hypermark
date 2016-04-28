defmodule Mazurka.Mediatype do
  use Behaviour

  @type ast :: Macro.t
  @type props :: Map.t
  defmacrocallback __handle_action__(ast) :: any
  defmacrocallback __handle_affordance__(ast, props) :: any
  defcallback __content_types__() :: [{binary, binary, binary, module}]

  @doc """
  Create a mediatype with default macros for action, affordance, error, and provides

      defmodule Mazurka.Mediatype.MyMediatype do
        use Mazurka.Mediatype
      end
  """
  defmacro __using__(_) do
    quote unquote: false do
      @behaviour Mazurka.Mediatype
      alias Mazurka.Resource.Utils

      defmacro __using__(_) do
        content_types = __content_types__ |> Macro.escape()
        quote do
          require Mazurka.Resource.Provides
          Mazurka.Resource.Provides.__mediatype_provides__(unquote(__MODULE__), unquote(content_types))
          import unquote(__MODULE__)

          defp mazurka__default_affordance(unquote(__MODULE__) = unquote(Utils.mediatype), unquote_splicing(Utils.arguments), unquote(Utils.scope)) do
            affordance = Mazurka.Resource.Link.resolve(__MODULE__, unquote_splicing(Utils.arguments))
            unquote(__MODULE__).__handle_affordance__(affordance, nil)
          end
        end
      end

      use Mazurka.Resource.Action
      use Mazurka.Resource.Affordance
      use Mazurka.Resource.Provides
    end
  end
end
