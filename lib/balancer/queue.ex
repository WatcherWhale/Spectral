defmodule Balancer.Queue do
  use GenServer
  require Logger

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(@name, nil, name: @name)
  end

  def init(_) do
    {:ok, []}
  end

  def handle_call({:push, conn}, _from, state) do
    new_state = state ++ [conn]

    if length(state) == 0 do
      Http.Handler.do_handle()
    end

    {:reply, :ok, new_state}
  end

  def handle_call({:length}, _from, state) do
    {:reply, length(state), state}
  end

  def handle_call({:pop}, _from, state) do
    {conn, new_state} = List.pop_at(state, 0)

    case conn do
      nil ->
        {:reply, {:empty, nil}, state}

      _ ->
        {:reply, {:ok, conn}, new_state}
    end
  end
end
