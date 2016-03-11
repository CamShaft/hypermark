defmodule Mazurka.Resource.Utils do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def arguments do
    [router, params, input]
  end

  def router do
    {:_@mazurka_router, [warn: false], nil}
  end

  def params do
    {:_@mazurka_params, [warn: false], nil}
  end

  def input do
    {:_@mazurka_input, [warn: false], nil}
  end
end
