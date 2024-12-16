defmodule InjectorTree do
  def provide(module) do
    ProcessTree.get(:injector_tree, default: %{})
    |> Map.get(module, module)
  end

  def inject(module, stub) do
    injector_map = Process.get(:injector_tree, %{})
    Process.put(:injector_tree, Map.put(injector_map, module, stub))
    :ok
  end
end
