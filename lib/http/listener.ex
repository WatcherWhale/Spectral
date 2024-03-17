defmodule Httpqueue.Http.Listener do
  alias Plug.Logger
  use Plug.Router

  plug(:match)
  plug(Logger)
  plug(:dispatch)

  match _ do
    node = Balancer.Node.get_random_node()

    GenServer.call({Balancer.Queue, node}, {:push, {self(), conn}})

    receive do
      {:ok, res} ->
        conn = merge_resp_headers(conn, res.headers)
        send_resp(conn, res.status_code, res.body)

      {:error, _} ->
        send_resp(conn, 503, "")

      _ ->
        send_resp(conn, 500, "")
    end
  end
end
