defmodule WebsocketWriter.Dynamo do
  use Dynamo

  config :dynamo,
    # The environment this Dynamo runs on
    env: Mix.env,

    # The OTP application associated with this Dynamo
    otp_app: :websocket_writer,

    # The endpoint to dispatch requests to
    endpoint: ApplicationRouter,

    # The route from which static assets are served
    # You can turn off static assets by setting it to false
    static_route: "/static"

  # Uncomment the lines below to enable the cookie session store
  # config :dynamo,
  #   session_store: Session.CookieStore,
  #   session_options:
  #     [ key: "_websocket_writer_session",
  #       secret: "2uGc//tkP1DELc+LQxzh1hh0ZCMW5/3RzJkQvnmAtmroWVKWH2kUZWatFO7R1jLR"]

  # Default functionality available in templates
  templates do
    use Dynamo.Helpers
  end
end
