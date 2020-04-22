-module('PBFS_sm').
-import(ral, [nth/2,nthtail/2, from_list/1, replace/3]).
-export([main/0, do_bfs/5, reset_and_do_bfs/4]).
% -import([timer])
% -compile(export_all).
get_element_in_index(List, Index) ->
	ral:nth(Index+1,List).

			
replace_element_in_list(List, Index, Value) ->
	ral:replace(Index+1,Value, List).	
	

get_input(NumberOfEdges, NumberOfEdgesLeft, Data) ->
	if
		NumberOfEdgesLeft == 0 ->
			Data;
		true ->
			Contents = string:trim(io:get_line('')),
			X = (string:tokens(Contents, [$\s])),
			U = list_to_integer(head(X)),
			V = list_to_integer(head(tail(X))),
			OldUList = get_element_in_index(Data,U),
			NewUList = OldUList ++ [V],
			NewData = replace_element_in_list(Data, U, NewUList),
			get_input(NumberOfEdges, NumberOfEdgesLeft -1, NewData)
	end.

			



head([]) ->
	[];
head([Head | _]) ->
    Head.

tail([]) ->
	[];
tail([_ | Rest]) ->
    Rest.




bfs(Graph, Node, Frontier, Visited, Traversal) ->
	if
		Node == [] ->
			{Visited, Traversal};
		true ->
			IsVis = get_element_in_index(Visited, Node),
			% io:format("Node ~p~n",[Node]),
			if
				IsVis == 0 ->
					Kids = get_element_in_index(Graph, Node),
					NewFrontier = Frontier ++ Kids,
					NewVisisted = replace_element_in_list(Visited, Node,1),
					NewTraversal = Traversal ++ [Node],
					bfs(Graph, head(NewFrontier), tail(NewFrontier), NewVisisted, NewTraversal);
				true ->
					if 
						Frontier == [] ->
							{Visited, Traversal};
						true ->
							bfs(Graph, head(Frontier), tail(Frontier), Visited, Traversal)
					end
			end
	end.


do_bfs(Graph,Nodes, Node, Visited, Traversal) ->
	if 
		Node == Nodes ->
			Traversal;
		true -> 
			IsVis = get_element_in_index(Visited, Node),
			if 
				IsVis == 0 ->
					{NewVisited, NewTraversal}  = bfs(Graph, Node, [], Visited, Traversal),
					do_bfs(Graph, Nodes, Node + 1, NewVisited, NewTraversal);
				true ->
					do_bfs(Graph, Nodes, Node + 1, Visited, Traversal)
			end
	end.

		

reset_and_do_bfs(Graph, Nodes, Node, Traversal) ->
   Visited = generateInitVisted(Nodes,[]),
   do_bfs(Graph, Nodes, Node, Visited, Traversal).
	
					
	

generateInitData(N, Data) ->
	if 
		N == 0 ->
			ral:from_list(Data);
		true ->
			NewData = Data ++ [[]],
			generateInitData(N-1,NewData)
	end.
			
generateInitVisted(N,Data) ->
	if 
		N == 0 ->
			ral:from_list(Data);
		true ->
			NewData = Data ++ [0],
			generateInitVisted(N-1,NewData)
	end.

printLoop([])-> ok;
printLoop([H|T])->
	io:format("~p ",[H]),
	printLoop(T).


test_avg(M, F, A, N) when N > 0 ->
   L = test_loop(M, F, A, N, []),
   Length = length(L),
   Min = lists:min(L),
   Max = lists:max(L),
   Med = lists:nth(round((Length / 2)), lists:sort(L)),
   Avg = round(lists:foldl(fun(X, Sum) -> X + Sum end, 0, L) / Length),
   {ok, OFile} = file:open("Times.txt",[append]),
   io:fwrite(OFile, "Range: ~b - ~b mics Median: ~b mics Average: ~b mics~n", [Min, Max, Med, Avg]),
   Med.

test_loop(_M, _F, _A, 0, List) ->
	% io:format("Finished Test Loop~n"),
   List;

test_loop(M, F, A, N, List) ->

	% io:format("Test Loop ~p~n",[N]),
   {T, _Result} = timer:tc(M, F, A),
   test_loop(M, F, A, N - 1, [T|List]).



main() ->
    Contents = string:trim(io:get_line('')),
    X = (string:tokens(Contents, [$\s])),
    N = list_to_integer(head(X)),
    M = list_to_integer(head(tail(X))),
	InitData = generateInitData(N, []),
    Graph = get_input(N,M, InitData),
%    io:format("~w~n",[Graph]),
	Visited = generateInitVisted(N,[]),
    Traversal = do_bfs(Graph,N, 0,Visited, []  ),

%    io:format("Traversal: ~p~n",[Traversal]),
    printLoop(Traversal),
    test_avg('SeqBFS', 'reset_and_do_bfs', [Graph, N, 0, []], 5).


