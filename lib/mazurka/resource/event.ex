defmodule Mazurka.Resource.Event do
  use Mazurka.Resource.Utils

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @doc false
      defp event(_, unquote_splicing(arguments)) do
        nil
      end
      defoverridable event: unquote(length(arguments) + 1)
    end
  end

  @doc """
  Create an event block

      event do
        # event goes here
      end
  """
  defmacro event([do: block]) do
    quote do
      @doc false
      defp event(var!(action), unquote_splicing(arguments)) do
        super(var!(action), unquote_splicing(arguments))
        unquote(block)
        var!(action)
      end
      defoverridable event: unquote(length(arguments) + 1)
    end
  end
end
