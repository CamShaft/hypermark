defmodule Test.Mazurka.Resource.Params do
  use Test.Mazurka.Case

  context Single do
    resource Foo do
      param foo

      mediatype Hyper do
        action do
          %{"foo" => foo}
        end
      end
    end
  after
    "action" ->
      {body, content_type, _} = Foo.action([], %{"foo" => "123"}, %{}, %{})
      assert %{"foo" => "123"} == body
      assert {"application", "json", %{}} = content_type

    "action missing param" ->
      assert_raise Mazurka.MissingParametersException, fn ->
        Foo.action([], %{}, %{}, %{})
      end

    "action nil param" ->
      assert_raise Mazurka.MissingParametersException, fn ->
        Foo.action([], %{"foo" => nil}, %{}, %{})
      end

    "affordance" ->
      assert_raise Mazurka.MissingRouterException, fn ->
        Foo.affordance([], %{"foo" => "123"}, %{}, %{})
      end

    "affordance missing param" ->
      assert_raise Mazurka.MissingParametersException, fn ->
        Foo.affordance([], %{}, %{}, %{})
      end

    "affordance nil param" ->
      {body, _} = Foo.affordance([], %{"foo" => nil}, %{}, %{})
      assert %Mazurka.Affordance.Undefined{} = body
  end
end
