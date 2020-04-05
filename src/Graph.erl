-module('Graph').
-export([main/0]).
-compile(export_all).
get_element_in_index(List, Index) ->
	lists:nth(Index+1,List).

			
replace_element_in_list(List, Index, Value) ->
	lists:sublist(List,Index) ++ [Value] ++ lists:nthtail(Index+1, List).	
		
	

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

			


tointeger([]) ->
    [];
tointeger([Head|Rest]) ->
    [list_to_integer(Head) | tointeger(Rest)].

head([Head | _]) ->
    Head.
tail([_ | Rest]) ->
    Rest.

bfs1(Graph, CurInd, Key, Stack ) ->
    X = lists:nth(CurInd,Graph),
    Val = head(tail(X)),
    if
        Key == Val ->
            CurInd;
        true ->
            if
                Stack == [] ->
                    -1;
            true ->
                    Children = head(tail(tail(X))),
                    NewStack = tail(Stack) ++ Children,
                    bfs1(Graph, head(Stack),Key,NewStack)
            end
    end.



bfs(Graph, Node, Frontier, Visited, Traversal) ->
	IsVis = get_element_in_index(Visited, Node),
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

		
	
	
					
	

generateInitData(N, Data) ->
	if 
		N == 0 ->
			Data;
		true ->
			NewData = Data ++ [[]],
			generateInitData(N-1,NewData)
	end.
			
generateInitVisted(N,Data) ->
	if 
		N == 0 ->
			Data;
		true ->
			NewData = Data ++ [0],
			generateInitVisted(N-1,NewData)
	end.


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
    io:format("Traversal: ~p~n",[Traversal]).


