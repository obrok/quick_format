defmodule QuickFormat do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        QuickFormat.FormatServer
      ],
      strategy: :one_for_one
    )
  end
end
