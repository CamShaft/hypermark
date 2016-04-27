defmodule Mazurka.Resource.Utils do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def arguments do
    [router, params, input, conn, opts]
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

  def conn do
    {:_@mazurka_conn, [warn: false], nil}
  end

  def opts do
    {:_@mazurka_opts, [warn: false], nil}
  end
end
