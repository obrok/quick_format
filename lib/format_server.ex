defmodule QuickFormat.FormatServer do
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    serve(client)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    {formatter_exs, _} = socket |> read_to_null() |> Code.eval_string()

    read_to_null(socket)
    |> Code.format_string!(formatter_exs)
    |> write_line(socket)

    :gen_tcp.shutdown(socket, :write)
  end

  defp read_to_null(socket) do
    Stream.repeatedly(fn -> read_line(socket) end)
    |> Stream.take_while(&(&1 != "\0\n"))
    |> Enum.join("")
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
    socket
  end
end
