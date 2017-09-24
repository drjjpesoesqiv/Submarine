defmodule Submarine do
  use Agent

  @moduledoc """
  Documentation for Submarine.
  """

  @doc """
  starts the pub/sub server
  """
  def start_link(_opts) do
    server = spawn(__MODULE__, :run, [[]])
    Agent.start_link(fn -> %{server: server} end, name: :submarine)
  end

  @doc """
  gets the server from the agent
  """
  def get_server do
    Agent.get(:submarine, &Map.get(&1, :server))
  end

  @doc """
  loop for subscribing and publishing messages
  """
  def run(subs) do
    receive do
      {:publish, msg} ->
        Enum.each(subs, &(send(&1, msg)))
        run(subs)

      {:subscribe, pid} ->
        run([pid | subs])

      {:unsubscribe, pid} ->
        List.delete(subs, pid) |> run
    end
  end

  @doc """
  publish to server
  """
  def publish(msg) do
    send(get_server(), {:publish, msg})
  end

  @doc """
  subscribe to server
  """
  def subscribe(pid, handler) do
    send(get_server(), {:subscribe, pid})
    listen(handler)
  end

  @doc """
  unsubscribe from server
  """
  def unsubscribe(pid) do
    send(get_server(), {:unsubscribe, pid})
  end

  @doc """
  reacts with callback after receiving message
  """
  def listen(callback) do
    receive do
      msg ->
        callback.(msg)
        listen(callback)
    end
  end
end
