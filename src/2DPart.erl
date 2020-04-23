-module('2DPart').
-import(ral, [nth/2,nthtail/2, from_list/1, replace/3]).
-export([main/0, procMain/6]).
% -import([timer])
% -compile(export_all).
get_element_in_index(List, Index) ->
	ral:nth(Index+1,List).

			
replace_element_in_list(List, Index, Value) ->
	ral:replace(Index+1,Value, List).	
	
head([]) ->
	[];
head([Head | _]) ->
    Head.

tail([]) ->
	[];
tail([_ | Rest]) ->
    Rest.



multiply_row(Row, [B | Bs], Acc) ->
	% io:format('Row ~w Mat Row ~w',[Row, ral:to_list(B)]),
    ZipProd = lists:zipwith(fun(X, Y) -> X * Y end, Row, ral:to_list(B)),
    Sum = lists:sum(ZipProd),
    multiply_row(Row, Bs, [Sum | Acc]);
multiply_row(_, [], Acc) ->
    lists:reverse(Acc).


vector_add(Row, Row2) ->
    ZipProd = lists:zipwith(fun(X, Y) -> X + Y end, Row, Row2),
	% io:format('Row ~w Mat Row ~w Result ~w~n',[Row, Row2, ZipProd]),
    ZipProd.
    


get_input(NumberOfEdgesLeft, NPerProc, NProc, Procs) ->
	if
		NumberOfEdgesLeft == 0 -> ok;
		true ->
			Contents = string:trim(io:get_line('')),
			X = (string:tokens(Contents, [$\s])),
			U = list_to_integer(head(X)),
			Col = U div NPerProc,
			V = list_to_integer(head(tail(X))),
			Row = V div NPerProc,

			Pid = Row*NProc + Col,
			Proc = get_element_in_index(Procs,Pid),
			Proc ! {U rem NPerProc, V rem NPerProc},

			get_input(NumberOfEdgesLeft -1, NPerProc, NProc, Procs)
	end.

			
% test_avg(M, F, A, N) when N > 0 ->
%    L = test_loop(M, F, A, N, []),
%    Length = length(L),
%    Min = lists:min(L),
%    Max = lists:max(L),
%    Med = lists:nth(round((Length / 2)), lists:sort(L)),
%    Avg = round(lists:foldl(fun(X, Sum) -> X + Sum end, 0, L) / Length),
%    {ok, OFile} = file:open("Times.txt",[append]),
%    io:fwrite(OFile, "Range: ~b - ~b mics Median: ~b mics Average: ~b mics~n", [Min, Max, Med, Avg]),
%    Med.

% test_loop(_M, _F, _A, 0, List) ->
% 	% io:format("Finished Test Loop~n"),
%    List;

% test_loop(M, F, A, N, List) ->

% 	% io:format("Test Loop ~w~n",[N]),
%    {T, _Result} = timer:tc(M, F, A),
%    test_loop(M, F, A, N - 1, [T|List]).

generateInitRow(N, Data)  ->
	if 
		N == 0 ->
			ral:from_list(Data);
		true ->
			NewData = Data ++ [0],
			generateInitRow(N-1,NewData)
	end.


generateInitMat(N, M, Data) ->
	if 
		N == 0 ->
			ral:from_list(Data);
		true ->
			NewData = Data ++ [generateInitRow(M,[])],
			generateInitMat(N-1, M, NewData)
	end.



recvSubMatrix(Mat)->
	receive
		done-> Mat;
		{U,V}->
			OldUList = get_element_in_index(Mat,V),
			NewUList = replace_element_in_list(OldUList, U, 1),
			NewData = replace_element_in_list(Mat, V, NewUList),
			recvSubMatrix(NewData)
	end.
	
getData()->
	receive
		L->
			L
	end.


printRow(Row, N, OrigN)->
	if 
		N == OrigN ->
			ok;
		true ->	
			El = get_element_in_index(Row, N),
			io:format('~w ',[El]),
			printRow(Row, N+1, OrigN)
	end.


printMatrix(Mat, N, OrigN)->
	if 
		N == OrigN ->
			ok;
		true ->
			List = get_element_in_index(Mat,N),
			printRow(List, 0, OrigN),
			io:format('~n',[]),
			printMatrix(Mat, N+1, OrigN)
	end.


sendVec(_, -1, _, _, _, _)-> ok;
sendVec(R, C, Me, V, ProcList, NProc)->
	if
		C /= Me->
			% io:format('pid ~w R ~w C ~w I ~w~n',[self(),R,C,R*NProc+C]),
			H =get_element_in_index(ProcList, R*NProc+C),
			H ! {V, Me},
			sendVec(R, C-1, Me, V, ProcList, NProc);
		true->
			sendVec(R, C-1, Me, V, ProcList, NProc)

	end.


sendTrans(R, C, V, ProcList, NProc)->
	if
		C /= R->
			% io:format('pid ~w R ~w C ~w I ~w~n',[self(),R,C,R*NProc+C]),
			H = get_element_in_index(ProcList, C*NProc+R),
			H ! V;
		true->
			ok
	end.

recvTrans(R,C, Vec)->
	if 
		C/=R->
			receive
				V->
					V
			end;
		true->
			Vec
	end.

assembleVec(_, -1, _, V, _)-> V;
assembleVec(R, C, Me, V, ProcList)->
	if
		C /= Me->
			receive
				{V_i, C}->
					assembleVec(R,C-1, Me, vector_add(V,V_i), ProcList)
			end;
		true->
			assembleVec(R,C-1, Me, V, ProcList)
	end.




conditionalPrintLoop(I, R, N, L1, L2)->
	if
		I==N->
			done;
		true->
			H1 = get_element_in_index(L1,I),
			H2 = get_element_in_index(L2,I),
			if 
				H1 == 0->
					if 
						H2 > 0->
							io:format('~w ',[N*R+I]),
							conditionalPrintLoop(I+1,R,N,L1,L2);

						true->
							conditionalPrintLoop(I+1,R,N,L1,L2)
					end;
			true->
				conditionalPrintLoop(I+1,R,N,L1,L2)
			end
	end.




% check(I,N, L)->
% 	if 
% 		I == N->
% 			1;
% 		true->
% 			H = get_element_in_index(L,I),
% 			if 
% 				H == 0->
% 					0;
% 				true->
% 					check(I+1,N,L)
% 			end
% 	end.

check(L1, L2)->
	if 
		L1 == L2->
			1;
		true->
			0
	end.

sendFlags(Fg, My, I, N, ProcList)->
	if 
		I == N->
			ok;
		I == My->
			sendFlags(Fg,My, I+1, N, ProcList);
		true->
			H = get_element_in_index(ProcList,I),
			% io:format('~w sent Fg to ~w~n',[My,I]),
			timer:sleep(1),
			H ! {Fg,My},
			sendFlags(Fg,My, I+1, N, ProcList)
	end.

getFlags(Cnt, My, I, N)->
	if 
		I == N->
			Cnt;
		I == My->
			getFlags(Cnt,My, I+1, N);
		true->
			receive
				{Fg,I}->
					% io:format('~w got Fg from ~w~n',[My,I]),
					getFlags(Cnt+Fg,My, I+1, N)
			end
	end.

procInnerLoop(Pid, NVec, R, C, ProcList, NProc, Mat)->
	% io:format('Pid ~w R ~w C ~w Vis: ~w ~n',[self(),R, C, NVec]),
	NVis = multiply_row(NVec, ral:to_list(Mat), []),
	% io:format('Pid ~w R ~w C ~w New Vis: ~w ~n',[self(),R, C, NVis]),
	sendVec(R, NProc-1, C, NVis, ProcList, NProc),
	Vis = assembleVec(R, NProc-1, C, NVis, ProcList),
	% io:format('Pid ~w R ~w C ~w Assembled Vis: ~w ~n',[self(),R, C, Vis]),
	% io:format("Crossed conditional Print Loop~n",[]),
	sendTrans(R,C, Vis, ProcList, NProc),
	RVec = recvTrans(R,C,Vis),
	% io:format('Pid ~w R ~w C ~w Received Vis: ~w ~n',[self(),R, C, RVec]),
	NextVec = vector_add(RVec,NVec),
	% io:format('Pid ~w R ~w C ~w Next Vec: ~w ~n',[self(),R, C, NextVec]),
	NextVecBin = lists:map(fun(X)-> if X == 0 -> 0; X > 0 -> 1; true -> -1 end  end, NextVec),
	if 
		R == 0->
			conditionalPrintLoop(0,C,length(Vis), ral:from_list(NVec), ral:from_list(NextVecBin));
		true->
			io:format('',[])
	end,

	% MyFg = check(0, length(NextVec), ral:from_list(NextVecBin)),
	MyFg = check(NVec, NextVecBin),
	sendFlags(MyFg, R*NProc+C, 0, NProc*NProc, ProcList),
	FgCnt = getFlags(MyFg, R*NProc+C, 0, NProc*NProc),

	% io:format("Flag Count ~w~n",[FgCnt]),
	if 
		FgCnt == NProc*NProc->
			% io:format('Done R ~w C ~w ~n',[R,C]),
			NextVecBin;
		true->
			
			% io:format('Not Done Yet R ~w C ~w ~n',[R,C]),
			timer:sleep(1),
			procInnerLoop(Pid, NextVecBin, R, C, ProcList, NProc, Mat)
	end.


procLoop(Pid, V, R, C, ProcList, NProc, Mat)->
	Flat = ral:to_list(V),
	% io:format('Start of new inner loop R ~w C ~w ~w~n',[R,C,Flat]),
	Pid ! { Flat,self(), R},
	receive
		done-> ok;
		none ->
			NVec = V,
			Next = procInnerLoop(Pid, ral:to_list(NVec), R, C, ProcList, NProc, Mat),
			procLoop(Pid, ral:from_list(Next), R, C, ProcList, NProc, Mat);
			
		Init ->
			NVec = replace_element_in_list(V, Init, 1),
			Next = procInnerLoop(Pid, ral:to_list(NVec), R, C, ProcList, NProc, Mat),
			procLoop(Pid, ral:from_list(Next), R, C, ProcList, NProc, Mat)
	end.


procMain(Pid, R, C, N_i, M_i, NProc)->
	ProcList = getData(),
	InitMat = generateInitMat(N_i, M_i, []),
	Mat = recvSubMatrix(InitMat),
	% io:format('R ~w C ~w~n',[R,C]),
	% printMatrix(Mat,0,N_i),
	V = generateInitRow(N_i, []),
	procLoop(Pid, V, R, C, ProcList, NProc, Mat).




spawnMultiple(0, ProcList, _, _)-> ProcList;
spawnMultiple(NProcCur, ProcList, N, NProc)->
	MPID = self(),
	R = (NProcCur-1) div NProc,
	C = (NProcCur-1) rem NProc,
	% io:format('N ~w R ~w C ~w~n',[NProcCur, R, C]),
	CPID = spawn('2DPart', procMain, [MPID, R, C, N div NProc + 1, N div NProc + 1, NProc]),
	spawnMultiple(NProcCur-1, [CPID | ProcList], N, NProc).


sendProcList(0, _)-> ok;
sendProcList(N, ProcList)->
	H = get_element_in_index(ProcList, N-1),
	% io:format("ProcList Sent to ~w~n",[H]),
	H ! ProcList,
	sendProcList(N-1, ProcList).

sendDone(0, _)-> ok;
sendDone(N, ProcList)->
	H = get_element_in_index(ProcList, N-1),
	% timer:sleep(50),
	% io:format("Done Sent to ~w~n",[H]),
	H ! done,
	sendDone(N-1, ProcList).


sendInit(0, _, _, _, _)-> 	ok;
sendInit(N, I, C, ProcList, NProc)-> 	
	H = get_element_in_index(ProcList, N-1),
	MC = (N-1) rem NProc,
	if 
		MC == C->
			% io:format("Sent ~w to ~w ~w~n",[I, N, H]),
			H ! I;
		true->
			% io:format("Sent none to ~w ~w~n",[N,H]),
			H ! none
	end,
	sendInit(N-1, I, C, ProcList, NProc).		


recvAll(I, N, ProcList, VVec)->
	if 
		I == N->
			VVec;
		true->
			Pid = get_element_in_index(ProcList, I),
			receive
				{V, Pid, C}->
					if 
						C == 0->
							recvAll(I+1, N, ProcList, VVec ++ V);
						true->
							recvAll(I+1, N, ProcList, VVec)
					end
			end
	end.


mainSubLoop(N, OrigN, L)->
	if
		N == OrigN->
			done; 
		true->
			H = get_element_in_index(L, N),
			if 
				H == 0->
					% io:format('WOOWOOOW ~w~n',[N]),
					N;
				true->
					mainSubLoop(N+1, OrigN, L)
			end
	end.

mainLoop(Nodes, NProc, ProcList)->
	Vis = recvAll(0,NProc*NProc, ProcList, []),
	Ind = mainSubLoop(0, Nodes, ral:from_list(Vis)),
	% io:format("Vis :~w Ind: ~w ~n",[Vis, Ind]),
	if 
		Ind == done->
			sendDone(NProc*NProc, ProcList),
			done;
		true->
			io:format('~w ',[Ind]),
			NV = Nodes div NProc + 1,
			PInd = Ind div NV, 
			PR = PInd rem NProc,
			PI = Ind rem NV,
			% io:format("PI :~w PInd: ~w~n",[PI, PInd]),
			sendInit(NProc*NProc, PI, PR, ProcList, NProc),
			mainLoop(Nodes, NProc, ProcList)
	end.


main() ->
	NProc = 3,
    Contents = string:trim(io:get_line('')),
    X = (string:tokens(Contents, [$\s])),
    N = list_to_integer(head(X)),
    M = list_to_integer(head(tail(X))),
	NPP = N div NProc + 1,
	ProcL = spawnMultiple(NProc*NProc, [], N, NProc),
	ProcList = ral:from_list(ProcL),
	% io:format("Spawn Done!~w~n",[ProcList]),
	sendProcList(NProc*NProc, ProcList),
    get_input(M, NPP, NProc, ProcList),
	sendDone(NProc*NProc, ProcList),
	mainLoop(N, NProc, ProcList).

% %    io:format("~w~n",[Graph]),
% 	Visited = generateInitVisted(N,[]),
%     Traversal = do_bfs(Graph,N, 0,Visited, []  ),

% %    io:format("Traversal: ~w~n",[Traversal]),
%     printLoop(Traversal),
%     test_avg('SeqBFS', 'reset_and_do_bfs', [Graph, N, 0, []], 5).




