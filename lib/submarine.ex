defmodule Subscriber do
  defstruct id: "none"
end

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
      {:publish, pid, msg} ->
        pub = List.keyfind(subs, pid, 0) |> elem(1)
        Enum.each(subs, &(send(elem(&1, 0), {pub.id, msg})))
        run(subs)

      {:subscribe, pid, id} ->
        run([{pid, %Subscriber{id: id}} | subs])
      {:subscribe, pid} ->
        run([{pid, %Subscriber{}} | subs])

      {:unsubscribe, pid} ->
        List.keydelete(subs, pid, 0) |> run

      {:identify, pid, id} ->
        sub = List.keyfind(subs, pid, 0) |> elem(1)
        List.keyreplace(subs, pid, 0, {pid, %{sub | id: id}}) |> run
    end
  end

  @doc """
  publish to server
  """
  def publish(pid, msg) do
    send(get_server(), {:publish, pid, msg})
  end

  @doc """
  subscribe to server with identifier
  """
  def subscribe(pid, id, handler) do
    send(get_server(), {:subscribe, pid, id})
    listen(handler)
  end

  @doc """
  subscribe to server without identifier
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

  def identify(pid, id) do
    send(get_server(), {:identify, pid, id})
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
