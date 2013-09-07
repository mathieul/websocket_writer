Dynamo.under_test(WebsocketWriter.Dynamo)
Dynamo.Loader.enable
ExUnit.start

defmodule WebsocketWriter.TestCase do
  use ExUnit.CaseTemplate

  # Enable code reloading on test cases
  setup do
    Dynamo.Loader.enable
    :ok
  end
end
