-module('ParallelBFS_SharedMem').
-import(ets,[lookup/2,insert/2, match_delete/2, new/2]).
-import(lists,[flatlength/1]).
-export([main/0, parallel_bfs_element/5]).
% -compile(export_all).


	
add_to_traversal(Traversal,Node) ->
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


call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,Node, N) ->
	if 
		Node == N ->
			get_second_elements(ets:lookup(traversal,0));
			
		true ->
			IsVis = checkifNodeVisited(VisitedTab,Node),
			if 
				IsVis == 0 ->
					ets:insert(FrontierTab,{0,Node}),
					parallel_bfs(GraphTab,VisitedTab,FrontierTab, Traversal),
					call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,Node + 1 , N);
				true ->
					call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,Node + 1 , N)
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
	call_bfs_on_every_element(GraphTab,VisitedTab,FrontierTab,Traversal,0 , N).
