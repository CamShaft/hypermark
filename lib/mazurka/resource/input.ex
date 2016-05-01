defmodule Mazurka.Resource.Input do
  @moduledoc false

  use Mazurka.Resource.Utils.Global, var: :input

  @doc """
  Define an expected input for the resource

      input name

      input age, String.to_integer(&value)

      input address do
        Address.parse(&value)
      end
  """
  defmacro input(name, block \\ []) do
    Scope.define(Utils.input, name, block)
  end
end
