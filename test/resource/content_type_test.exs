defmodule Test.Mazurka.Resource.ContentType do
  use Test.Mazurka.Case

  context Multiple do
    resource Foo do
      mediatype Hyper do
        action do
          %{"hello" => "World"}
        end
      end

      mediatype HTML do
        action do
          {"html", nil, []}
        end
      end
    end
  after
    "Foo.action [application/json]" ->
      {_, content_type, _} = Foo.action([{"application", "hyper+json", %{}}], %{}, %{}, %{})
      assert {"application", "hyper+json", %{}} = content_type

    "Foo.action [text/html]" ->
      {_, content_type, _} = Foo.action([{"text", "html", %{}}], %{}, %{}, %{})
      assert {"text", "html", %{}} = content_type

    "Foo.action [application/*]" ->
      {_, content_type, _} = Foo.action([{"application", "*", %{}}], %{}, %{}, %{})
      assert {"application", "json", %{}} = content_type

    "Foo.action [*/html]" ->
      {_, content_type, _} = Foo.action([{"*", "html", %{}}], %{}, %{}, %{})
      assert {"text", "html", %{}} = content_type

    "Foo.action [*/*]" ->
      {_, content_type, _} = Foo.action([{"*", "*", %{}}], %{}, %{}, %{})
      assert {"application", "json", %{}} = content_type

    "Foo.action [foo/bar, application/json]" ->
      {_, content_type, _} = Foo.action([{"foo", "bar", %{}}, {"application", "json", %{}}], %{}, %{}, %{})
      assert {"application", "json", %{}} = content_type

    "Foo.action [text/plain]" ->
      assert_raise Mazurka.UnacceptableContentTypeException, fn ->
        Foo.action([{"text", "plain", %{}}], %{}, %{}, %{})
      end
  end

  #context Params do
  #  resource Foo do
  #    mediatype Hyper do
  #      provides "application/hyper+json; foo=bar"
  #
  #      action do
  #        %{"foo" => "bar"}
  #      end
  #    end
  #
  #    mediatype Hyper do
  #      action do
  #        %{"foo" => "baz"}
  #      end
  #    end
  # end
  #after
  #  "Foo.action (foo=bar)" ->
  #    {_, content_type, _} = Foo.action([{"application", "hyper+json", %{"foo" => "bar"}}], %{}, %{}, %{})
  #    assert {"application", "hyper+json", %{"foo" => "bar"}} = content_type
  #
  #  "Foo.action (foo=baz)" ->
  #    {_, content_type, _} = Foo.action([{"application", "hyper+json", %{"foo" => "baz"}}], %{}, %{}, %{})
  #    assert {"application", "hyper+json", %{"foo" => "baz"}} = content_type
  #end
end
