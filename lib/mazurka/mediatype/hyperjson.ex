defmodule Mazurka.Mediatype.Hyper do
  use Mazurka.Mediatype

  def __content_types__ do
    [{"application", "json", %{}},
     {"application", "hyper+json", %{}},
     {"application", "hyper+x-erlang-binary", %{}},
     {"application", "hyper+msgpack", %{}}]
  end

  defmacro __handle_action__(block) do
    quote do
      case unquote(block) do
        %{__struct__: _} = response ->
          response
        response when is_map(response) ->
          # TODO
          #Map.put(response, "href", Link.from_conn(conn))
          response
        response ->
          response
      end
    end
  end

  defmacro __handle_affordance__(affordance, props) do
    quote do
      case {unquote(affordance), unquote(props)} do
        {nil, _} ->
          nil
        # check if props is defined to supress the compiler warning
        unquote(if props do
          quote do
            {affordance, %{"input" => _} = props} ->
              %{
                "method" => affordance[:method],
                "action" => to_string(affordance)
              } |> Map.merge(props)
          end
        end)
        {%{method: "GET"} = affordance, props} ->
          %{
            "href" => to_string(affordance)
          } |> Map.merge(props || %{})
        {affordance, props} ->
          %{
            "method" => affordance[:method],
            "action" => to_string(affordance),
          } |> Map.merge(props || %{})
      end
    end
  end
end
