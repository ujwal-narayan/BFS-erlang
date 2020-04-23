-module('bfs_one_d').
-export([process_list/1,pred/1,main/1]).

pred(Elem) ->
	if
		Elem == 1 ->
			return true
		true ->
			return false
	end.

send_list(Ver) ->
	
	Data = element(2, lists:nth(1, ets:lookup(ver))),

	if
		any(pred, data) ->
			
			Newbie = element(where(pred, Data), Data)
			Listo = [newbie]

			%check for any other neighbour belonging to same process, append to list
			PIDs = element(3, lists:nth(1, ets:lookup(user_lookup, newbie)))
			lists:append(Listo, element(where(pred, Data), Data))
			
			%send list to process
			Listo ! SendPID

			send_list(Ver)

		true ->
			pass
	
	end

process_list(Msg) ->

	if
		Msg != [] ->
			
			Ver = Msg.pop(),
			%print
			io:format(File, "~w\n", [Ver]),
			%mark visited in ETS table
			Data = element(2, lists:nth(1, ets:lookup(user_lookup, Ver))),
			ets:insert(Ver, {Ver, Data, 1}),
			send_list(Ver),
			process_list(Msg)

		true ->
			pass
	end.
	

proc_response() ->

	if
		%check for any ets record marked unvisited that belongs to this process ->
		ets:lookup(user_lookup, self.PID) = [] ->
			receive
				Msg ->

					process_list(Msg),
					proc_response()

		true ->
			"Hello" ! main_proc
	end.

main_response(Main_num) ->
	
	if 
		Main_num > 0 ->
			receive
				Msg ->
					main_response(Main_num - 1)
			end

		true ->
			pass
	end.
			

main(Args) ->
	
	Inpfile = lists:nth(1, Args),
    Outfile = lists:nth(2, Args),

    {ok,Filetwo} = file:open(Inpfile, read),
    Line1 = io:get_line(Filetwo, ''),
    Line = string:strip(Line1,both,$\n),
    Inputs = [list_to_integer(I) || I <- string:tokens(Line, " ")],
    Numfunc = lists:nth(1, Inputs),
    Token = lists:nth(2, Inputs),
    file:close(Filetwo),
	Num_procs = (vertices // 5) + 1,
	
	Child_pid = spawn('module name', proc_response);

	%build ets table
	ets:new(user_lookup, [set, public, named_table]),

	Root = 1,

	Record = ets.lookup: num == root, Process = Record.pid,

	Sendlis = [Root],
	Sendlis ! Rrocess,

	main_response(Num_procs),

	%flush table