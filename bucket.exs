defmodule Bucket do

    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__, Map.new, name: __MODULE__)
    end

    def init(default) do
        {:ok, default}
    end


    def set({key, value}) do
        GenServer.call(__MODULE__, {:set, {key, value}})
    end

    def get(key) do
        GenServer.call(__MODULE__, {:get, key})
    end

    def get_all do
        GenServer.call(__MODULE__, :get_all)
    end

    def delete(key) do
        GenServer.call(__MODULE__, {:delete, key})
    end


    def handle_call({:set, {key, value}}, _from, state) do
        {:reply, :ok, Map.put(state, key, value)}
    end

    def handle_call({:get, key}, _from, state) do
        {:reply, Map.fetch(state, key), state}
    end

    def handle_call(:get_all, _from, state) do
        {:reply, state, state}
    end

    def handle_call({:delete, key}, _from, state) do
        {:reply, :ok, Map.delete(state, key)}
    end

end
