-module('ParallelBFS_SharedMem').
-import(ets,[lookup/2,insert/2, match_delete/2, new/2]).
-import(lists,[flatlength/1]).
-export([main/0, parallel_bfs_element/5, reset_and_do_bfs/5 ]).
% -compile(export_all).


	
add_to_traversal(Traversal,Node) ->
	io:format("~p ",[Node]),
	ets:insert(Traversal,{0,Node}).

mark_the_node_visited(VisitedTab,Node) ->
	ets:insert(VisitedTab,{Node,1}).

get_the_nbrs(GraphTab,Node) ->
	{_,Nbrs} = lists:unzip(ets:lookup(GraphTab, Node)),
	Nbrs.

get_second_elements(List) ->
	{_,Val} = lists:unzip(List),
	Val.

add_nbrs_to_front(FrontierTab,Nbrs) ->
	if 
		Nbrs == [] ->
			FrontierTab;
		true ->
			ets:insert(FrontierTab,{0,head(Nbrs)}),
			add_nbrs_to_front(FrontierTab,tail(Nbrs)),
			FrontierTab
	end.

parallel_bfs_element(GraphTab, Node, VisitedTab,FrontierTab, Traversal) ->
		Nbrs = get_the_nbrs(GraphTab,Node),
		add_nbrs_to_front(FrontierTab,Nbrs).
	
call_bfs(GraphTab,VisitedTab,FrontierTab,Traversal,Frontier,NumProcs) ->
	if 
		NumProcs == 0 ->
			ok;
		true ->
			Node = head(Frontier),
			IsVis = checkifNodeVisited(VisitedTab,Node),
		
			if
				IsVis == 0 -> 
					ets:match_delete(FrontierTab,{0,Node}),
					add_to_traversal(Traversal,Node),
					mark_the_node_visited(VisitedTab,Node),	
					spawn('ParallelBFS_SharedMem',parallel_bfs_element,[GraphTab,Node,VisitedTab,FrontierTab,Traversal]),
					call_bfs(GraphTab,VisitedTab,FrontierTab,Traversal,tail(Frontier),NumProcs-1);
				true ->
					call_bfs(GraphTab,VisitedTab,FrontierTab,Traversal,tail(Frontier),NumProcs-1)
			end
	end.	
					

parallel_bfs(GraphTab,VisitedTab,FrontierTab,Traversal) ->
	% spawn a program for each process in the neighbour and run bfs per element on  them 
	
	Frontier = get_second_elements(ets:lookup(FrontierTab,0)),
	NumProcs = lists:flatlength(Frontier),
	if
		
		NumProcs > 0 ->
			call_bfs(GraphTab,VisitedTab,FrontierTab,Traversal,Frontier,NumProcs),
			parallel_bfs(GraphTab,VisitedTab,FrontierTab,Traversal);
		true ->
			ok
	end.

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


call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,Node, N) ->
	if 
		Node == N ->
			ok;
		true ->
			io:format(""),
			Nbrs = get_the_nbrs(GraphTab,Node),
			Connected = lists:flatlength(Nbrs),
			IsVis = checkifNodeVisited(VisitedTab,Node),
			if 
				IsVis == 0 ->
					if 
						Connected == 0 ->
							call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,Node + 1 , N);
						true -> 
							ets:insert(FrontierTab,{0,Node}),
							parallel_bfs(GraphTab,VisitedTab,FrontierTab, Traversal),
							call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,Node + 1 , N)
					end;
				true ->
					call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,Node + 1 , N)
			end
	end.
				

take_care_of_unconnected(GraphTab, VisitedTab,Node,N) ->
	if 
		Node == N ->
			ok;
		true ->
			IsVis = checkifNodeVisited(VisitedTab,Node),
			if 
				IsVis == 0 ->
					io:format("~p ",[Node]),
					take_care_of_unconnected(GraphTab,VisitedTab,Node + 1, N);
				true ->
					take_care_of_unconnected(GraphTab,VisitedTab,Node + 1, N)
			end
	end.

			
head([]) ->
    [];	
head([Head | _]) ->
    Head.

tail([]) ->
    [];
tail([_ | Rest]) ->
    Rest.

get_input(NumberOfEdges, NumberOfEdgesLeft, GraphTab) ->
	if
		NumberOfEdgesLeft == 0 ->
			ok;
		true ->
			Contents = string:trim(io:get_line('')),
			X = (string:tokens(Contents, [$\s])),
			U = list_to_integer(head(X)),
			V = list_to_integer(head(tail(X))),
			ets:insert(GraphTab, {U,V}),
			get_input(NumberOfEdges, NumberOfEdgesLeft -1, GraphTab)
	end.

generateInitVisited(VisitedTab,N) ->
	if 
		N == 0 ->
			ok;
			% ets:match_object(VisitedTab, {'$0', '$1'});
		true ->
			ets:insert(VisitedTab,{N-1,0}),
			generateInitVisited(VisitedTab,N-1)
	end.			

checkifNodeVisited(VisitedTab, N) ->
	[{_,Val}] = ets:lookup(VisitedTab, N),
	Val.
	


reset_and_do_bfs(GraphTab, VisitedTab, FrontierTab, Traversal,N) ->
	generateInitVisited(VisitedTab,N),
	call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,0 , N),
	take_care_of_unconnected(GraphTab,VisitedTab,0,N).
   
main() ->
	Contents = string:trim(io:get_line('')),
	X = (string:tokens(Contents, [$\s])),
	N = list_to_integer(head(X)),
	M = list_to_integer(head(tail(X))),
	GraphTab = ets:new(graph,[bag,public,named_table]),
	VisitedTab = ets:new(visited,[set,public,named_table]),
	FrontierTab = ets:new(frontier,[bag,public,named_table]),
	Traversal = ets:new(traversal,[bag,public,named_table]),
	get_input(N,M,GraphTab),
	generateInitVisited(VisitedTab,N),
	call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,0 , N),
	take_care_of_unconnected(GraphTab,VisitedTab,0,N),
	io:format("~n"),
	% test_avg('ParallelBFS_SharedMem', 'reset_and_do_bfs', [GraphTab, VisitedTab, FrontierTab, Traversal,N], 5),
	io:format("").
