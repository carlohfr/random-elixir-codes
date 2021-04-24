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


defmodule A do
    def write do
        IO.puts("test")
        :ok
    end
end



defmodule KeyValueStorage do

    use GenServer


    def start_link do
        GenServer.start_link(__MODULE__, Map.new, name: __MODULE__)
    end

    def init(default) do
        {:ok, default}
    end

    def set(bucket, key, value) do
        GenServer.call(__MODULE__, {:set, {bucket, key, value}})
    end

    def get(bucket, key) do
        GenServer.call(__MODULE__, {:get, {bucket, key}})
    end

    def get_all do
        GenServer.call(__MODULE__, {:get_all})
    end


    def handle_call({:create_bucket, bucket}, _from, state) do

        IO.inspect(Map.fetch(state, bucket))

        #case Map.has_key?(state, bucket) do
        #    :true ->
        #        {:reply, {:error, :already_exists}, state}
        #    _ ->

                #Bucket.start_link(bucket)  #problema aqui o processo ta morrendo
                #IO.inspect(new_bucket_pid)
                #IO.inspect(Process.alive?(new_bucket_pid))
                #{:reply, :ok, Map.put(state, bucket, new_bucket_pid)}
        #end
        {:reply, :ok, state}
    end


    def handle_call({:set, {bucket, key, value}}, _from, state) do #reavaliar, não salva mais que um bucket
        case Map.fetch(state, bucket) do
            {:ok, pid} ->
                GenServer.call(pid, {:set, {key, value}})
                {:reply, :ok, state}
            :error ->
                {:ok, registry} = Bucket.start_link()
                GenServer.call(registry, {:set, {key, value}})
                {:reply, :ok, Map.put(state, bucket, registry)}
        end
    end


    def handle_call({:get, {bucket, key}}, _from, state) do #melhorar o retorno
        case Map.fetch(state, bucket) do
            {:ok, pid} ->
                IO.puts("inside get")
                value = GenServer.call(pid, {:get, key})
                IO.inspect(value)
            _ ->
                :error
        end
        {:reply, :ok, state}
    end


    def handle_call(:get_all, _from, state) do #apresentando problema
        {:reply, state, state}
    end



end
