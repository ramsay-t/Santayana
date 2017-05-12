defmodule Santayana do
	use Application
	require Logger

  def start(_type, _args) do
    Logger.info "Starting Santayana..."
		{:ok, self()}
  end

end
