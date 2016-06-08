defmodule MazurkaTest.Resources.Sitemap.Nested do
  use Mazurka.Resource

  let sites = [
    {"Mazurka Homepage", "http://www.mazurka.io", "_blank"}
  ]

  mediatype Mazurka.Mediatype.Sitemap do
    action do
      for info <- sites do
        elem(info, 1)
      end
    end
  end

  mediatype Mazurka.Mediatype.HTML do
    action do
      {"html", [
        {"head", nil, [
          {"title", nil, "Sitemap - Nested"}
        ]},
        {"body", nil, [
          {"ul", nil, [
            {"li", nil, for info <- sites do
              {"a", [href: elem(info, 1), target: elem(info, 2)], elem(info, 0)}
            end}
          ]}
        ]}
      ]}
    end

    affordance do
      %{
        "name" => "Nested Sitemap"
      }
    end
  end

  test "should respond with a 200" do
    request()
  after conn ->
    conn
    |> assert_status(200)
  end

  test "should generate a sitemap" do
    request()
  after conn ->
    conn
    |> assert_status(200)
    |> assert_body("""
      <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
      <urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">
      \t<url>
      \t\t<loc>http://www.mazurka.io</loc>
      \t</url>
      </urlset>
      """ |> String.rstrip())
  end

  test "should respond with html" do
    request do
      accept "html"
    end
  after conn ->
    conn
    |> assert_status(200)
  end
end