-module('Graph').

-export([main/0, get_nodes/3, head/1, tail/1, bfs1/4]).


get_nodes(NumberOfNodes, NumberOfNodesLeft, Data) ->
    if
        NumberOfNodesLeft == 0 ->
            Data;
        true ->
            Node = NumberOfNodes - NumberOfNodesLeft + 1,
            Contents = string:trim(io:get_line('')),
            X = (string:tokens(Contents, [$\s])),
            Val = list_to_integer(head(X)),
            Children = tointeger(tail(X)),
            Data1 = Data ++ [[Node,Val,Children]],
            get_nodes(NumberOfNodes,NumberOfNodesLeft-1,Data1)
   end.


tointeger([]) ->
    [];
tointeger([Head|Rest]) ->
    [list_to_integer(Head) | tointeger(Rest)].

head([Head | _]) ->
    Head.
tail([_ | Rest]) ->
    Rest.

bfs1(Graph, CurInd, Key, Stack) ->
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

main() ->
    %% App 1: 
    %% Enter the Number of Nodes (N), then in the next N lines enter the value at node n, and the children of node n,  if no children enter nothing. Enter the value to search for. Returns the node at which it is present else if not present at all returns -1.
    Contents = string:trim(io:get_line('')),
    X = (string:tokens(Contents, [$\s])),
    N = list_to_integer(head(X)),
    Graph = get_nodes(N,N,[]),
    io:format("~w~n",[Graph]),
    Contents1 = string:trim(io:get_line('')),
    X1 = (string:tokens(Contents1, [$\s])),
    Val = list_to_integer(head(X1)),
    Ind = bfs1(Graph,1,Val,[1]),
    io:format("Value found at Index: ~p~n",[Ind]).


