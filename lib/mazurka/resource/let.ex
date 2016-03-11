defmodule Mazurka.Resource.Let do
  use Mazurka.Resource.Utils

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc """
  Define a resource-wide variable

      let foo = 1
  """
  defmacro let({:=, meta, [name, block]}) do
    to_quoted(name, meta, block)
  end

  @doc """
  Define a resource-wide variable with a block

      let foo do
        id = Params.get("user")
        User.get(id)
      end
  """
  defmacro let(name, [do: block]) do
    to_quoted(name, [], block)
  end

  defp to_quoted(name, meta, block) do
    {:defmacrop, meta, [name, [
      do: {:quote, [], [[
        do: block]]}]]}
  end
end
