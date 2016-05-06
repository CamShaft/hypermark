defprotocol Mazurka.Router do
  @doc """
  TODO write the docs
  """

  def resolve(router, affordance, source, conn)

  @doc """
  TODO write the docs
  """

  def resolve_resource(router, module, source, conn)
end

defimpl Mazurka.Router, for: Atom do
  def resolve(router, affordance, source, conn) do
    router.resolve(affordance, source, conn)
  end

  def resolve_resource(router, module, source, conn) do
    router.resolve_resource(module, source, conn)
  end
end
