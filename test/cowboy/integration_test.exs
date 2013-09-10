defmodule Cowboy.IntegrationTest do
  use ExUnit.Case, async: true

  defmodule HttpHandler do
    @behaviour :cowboy_http_handler
    def init({:tcp, :http}, req, _opts), do: {:ok, req, :undefined_state}
    def handle(req, state) do
      { :ok, req } = :cowboy_req.reply(200, [], "HttpHandler says hi /http", req)
      { :ok, req, state }
    end
    def terminate(_reason, _req, _state), do: :ok
  end

  defmodule RouterApp do
    use Dynamo
    use Dynamo.Router
    get "/", do: conn.send(200, "RouterApp says wassup /")
  end

  defmodule CowboyRoutes do
    use WebsocketWriter.Cowboy.Dispatch
    match "/http", to: HttpHandler
    default with: RouterApp
  end

  test "basic request on a router app" do
    start_server RouterApp, 8011, CowboyRoutes
    assert { 200, _, "RouterApp says wassup /" } = request :get, "/"
    assert { 200, _, "HttpHandler says hi /http" } = request :get, "/http"
    stop_server RouterApp
  end

  defp start_server(app, port, routes) do
    Dynamo.Cowboy.run(app, port: port, verbose: false, dispatch: routes.dispatch)
  end

  defp stop_server(app), do: Dynamo.Cowboy.shutdown(app)

  defp request(verb, path) do
    { :ok, status, headers, client } =
      :hackney.request(verb, "http://127.0.0.1:8011" <> path, [], "", [])
    { :ok, body, _ } = :hackney.body(client)
    { status, headers, body }
  end
end
