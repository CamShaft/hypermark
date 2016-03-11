defmodule Mazurka.Mediatype.XML do
  use Mazurka.Mediatype

  def __content_types__ do
    [{"application", "xml", %{}}]
  end

  def format_affordance(affordance, _props) do
    to_string(affordance)
  end

  defmacro __handle_action__(block) do
    block
  end

  defmacro __handle_affordance__(affordance, props) do
    quote do
      affordance = unquote(affordance)
      if affordance do
        ^Mazurka.Mediatype.XML.format_affordance(affordance, unquote(props))
      else
        affordance
      end
    end
  end

  defmacro __handle_error__(block) do
    block
  end
end
