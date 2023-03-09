defmodule FileSearch do
  @moduledoc """
  Documentation for FileSearch
  """

  @doc """
  Find all nested files.

  For example, given the following folder structure
  /main
    /sub1
      file1.txt
    /sub2
      file2.txt
    /sub3
      file3.txt
    file4.txt

  It would return:

  ["file1.txt", "file2.txt", "file3.txt", "file4.txt"]
  """
  def all(folder, opts \\ []) do
    output = Path.wildcard("#{folder}/**")
    |> Stream.reject(&File.dir?/1)
    |> Stream.map(&Path.basename/1)
    |> Enum.to_list()
    IO.puts "#{inspect(output)}"
  end

  @doc """
  Find all nested files and categorize them by their extension.

  For example, given the following folder structure
  /main
    /sub1
      file1.txt
      file1.png
    /sub2
      file2.txt
      file2.png
    /sub3
      file3.txt
      file3.jpg
    file4.txt

  It would return:

  %{
    "txt" => ["file1.txt", "file2.txt", "file3.txt", "file4.txt"],
    "png" => ["file1.png", "file2.png"],
    "jpg" => ["file3.jpg"]
  }
  """
  def by_extension(folder, opts \\ []) do
    output = all(folder)
    |> Enum.reduce(%{}, fn file, acc ->
      [_ , file_extension] = String.split(file, ".")
      Map.update(acc, file_extension, [file], fn list -> [file | list] end)
    end)
    IO.puts "#{inspect(output)}"
  end
end

defmodule FileSearch.Menu do
  @moduledoc """
  Enables the user to call the FileSearch module from their command line via escript.
  """
  @doc """
  Show which functions are available, and let the user choose one.
  """
  def display(opts) do
    IO.puts("""
    Select a function:
    1. FileSearch.all(folder) -> Outputs all the files from the specified directory and nested sub-directories.
    2. FileSearch.by_extension(folder) -> Outputs a map with the different file extensions as the key, and a list of the files with that extension as the value.
    """)
    {func, _} = IO.gets("Select (1 or 2): ") |> Integer.parse()
    folder = IO.gets("Select the folder: ") |> String.trim()
    case func do
      1 -> FileSearch.all(folder, opts)
      2 -> FileSearch.by_extension(folder, opts)
      _ -> "Invalid choice. Please input either 1 or 2."
    end
  end
end

defmodule FileSearch.CLI do
  def main(_args) do
    {opts, _word, _errors} = OptionParser.parse(args, switches: [by_type: :string])
    FileSearch.Menu.display(opts)
  end
end
