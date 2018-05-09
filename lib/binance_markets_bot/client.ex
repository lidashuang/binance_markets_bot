defmodule BinanceMarketsBot.Client do
  use WebSockex
  require Logger

  def start_link(state) do
    options = if Mix.env() == :dev, do: [debug: [:trace]], else: [socket_connect_timeout: 10000]
    options = Keyword.merge(options, name: :binance)
    ws_endpoint = "wss://stream.binance.com:9443/ws/!ticker@arr"
    WebSockex.start_link(ws_endpoint, __MODULE__, state, options)
  end

  def handle_frame({:text, msg}, state) do
    state = %{state | data: msg}
    {:ok, state}
  end

  def handle_frame({type, msg}, state) do
    Logger.info("Received Message - Type: #{inspect(type)} -- Message: #{msg}")
    {:ok, state}
  end

  def handle_disconnect(%{reason: reason}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:ok, state}
  end

  def handle_info(:telegram, state) do
    pid = Process.whereis(:telegram)
    GenServer.cast(pid, {:send, state[:data]})
  end

  def terminate(reason, _state) do
    Logger.info("Local terminate with reason: #{inspect(reason)}")
    exit(:normal)
  end
end
