defmodule Mazurka.Mediatype.Hyperjson do
  use Mazurka.Mediatype

  def __content_types__ do
    [{"application", "json", %{}},
     {"application", "hyper+json", %{}},
     {"application", "hyper+x-erlang-binary", %{}},
     {"application", "hyper+msgpack", %{}}]
  end

  def __optional_types__ do
    [{"application", "json", %{}},
     {"application", "x-erlang-binary", %{}},
     {"application", "msgpack", %{}}]
  end

  def __format_affordance__(affordance, props = %{"input" => _input}) do
    %{
      "method" => affordance.method,
      "action" => to_string(affordance)
    }
    |> Dict.merge(props)
  end
  def __format_affordance__(%{method: "GET"} = affordance, props) do
    %{
      "href" => to_string(affordance)
    }
    |> Dict.merge(props || %{})
  end
  def __format_affordance__(affordance, props) do
    %{
      "method" => affordance.method,
      "action" => to_string(affordance)
    }
    |> Dict.merge(props || %{})
  end

  defmacro __handle_action__(block) do
    block
    # quote do
    #   response = unquote(block)
    #   if ^:erlang.is_map(response) do
    #     ^Dict.put(response, "href", Rels.self)
    #   else
    #     response
    #   end
    # end
  end

  defmacro __handle_affordance__(affordance, _props) do
    affordance
    # quote do
    #   affordance = unquote(affordance)
    #   if affordance do
    #     ^Mazurka.Mediatype.Hyperjson.format_affordance(affordance, unquote(props))
    #   else
    #     affordance
    #   end
    # end
  end

  defmacro __handle_error__(block) do
    quote do
      response = unquote(block) || %{}

      if ^:erlang.is_map(response) do
        response
        |> ^Dict.put("href", Rels.self)
        |> ^Dict.put_new("error", %{
          "message" => "Internal server error"
        })
      else
        response
      end
    end
  end
end
