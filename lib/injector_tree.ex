defmodule InjectorTree do
  @doc """
  Injects the specified stub such that it gets registered as an override in the
  process hierarchy.
  """
  def inject(module, stub) do
    injector_map = Process.get(:injector_tree, %{})
    Process.put(:injector_tree, Map.put(injector_map, module, stub))
    :ok
  end

  @doc """
  Provides (aka returns) the specified module such that if that module has been
  injected then that override is what gets returned.

  If the module has not been injected the specified module is returned.
  """
  def provide(module) do
    ProcessTree.get(:injector_tree, default: %{})
    |> Map.get(module, module)
  end
end
