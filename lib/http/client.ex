defmodule Http.Client do
  def handle_downstream("GET", conn) do
    HTTPoison.get("http://127.0.0.1:3000/" <> conn.request_path, conn.req_headers)
  end

  def handle_downstream("OPTIONS", conn) do
    HTTPoison.options("http://127.0.0.1:3000/" <> conn.request_path, conn.req_headers)
  end
  
  def handle_downstream("HEAD", conn) do
    HTTPoison.head("http://127.0.0.1:3000/" <> conn.request_path, conn.req_headers)
  end

  def handle_downstream("POST", conn) do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    HTTPoison.post("http://127.0.0.1:3000/" <> conn.request_path, body, conn.req_headers)
  end

  def handle_downstream("PATCH", conn) do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    HTTPoison.patch("http://127.0.0.1:3000/" <> conn.request_path, body, conn.req_headers)
  end

  def handle_downstream("PUT", conn) do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    HTTPoison.put("http://127.0.0.1:3000/" <> conn.request_path, body, conn.req_headers)
  end
end
