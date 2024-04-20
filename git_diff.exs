defmodule GitDiffFormatter do
  @moduledoc """
  Like `git diff`, but with output that's easier on the eye.

  I use it by hooking it into an alias:
  ```sh
    $ alias git-nice-diff="elixir <absolute path to git_diff.exs>"
    $ git-nice-diff .
  ```
  """

  # e.g.: `index 0000000..cbecb02`
  @diff_or_index ~r/^(index|diff --git)/
  # e.g.: `@@ -0,0 +1,25 @@`
  @hunk_header ~r/^@@\ -\d+,\d+\ \+(\d+),\d+ @@/
  # e.g.: `new file mode 100644`
  @new_file_mode ~r/^new file mode \d*/
  # e.g.: `+++ b/path/to/file.ex`
  @new_path ~r/^\+\+\+\s\w?/
  # e.g.: `--- /dev/null`
  @old_path ~r/^---\s\w?/
  # e.g.: `- foo`
  @minus_line ~r/^-/
  # e.g.: `+ foo`
  @plus_line ~r/^\+/

  def run do
    {output, _} = System.cmd("git", ["diff"] ++ System.argv())

    output
    |> String.split("\n")
    |> Enum.map(&process_line/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.each(&IO.puts/1)
  end

  defp process_line(line) do
    cond do
      Regex.match?(@new_file_mode, line) -> nil
      Regex.match?(@diff_or_index, line) -> nil
      Regex.match?(@old_path, line) -> nil
      Regex.match?(@new_path, line) -> line |> format_new_file_path |> bold |> underline
      Regex.match?(@hunk_header, line) -> line |> format_hunk_header |> bold
      Regex.match?(@plus_line, line) -> line |> green
      Regex.match?(@minus_line, line) -> line |> red
      true -> line
    end
  end

  defp bold(str), do: "\e[1m#{str}\e[0m"

  defp format_hunk_header(line),
    do: with([_, number] <- Regex.run(@hunk_header, line), do: "L##{number}:")

  defp format_new_file_path(line), do: line |> String.replace(@new_path, "")
  defp green(str), do: "\e[32m#{str}\e[0m"
  defp red(str), do: "\e[31m#{str}\e[0m"
  defp underline(str), do: "\e[4m#{str}\e[0m"
end

GitDiffFormatter.run()
