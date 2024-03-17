defmodule Balancer.Node do
  use GenServer

  @name __MODULE__
  @queue Balancer.Queue

  def start_link(_) do
    GenServer.start_link(@name, %{max: 1, sum: 1, nodes: %{}}, name: @name)
  end

  def init(_) do
    :net_kernel.monitor_nodes(true)
    state = recalculate()
    {:ok, state}
  end

  def handle_call({:random}, _from, state) do
    case length(Node.list()) do
      0 -> {:reply, Node.self(), state}
      _ -> {:reply, select_node(get_nodes(), :rand.uniform(state.sum) , state), state}
    end
  end

  def handle_info({:recalculate}, _state) do
    schedule_recalculate()
    {:noreply, recalculate()}
  end

  def handle_info({:nodeup, _}, state) do
    schedule_recalculate()
    {:noreply, state}
  end

  def handle_info({:nodedown, _}, state) do
    schedule_recalculate()
    {:noreply, state}
  end

  def get_random_node() do
    GenServer.call(@name, {:random})
  end

  defp select_node([head | tail], index, state) do
    weigth = Map.get(state.nodes, Atom.to_string(head), state.max)

    cond do
       index <= 0 -> head
       index < weigth -> head
       true -> select_node(tail, index - weigth, state)
    end
  end

  defp select_node([], _, _) do
    Node.self()
  end

  defp schedule_recalculate() do
    nodes = get_nodes()
    # Only do recalculations with other nodes present
    if length(nodes) > 1 do
      Process.send_after(@name, {:recalculate}, 100)
    end
  end

  defp recalculate() do
    nodes = get_nodes()

    weights = Enum.map(nodes, fn node ->
      cond do
        node == Node.self() ->
          {node, GenServer.call(@queue, {:length}) + 1}
        true ->
          {node, GenServer.call({@queue, node}, {:length}) + 1}
      end
    end)

    {_, max} = Enum.max_by(weights, fn {_, w} -> w end)
    sum = Enum.reduce(weights, 0, fn {_, w}, acc -> acc + w end)
    weights = Enum.map(weights, fn {node, w} -> {node, max - w} end)

    node_map = weights |> Enum.into(%{})

    %{max: max + 1, sum: sum + 1, nodes: node_map}
  end

  defp get_nodes do
    Node.list() ++ [Node.self()]
  end
end
