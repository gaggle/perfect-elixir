defmodule CowboyExample do
  def start_server do
    # Set up the routing table for the Cowboy server, so root req
    #uests ("/") direct to our handler.
    dispatch = :cowboy_router.compile([{:_, [
      {"/", CowboyExample.HelloWorldHandler, []}
    ]}])

    # Start the Cowboy server in "clear mode" aka plain HTTP
    #   options - Configuration options for the server itself
    #             (this also supports which IP to bind to,
    #             SSL details, etc.)
    #   `env`   - Configuration map for how the server
    #             handles HTTP requests
    #             (this also allows configuring timeouts,
    #             compression settings, etc.)
    {:ok, _} =
      :cowboy.start_clear(
        :my_name,
        [{:port, 8080}],
        %{env: %{dispatch: dispatch}}
      )

    IO.puts("Cowboy server started on port 8080")
  end
end

defmodule CowboyExample.HelloWorldHandler do
  # `init/2` is the entry point for handling a new HTTP request
  # in Cowboy
  def init(req, _opts) do
    req = :cowboy_req.reply(200, %{
      "content-type" => "text/html"
    }, "<h1>Hello World!</h1>", req)

    # Return `{:ok, req, state}` where `state` is
    # handler-specific state data; here, it's `:nostate`
    # as we do not maintain any state between requests.
    {:ok, req, :nostate}
  end
end
