defmodule Test.Mazurka.Resource.Link do
  use Test.Mazurka.Case

  context Dual do
    resource Foo do
      param foo

      mediatype Hyper do
        action do
          %{"foo" => foo}
        end
      end
    end

    resource Bar do
      param bar

      mediatype Hyper do
        action do
          %{
            "bar" => bar,
            "foo" => link_to(Foo, %{"foo" => bar <> bar})
          }
        end
      end
    end

    router Router do
      route "GET", ["foo", :foo], Foo
      route "POST", ["bar", :bar], Bar
    end
  after
    "Foo.action" ->
      {body, content_type, _} = Foo.action([], %{"foo" => "123"}, %{}, %{}, Router)
      assert %{"foo" => "123", "href" => "/foo/123"} == body
      assert {"application", "json", %{}} = content_type

    "Foo.affordance" ->
      {body, content_type} = Foo.affordance([], %{"foo" => "123"}, %{}, %{}, Router)
      assert %{"href" => "/foo/123"} == body
      assert {"application", "json", %{}} == content_type

    "Bar.action" ->
      {body, content_type, _} = Bar.action([], %{"bar" => "123"}, %{}, %{}, Router)
      assert %{"bar" => "123", "foo" => %{"href" => "/foo/123123"}, "href" => "/bar/123"} == body
      assert {"application", "json", %{}} == content_type

    "Bar.affordance" ->
      {body, content_type} = Bar.affordance([], %{"bar" => "123"}, %{}, %{}, Router)
      assert %{"action" => "/bar/123", "method" => "POST", "input" => %{}} = body
      assert {"application", "json", %{}} == content_type

    "Bar.action missing router" ->
      assert_raise Mazurka.MissingRouterException, fn ->
        Bar.action([], %{"bar" => "123"}, %{}, %{})
      end

    "Bar.affordance missing router" ->
      assert_raise Mazurka.MissingRouterException, fn ->
        Bar.affordance([], %{"bar" => "123"}, %{}, %{})
      end
  end
end
