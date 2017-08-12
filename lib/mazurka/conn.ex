defprotocol Mazurka.Conn do
  @fallback_to_any true
  def transition(conn, affordance)
  def invalidate(conn, affordance)
end

defimpl Mazurka.Conn, for: Any do
  def transition(conn, affordance) do
    private = Map.put(conn.private, :mazurka_transition, affordance)
    %{conn | private: private}
  end

  def invalidate(conn, affordance) do
    private = Map.update(conn.private, :mazurka_invalidations, [affordance], &[affordance | &1])
    %{conn | private: private}
  end
end
