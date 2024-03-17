defmodule Http.Handler do
  use GenServer

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(@name, %{handling: 0}, name: @name)
  end

  def init(state) do
    do_handle()
    {:ok, state}
  end

  def do_handle() do
    Task.Supervisor.start_child(Http.TaskSupervisor, fn -> Process.send(@name, {:handle}, []) end, [])
  end

  def handle_info({:handle}, state) do
    {status, conn_obj} = GenServer.call(Balancer.Queue, {:pop})
    case status do
      :empty ->
        {:noreply, state}
      :ok ->
        {pid, conn} = conn_obj
        Task.Supervisor.start_child(Http.TaskSupervisor, fn -> handle_conn(pid, conn) end, [])
        do_handle()
        {:noreply, Map.put(state, "handling", 1 + Map.get(state, "handling", 0))}
    end
  end

  def handle_cast({:done}, state) do
    new_state = Map.put(state, "handling", Map.get(state, "handling", 1) - 1)
    {:noreply, new_state}
  end

  defp handle_conn(pid, in_conn) do
    res = Http.Client.handle_downstream(in_conn.method, in_conn)
    send(pid, res)
    GenServer.cast(@name, {:done})
  end
end
