defmodule Mazurka.Resource.Utils do
  @moduledoc false

  def arguments do
    [params(), input(), conn(), router(), opts()]
  end

  def router do
    {:"$mazurka_router", [warn: false], nil}
  end

  def params do
    {:"$mazurka_params", [warn: false], nil}
  end

  def input do
    {:"$mazurka_input", [warn: false], nil}
  end

  def conn do
    {:"$mazurka_conn", [warn: false], nil}
  end

  def opts do
    {:"$mazurka_opts", [warn: false], nil}
  end

  def mediatype do
    {:"$mazurka_mediatype", [warn: false], nil}
  end

  def scope do
    {:"$mazurka_scope", [warn: false], nil}
  end
end
