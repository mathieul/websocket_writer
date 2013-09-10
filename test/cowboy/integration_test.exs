defmodule Cowboy.IntegrationTest do
  use ExUnit.Case, async: true

  defmodule HttpHandler do
    @behaviour :cowboy_http_handler
    def init({ :tcp, :http }, req, _opts), do: { :ok, req, :undefined_state }
    def handle(req, state) do
      { :ok, req } = :cowboy_req.reply(200, [], "HttpHandler says hi /http", req)
      { :ok, req, state }
    end
    def terminate(_reason, _req, _state), do: :ok
  end

  defmodule LoopHandler do
    @behaviour :cowboy_loop_handler
    def init({ :tcp, :http }, req, _opts) do
      :timer.send_interval(150, { :return, "150ms have passed" })
      { :loop, req, :undefined_state, 1000, :hibernate }
    end
    def info({ :return, message }, req, state) do
      { :ok, req } = :cowboy_req.reply(200, [], message, req)
      { :ok, req, state }
    end
    def terminate(_reason, _req, _state), do: :ok
  end

  defmodule InfoHandler do
    @behaviour :cowboy_http_handler
    def init({ :tcp, :http }, req, _opts), do: { :ok, req, :undefined_state }
    def handle(req, state) do
      { bindings, req } = :cowboy_req.bindings(req)
      { path_info, req } = :cowboy_req.path_info(req)
      body = "bindings=#{inspect bindings} path_info=#{inspect path_info}"
      { :ok, req } = :cowboy_req.reply(200, [], body, req)
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
    match "/loop", to: LoopHandler
    match "/info/:first/[...]", to: InfoHandler
    default with: RouterApp
  end

  setup_all do
    Dynamo.Cowboy.run RouterApp, port: 8011, verbose: false, dispatch: CowboyRoutes.dispatch
    :ok
  end

  teardown_all do
    Dynamo.Cowboy.shutdown RouterApp
    :ok
  end

  test "request routed to dynamo" do
    assert { 200, _, "RouterApp says wassup /" } = request :get, "/"
  end

  test "request routed to a HTTP handler" do
    assert { 200, _, "HttpHandler says hi /http" } = request :get, "/http"
  end

  test "request routed to a Loop handler" do
    assert { 200, _, "150ms have passed" } = request :get, "/loop"
  end

  test "request returning its bindings and path info" do
    { 200, _, body } = request :get, "/info/allo/la/terre"
    assert body == %s(bindings=[first: "allo"] path_info=["la", "terre"])
  end

  defp request(verb, path) do
    { :ok, status, headers, client } =
      :hackney.request(verb, "http://127.0.0.1:8011" <> path, [], "", [])
    { :ok, body, _ } = :hackney.body(client)
    { status, headers, body }
  end
end
