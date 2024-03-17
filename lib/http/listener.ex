defmodule Httpqueue.Http.Listener do
  use Plug.Router
  plug(:match)
  plug(:dispatch)

  match _ do
    node = Balancer.Node.get_random_node()
    IO.inspect(node)

    GenServer.call({Balancer.Queue, node}, {:push, {self(), conn}})
    receive do
      {status, res} ->
        case status do
          :ok -> send_resp(conn, res.status_code, res.body)
          _ -> send_resp(conn, 503, "")
        end
    end
  end
end
