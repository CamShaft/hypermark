defmodule Mazurka.Router do
  use Behaviour

  @type conn :: any

  @doc """
  TODO write the docs
  """
  defcallback resolve(Mazurka.Affordance.t, Mazurka.Resource.Link.source, conn)

  @doc """
  TODO write the docs
  """
  defcallback resolve_resource(module, Mazurka.Resource.Link.source, conn)
end
