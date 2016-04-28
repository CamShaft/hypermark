defmodule Mazurka.Resource.Let do
  alias Mazurka.Resource.Utils.Scope

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc """
  Define a resource-wide variable

      let foo = 1
  """
  defmacro let({:=, _, [name, block]}) do
    Scope.compile(name, block)
  end

  @doc """
  Define a resource-wide variable with a block

      let foo do
        id = Params.get("user")
        User.get(id)
      end
  """
  defmacro let(name, [do: block]) do
    Scope.compile(name, block)
  end
end
