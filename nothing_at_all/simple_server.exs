defmodule SimpleServer do
  def start(port) do
    # Listen on a TCP socket on the specified port
    #   :binary       - Treat data as raw binary, instead of
    #                   being automatically converted into
    #                   Elixir strings (which are UTF-8 encoded).
    #                   It'd be unnecessary to convert, as the
    #                   HTTP protocol uses raw bytes.
    #   packet: :line - Frame messages using newline delimiters,
    #                   which is the expected shape of HTTP-data
    #   active: false - Require manual fetching of messages. In
    #                   Erlang, active mode controls the
    #                   automatic sending of messages to the
    #                   socket's controlling process. We disable
    #                   this behavior, so our server can control
    #                   when and how it reads data
    {:ok, socket} = :gen_tcp.listen(port, [
      :binary, packet: :line, active: false
    ])
    IO.puts("Listening on port #{port}")
    loop_handle_client_connection(socket)
  end

  defp loop_handle_client_connection(socket) do
    # Wait for a new client connection. This is a blocking call
    # that waits until a new connection arrives.
    # A connection returns a `client_socket` which is connected
    # to the client, so we can send a reply back.
    {:ok, client_socket} = :gen_tcp.accept(socket)

    send_hello_world_response(client_socket)
    :gen_tcp.close(client_socket)

    # Recursively wait for the next client connection
    loop_handle_client_connection(socket)
  end

  defp send_hello_world_response(client_socket) do
    # Simple HTML content for the response.
    content = "<h1>Hello, World!</h1>"

    # Generate the entire raw HTTP response, which includes
    # calculating content-length header.
    response = """
    HTTP/1.1 200 OK
    content-length: #{byte_size(content)}
    content-type: text/html

    #{content}
    """

    :gen_tcp.send(client_socket, response)
  end
end

SimpleServer.start(8080)
