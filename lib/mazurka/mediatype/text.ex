defmodule Mazurka.Mediatype.Text do
  use Mazurka.Mediatype

  def __content_types__ do
    [{"text", "plain", %{}}]
  end

  def format_affordance(%{method: method} = affordance, _props) do
    "#{method} #{affordance}"
  end

  defmacro __handle_action__(block) do
    block
  end

  defmacro __handle_affordance__(affordance, props) do
    quote do
      affordance = unquote(affordance)
      if affordance do
        ^Mazurka.Mediatype.Text.format_affordance(affordance, unquote(props))
      else
        affordance
      end
    end
  end

  defmacro __handle_error__(block) do
    block
  end
end
