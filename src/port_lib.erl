-module(port_lib).

-export([run_interactive_cmd/1]).

%%--------------------------------------------------------------------
%% @doc Запускает цикл обработки порта внешнего процесса, запускает рядом поток чтения ввода
%% @end
%%--------------------------------------------------------------------
run_interactive_cmd(CMD) ->
    Port = erlang:open_port({spawn, CMD}, [exit_status, eof]),
    InputPid = spawn_link(fun()-> input(Port) end),
    run_interactive_cmd_(Port).

run_interactive_cmd_(Port) ->
    Continue =
    receive
        {Port, {data, Data}} ->
            io:format("~s", [Data]),
            run_interactive_cmd_(Port);

        {Port, eof} ->
            port_close(Port),
            receive
                {Port, {exit_status, N}} ->
                    ok
            end
    end.
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
input(Port) ->
    case io:get_chars("", 1) of
        {error, _} ->
            ok;

        eof ->
            ok;
        
        Input ->
            port_command(Port, Input)
    end,
    timer:sleep(16),
    input(Port).
%%--------------------------------------------------------------------

