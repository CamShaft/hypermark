defmodule Mazurka.Resource.Mediatype.UndefinedMediatype do
  @moduledoc """
  TODO write the docs
  """

  defexception [:mediatype]

  def message(%{mediatype: mediatype}) do
    "Undefined mediatype #{mediatype}"
  end
end

defmodule Mazurka.Resource.Mediatype do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      @before_compile Mazurka.Resource.Action
      @before_compile Mazurka.Resource.Affordance
      @before_compile Mazurka.Resource.Provides
    end
  end

  defmacro mediatype(name, [do: block]) do
    module = name
    |> Mazurka.Utils.eval(__CALLER__)
    |> resolve()

    quote do
      use unquote(module)
      unquote(block)
      import unquote(module), only: [], warn: false
    end
  end

  defp resolve(module) do
    resolve([module, Module.concat(Mazurka.Mediatype, module)], module)
  end

  defp resolve([], module) do
    raise __MODULE__.UndefinedMediatype, mediatype: to_string(module)
  end
  defp resolve([mod | rest], module) do
    mod.module_info() && mod
  catch
    _, _ ->
      resolve(rest, module)
  end
end
