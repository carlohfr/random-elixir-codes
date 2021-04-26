defmodule Client do

    require Logger
    use GenServer

    @ip {127, 0, 0, 1}
    @port 10000


    def start_link(_) do
        GenServer.start(__MODULE__, %{socket: nil})
    end


    def init(state) do
        GenServer.cast(self(), :connect)
        send_message(self(), "version: 1.0\r\nto: 127.0.0.1:10000\r\nfrom: client\r\naction: register-client\r\ntype: request\r\nbody-size: 0\r\n\r\n")
        {:ok, state}
    end


    def send_message(pid, message) do
        GenServer.cast(pid, {:message, message})
    end


    #def disconnect(state, reason) do
    #    Logger.info "Disconnected: #{reason}"
    #    {:stop, :normal, state}
    #end


    def handle_cast(:connect, state) do
        Logger.info "Connecting to #{:inet.ntoa(@ip)}:#{@port}"

        case :gen_tcp.connect(@ip, @port, [:binary, active: true]) do
            {:ok, socket} ->
                {:noreply, %{state | socket: socket}}
            {:error, reason} ->
                Logger.info "Disconnected: #{reason}"
                {:stop, :normal, state}
        end
    end


    def handle_cast({:message, message}, %{socket: socket} = state) do
        Logger.info "Sending #{message}"

        :ok = :gen_tcp.send(socket, message)
        {:noreply, state}
    end


    def handle_info({:tcp, _, data}, state) do
        Logger.info "Received #{data}"
        {:noreply, state}
    end


    def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}
    def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}

end
