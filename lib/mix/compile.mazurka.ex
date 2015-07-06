defmodule Mix.Tasks.Compile.Mazurka do
  use Mix.Task

  @recursive true

  def run(args) do
    {opts, _, _} = OptionParser.parse(args, switches: [force: :boolean])

    project      = Mix.Project.config
    options      = project[:mazurka_options] || []
    source_paths = options[:paths] || ["res"]
    erlc_options = project[:erlc_options] || []
    compile_path = Mix.Project.compile_path(project)

    compile_opts = [native: Keyword.get(options, :native, Mix.env == :prod),
                    timeout: Keyword.get(options, :timeout, 10_000),
                    debug: Keyword.get(options, :debug, false),
                    erlc_options: erlc_options]

    if opts[:file] do
      prepare_file(opts[:file], compile_path, compile_opts)
    else
      extract_targets(source_paths, compile_path, compile_opts)
    end
  end

  def manifests, do: []

  defp extract_targets(source_paths, compile_path, opts) do
    Mix.Utils.extract_files(source_paths, ["md"])
    |> Enum.flat_map(&(prepare_file(&1, compile_path, opts)))
  end

  defp prepare_file(file, compile_path, opts) do
    file(file)
    |> Enum.map(&(prepare_module(&1, file, compile_path, opts)))
  end

  defp file(src, opts \\ []) do
    {:ok, resources} = :mazurka_dsl.parse_file(src, opts)
    resources
    |> Enum.flat_map(&(Mazurka.Compiler.Markdown.compile(&1, src, opts)))
  end

  defp prepare_module({module, generate, type}, file, compile_path, opts) do
    source = "#{file} (#{type})"
    target = Path.join(compile_path, "#{module}.beam")
    {vsn, compile} = generate.(opts)
    if is_stale?(target, vsn) do
      {:ok, _name, _main, beam} = compile.()
      File.write!(target, beam)
      Mix.shell.info "Compiled #{source}"
      :ok
    else
      :noop
    end
  end

  defp is_stale?(path, version) do
    case :beam_lib.version(to_char_list(path)) do
      {:ok, {_, [prev | _]}} ->
        prev != version
      _error ->
        true
    end
  end
end