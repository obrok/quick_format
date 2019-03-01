defmodule QuickFormat.FormatServer do
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Task.Supervisor.start_child(__MODULE__.TaskSupervisor, fn -> serve(client) end)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    try do
      {formatter_exs, _} = socket |> read_to_null() |> Code.eval_string()

      formatted = read_to_null(socket) |> Code.format_string!(formatter_exs)

      write_line("0\n", socket)
      write_line(formatted, socket)
    rescue
      _ -> write_line("1\n", socket)
    end

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

  def child_spec(_) do
    children = [
      {Task.Supervisor, name: __MODULE__.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> __MODULE__.accept(8090) end}, restart: :permanent)
    ]

    %{
      id: __MODULE__.Supervisor,
      restart: :permanent,
      shutdown: :infinity,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one, name: __MODULE__.Supervisor]]}
    }
  end
end
