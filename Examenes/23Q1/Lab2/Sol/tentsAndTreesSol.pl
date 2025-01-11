%% --------- [3 points] ---------- %%

%% Place a tent next to each tree. Place it NORTH, EAST, SOUTH or WEST
%% of the tree, but never outside the box. Each cell can have at most
%% one tent. The final solution should have the same number of tents and
%% trees. Trees are marked with *. Tents are marked with T. There may
%% be more than one solution. Just find one.
%%    
%%           INPUT            ONE SOLUTION
%%      1 2 3 4 5 6 7 8      1 2 3 4 5 6 7 8     
%%     -----------------    -----------------   
%%  1 |       *         |  |     T * T T     | 
%%  2 |     *   * *     |  |     *   * *     | 
%%  3 |                 |  |         T T     | 
%%  4 |           *     |  | T T   T   *     | 
%%  5 | * *   *         |  | * *   * T     T | 
%%  6 |   *     *     * |  |   * T   *     * | 
%%  7 |                 |  |   T             | 
%%  8 |   *             |  |   *             | 
%%     -----------------    -----------------  
%%
%%    OUTPUT
%% [1,4]: West        inside: OK        in free: OK        one tent: OK  
%% [2,3]: West        inside: OK        in free: OK        one tent: OK  
%% [2,5]: West        inside: OK        in free: OK        one tent: OK  
%% [2,6]: East        inside: OK        in free: OK        one tent: OK  
%% [4,6]: West        inside: OK        in free: OK        one tent: OK  
%% [5,1]: South       inside: OK        in free: OK        one tent: OK  
%% [5,2]: East        inside: OK        in free: OK        one tent: OK  
%% [5,4]: East        inside: OK        in free: OK        one tent: OK  
%% [6,2]: East        inside: OK        in free: OK        one tent: OK  
%% [6,5]: West        inside: OK        in free: OK        one tent: OK  
%% [6,8]: West        inside: OK        in free: OK        one tent: OK  
%% [8,2]: West        inside: OK        in free: OK        one tent: OK  


:- use_module(library(clpfd)).

example(a, 2, 2, [[1,1],[2,2]] ).
%     INPUT              ONE SOLUTION   (2 different solutions [different Vars assigments])
%      1 2                   1 2
%     -----                 -----
%  1 | *   |               | * T |
%  2 |   * |               | T * |
%     -----                 -----
% [1,1]: East
% [2,2]: West
example(b, 2, 2, [[1,1],[1,2],[2,2]] ).
%     INPUT            NO SOLUTION EXISTS
%      1 2             
%     -----            
%  1 | * * |           
%  2 |   * |           
%     -----            
example(c, 8, 8, [[1,4],[2,3],[2,5],[2,6],[4,6],[5,1],[5,2],
                  [5,4],[6,2],[6,5],[6,8],[8,2]] ).          %% 216216 different solutions
example(d, 4, 3, [[1,1],[1,3],[2,2],[3,1],[3,3],[4,3]]).     %% 4 different solutions
example(e, 3, 3, [[1,1],[1,3],[3,1],[3,3]]).                 %% 2 different solutions


main(E):-
    example(E, N, M, Trees),
    %1. Variables + domains
    length(Trees, NVars), 
    length(DRVars, NVars), % list of Prolog vars (names do not matter)
    length(DCVars, NVars), % list of Prolog vars (names do not matter)
    append(DRVars, DCVars, Vars),
    Vars ins -1..1,
    %2. Constraints
    onlyNESWCells(DRVars, DCVars),
    tentsInBox(N, M, Trees, DRVars, DCVars),
    tentsInFreeSpaces(Trees, DRVars, DCVars),
    noTwoTentsOnSameSpot(Trees, DRVars, DCVars),
    %3. Labeling
    label(Vars),
    %4. Write Solution
    print(N, M, Trees, DRVars, DCVars).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% generate constraints:
%a. onlyNESWCells
onlyNESWCells([], []).
onlyNESWCells([DR|DRs], [DC|DCs]) :-
    abs(DR+DC) #= 1,
    onlyNESWCells(DRs, DCs).

%b. tentsInBox
tentsInBox(_, _, [], [], []).
tentsInBox(N, M, [[R,C]|Ts], [DR|DRs],[DC|DCs]) :-
    tentsInBoxAux(N, M, R, C, DR, DC),
    tentsInBox(N, M, Ts, DRs, DCs).

tentsInBoxAux(N, M, R, C, DR, DC) :-
    R+DR #>= 1, R+DR #=< N, 
    C+DC #>= 1, C+DC #=< M.

%c. tentsInFreeSpaces
tentsInFreeSpaces([], [], []).
tentsInFreeSpaces([[R,C]|Ts], [DR|DRs], [DC|DCs]) :-
    tentsInFreeSpacesAux(R, C, DR, DC, Ts, DRs, DCs),
    tentsInFreeSpaces(Ts, DRs, DCs).

tentsInFreeSpacesAux(_, _, _, _, [], [], []).
tentsInFreeSpacesAux(R, C, DR, DC, [[R2,C2]|Ts], [DR2|DRs], [DC2|DCs]) :-
    R+DR #\= R2 #\/ C+DC #\= C2,     % the tree in [R,C]   does not locate its tend in [R2,C2]
    R #\= R2+DR2 #\/ C #\= C2+DC2,   % the tree in [R2,C2] does not locate its tend in [R,C]
    tentsInFreeSpacesAux(R, C, DR, DC, Ts, DRs, DCs).
    

%d. noTwoTentsOnSameSpot
noTwoTentsOnSameSpot([], [], []).
noTwoTentsOnSameSpot([[R,C]|Ts], [DR|DRs], [DC|DCs]) :-
    noTwoTentsOnSameSpotAux(R, C, DR, DC, Ts, DRs, DCs),
    noTwoTentsOnSameSpot(Ts, DRs, DCs).

noTwoTentsOnSameSpotAux(_, _, _, _, [], [], []).
noTwoTentsOnSameSpotAux(R, C, DR, DC, [[R2,C2]|Ts], [DR2|DRs], [DC2|DCs]) :-
    R+DR #\= R2+DR2 #\/ C+DC #\= C2+DC2,
    noTwoTentsOnSameSpotAux(R, C, DR, DC, Ts, DRs, DCs).

     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% print solution
print(N, M, Ts, DRs, DCs) :-
    nth1(K, Ts, [R,C], RestTs),
    nth1(K, DRs, DR, RestDRs),
    nth1(K, DCs, DC, RestDCs),
    write([R,C]), write(": "),
    print_position(DR, DC),
    write('      '),
    verifyInside(N, M, R, C, DR, DC),
    write('      '),
    verifyFree(R, C, DR, DC, Ts),
    write('      '),
    verifyOne(R, C, DR, DC, RestTs, RestDRs, RestDCs),
    nl,
    fail.
print(_, _, _, _, _).
         
print_position(-1, 0) :- write('North '), !.
print_position( 0, 1) :- write('East  '), !.
print_position( 1, 0) :- write('South '), !.
print_position( 0,-1) :- write('West  '), !.

verifyInside(N, M, R, C, DR, DC):-
    R+DR >= 1, R+DR =< N,
    C+DC >= 1, C+DC =< M,
    write('inside: OK  '), !.
verifyInside(_, _, _, _, _, _):-
    write('inside: FAIL').

verifyFree(R, C, DR, DC, AllTs):-
    findall([R2,C2], (member([R2,C2],AllTs), R2 is R+DR, C2 is C+DC), []),
    write('in free: OK  '), !.
verifyFree(_, _, _, _, _):-
    write('in free: FAIL').

verifyOne(R, C, DR, DC, Ts, DRs, DCs):-
    R1 is R+DR, C1 is C+DC,
    findall([R1,C1], (nth1(K,Ts,[R2,C2]), nth1(K,DRs,DR2), nth1(K,DCs,DC2), R1 is R2+DR2, C1 is C2+DC2), []),
    write('one tent: OK  '), !.
verifyOne(_, _, _, _, _, _, _):-
    write('one tent: FAIL').
