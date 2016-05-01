defmodule Mazurka.Resource.Param do
  @moduledoc false

  use Mazurka.Resource.Utils
  alias Mazurka.Resource.Utils.Scope

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      defp mazurka__check_params(_) do
        {[], []}
      end
      defoverridable mazurka__check_params: 1
    end
  end

  @doc """
  Define an expected parameter for the resource

      param user

      param user, User.get(&value)

      param user do
        User.get(&value)
      end
  """
  defmacro param(name, block \\ []) do
    bin_name = elem(name, 0) |> to_string()
    block = replace_value(bin_name, block)
    [
      Scope.compile(name, block),
      quote do
        defp mazurka__check_params(params) do
          {missing, nil_params} = super(params)
          case Map.fetch(params, unquote(bin_name)) do
            :error ->
              {[unquote(bin_name) | missing], nil_params}
            {:ok, nil} ->
              {missing, [unquote(bin_name) | nil_params]}
            _ ->
              {missing, nil_params}
          end
        end
      end
    ]
  end

  defp replace_value(name, []) do
    params_get(name)
  end
  defp replace_value(name, [do: block]) do
    replace_value(name, block)
  end
  defp replace_value(name, block) do
    params_get = params_get(name)
    Mazurka.Utils.postwalk(block, fn
      ({:&, _, [{:value, _, _}]}) ->
        params_get
      (other) ->
        other
    end)
  end

  defp params_get(name) do
    quote do
      Map.get(unquote(Utils.params), unquote(name))
    end
  end
end
