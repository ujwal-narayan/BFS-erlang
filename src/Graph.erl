-module('Graph').
-export([main/0, generateInitData/2, head/1, tail/1, bfs1/4, get_element_in_index/2, replace_element_in_list/3, get_input/3]).

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

bfs(Graph,TotalNodes,  CurNode, Visited, Traversal) ->
	if 
		CurNode == TotalNodes ->
			Traversal;
		true ->
			IsVisited = get_element_in_index(Visited, CurNode),
			if
				IsVisited == 0 ->
					
	

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
    io:format("~w~n",[Graph]),
	Visited = generateInitVisted(N,[]),
    Traversal = bfs(Graph,0,[0], Visited,[] ),
    io:format("Traversal: ~p~n",[Traversal]).


