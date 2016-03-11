defmodule Mazurka.Resource.Event do
  use Mazurka.Resource.Utils

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @doc false
      defp event(unquote_splicing(arguments)) do
        nil
      end
      defoverridable event: unquote(length(arguments))
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
      defp event(unquote_splicing(arguments)) do
        super(unquote_splicing(arguments))
        unquote({:__block__, [], block})
      end
      defoverridable event: unquote(length(arguments))
    end
  end
end
