defmodule Mazurka.Compiler.Utils do
  def eval(quoted, env) do
    {out, []} = quoted
    |> Macro.expand(env)
    |> Code.eval_quoted([], env)
    out
  end

  def expand(quoted, env) do
    do_expand(quoted, env)
  end

  def prewalk(quoted, fun) do
    Macro.prewalk(quoted, walk(fun, &prewalk(&1, fun)))
  end

  def postwalk(quoted, fun) do
    Macro.postwalk(quoted, walk(fun, &postwalk(&1, fun)))
  end

  defp walk(fun, recurse) do
    fn
      ({:__block__, meta, children}) ->
        {:__block__, meta, Enum.map(children, recurse)}
      ([{:do, _} | _] = doblock) ->
        Enum.map(doblock, fn({key, children}) ->
          children = recurse.(children)
          {key, children}
        end)
        |> fun.()
      ({name, children}) when is_atom(name) ->
        children = recurse.(children)
        {name, children}
        |> fun.()
      (other) ->
        other
        |> fun.()
    end
  end

  defp do_expand(quoted, env) do
    postwalk(quoted, fn
      other ->
        Macro.expand(other, env)
    end)
  end

  def register(name, block) do
    register(name, block, nil)
  end
  def register(name, block, meta) do
    register(nil, name, block, meta)
  end
  def register(mediatype, name, block, meta) do
    {{:., [],
        [{:__aliases__, [alias: false], [:Mazurka, :Compiler, :Utils]}, :save]}, [],
       [mediatype, name, block, meta]}
    |> Mazurka.Compiler.Kernel.wrap
  end

  defmacro save(mediatype, name, block, meta) do
    mediatype = eval(mediatype, __CALLER__)
    put(__CALLER__, mediatype, name, block, meta)
  end

  def put(caller, mediatype, name, value, meta \\ nil) do
    module = caller.module
    Module.register_attribute(module, __MODULE__, accumulate: true)
    Module.put_attribute(module, __MODULE__, {mediatype, name, value, meta})
    nil
  end

  def get(caller) do
    caller.module
    |> Module.get_attribute(__MODULE__)
    |> reverse()
  end
  def get(caller, name) do
    get(caller)
    |> Enum.filter(fn({_, item, _, _}) ->
      item == name
    end)
  end

  defp reverse(nil), do: []
  defp reverse(list), do: :lists.reverse(list)
end
