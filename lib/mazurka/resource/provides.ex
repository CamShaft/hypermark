defmodule Mazurka.Resource.Provides do
  defmacro __using__(_) do
    quote do
      @doc """
      Override the content types #{inspect(__MODULE__)} provides

          mediatype #{inspect(__MODULE__)} do
            provides "text/plain"
          end
      """
      defmacro provides(type) do
        mediatype = __MODULE__
        quote do
          require Mazurka.Resource.Provides
          Mazurka.Resource.Provides.provides(unquote(mediatype), unquote(type))
        end
      end
    end
  end

  @doc """
  Overrides the content types a mediatype provides

      provides Mazurka.Mediatype.MyCustomMediatype, "text/plain"
  """
  defmacro provides(mediatype, type) do
    quote do
      {:ok, types} = case unquote(type) do
        type when is_binary(type) ->
          :mimetype_parser.parse(type)
        {_, _, _} = type ->
          {:ok, [type]}
      end

      Module.register_attribute(__MODULE__, :mazurka_provides_overrides, accumulate: true)
      for type <- types do
        Module.put_attribute(__MODULE__, :mazurka_provides_overrides, {unquote(mediatype), type})
      end
    end
  end

  @doc false
  defmacro __mediatype_provides__(mediatype, types) do
    quote do
      Module.register_attribute(__MODULE__, :mazurka_provides, accumulate: true)
      Module.put_attribute(__MODULE__, :mazurka_provides, {unquote(mediatype), unquote(types)})
    end
  end

  defmacro __before_compile__(_) do
    quote unquote: false do
      mazurka_provides = Module.get_attribute(__MODULE__, :mazurka_provides)
      mazurka_overrides = Module.get_attribute(__MODULE__, :mazurka_provides_overrides)

      provides = Mazurka.Resource.Provides.__merge_provides__(mazurka_provides, mazurka_overrides)

      list = Enum.map(provides, fn({type, _}) ->
        type
      end)

      defp mazurka__acceptable_content_types() do
        unquote(list |> Macro.escape)
      end

      defp mazurka__select_content_type(types) when types in [nil, []] do
        unquote(list |> hd |> Macro.escape)
      end
      defp mazurka__select_content_type(types) do
        mazurka__select_acceptable_content_type(types)
      end

      defp mazurka__select_acceptable_content_type([]) do
        nil
      end
      for {{type, subtype, params}, _} <- provides do
        defp mazurka__select_acceptable_content_type([{unquote(type), unquote(subtype), unquote(Macro.escape(params))} = ct | _]) do
          ct
        end
      end
      defp mazurka__select_acceptable_content_type([_ | content_types]) do
        mazurka__select_acceptable_content_type(content_types)
      end

      for {content_type, mediatype} <- provides do
        defp mazurka__provide_content_type(unquote(Macro.escape(content_type))) do
          unquote(mediatype)
        end
      end
      defp mazurka__provide_content_type(_) do
        nil
      end
    end
  end

  def __merge_provides__(nil, overrides) do
    __merge_provides__([], overrides)
  end
  def __merge_provides__(default, nil) do
    __merge_provides__(default, [])
  end
  def __merge_provides__([], []) do
    throw :missing_mediatype_block
  end
  def __merge_provides__(default, overrides) do
    default = Enum.reverse(default)
    overrides = overrides_to_map(overrides)
    Keyword.merge(default, overrides)
    |> Enum.flat_map(fn({mediatype, types}) ->
      for type <- types do
        {type, mediatype}
      end
    end)
  end

  def overrides_to_map(overrides) do
    Enum.reduce(overrides, [], fn({mediatype, type}, acc) ->
      Keyword.update(acc, mediatype, [type], fn(list) ->
        [type | list]
      end)
    end)
  end
end
