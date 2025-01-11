%% --------- [3 points] ---------- %%

%% In a *sliding puzzle* we have an NxN board with N^2-1 tiles, each
%% placed on a square and marked with a different number 1, 2, ..., N^2-1.
%% We will represent the remaining empty square with a cross.
%% A *move* in the puzzle consists in sliding one or more tiles
%% horizontally in the row or vertically in the column of the empty square.

%% Let us consider the following example with N = 3. From

%%      1  5  3
%%      2  x  8
%%      4  7  6

%% we can get

%%      1  5  3
%%      x  2  8
%%      4  7  6

%% in one move, by sliding tile 2 to the right.
%% From this, with one more move we can get

%%      x  5  3
%%      1  2  8
%%      4  7  6

%% by sliding down tile 1.

%% We can slide more than one tile in a single move. E.g., in the
%% previous board we can slide all tiles on the top row to the left,
%% which yields

%%      5  3  x
%%      1  2  8
%%      4  7  6

%% The goal of the puzzle is to rearrange the tiles so that the empty
%% square is at the lower right corner, and when the board is traversed
%% by rows from top to bottom, the numbers of the tiles form the sequence
%% 1, 2, 3, ...; e.g., when N = 3, the goal would be:

%%      1  2  3
%%      4  5  6
%%      7  8  x

%% Write a Prolog program for solving sliding puzzles
%% with the least number of moves.


%% example(N, InitialBoard, FinalBoard)
example(1, [[x,1,3],
            [4,2,5],
            [7,8,6]],
                      [[1,2,3],
                       [4,5,6],
                       [7,8,x]]).    %% Cost: 4

example(2, [[1,5,3],
            [2,x,8],
            [4,7,6]],
                      [[1,2,3],
                       [4,5,6],
                       [7,8,x]]).    %% Cost: 12

example(3, [[x,8,7],
            [6,5,4],
            [3,2,1]],
                      [[1,2,3],
                       [4,5,6],
                       [7,8,x]]).    %% Cost: 14

%% column(Board, J, Col)  holds
%%   if Col is a list that contains the elements in the Jth column of Board
column(Board, J, Col) :-
    length(Board, N),
    findall(X, (between(1, N, I), nth1(I, Board, Row), nth1(J, Row, X)), Col).

%% transpose(Board, Trans) holds
%%   if Trans is the transposed matrix of Board
transpose(Board, Trans) :-
    length(Board, N),
    findall(Col, (between(1, N, J), column(Board, J, Col)), Trans).

%% step(OldBoard, NewBoard) holds
%%   if Newboard is obtained by applying one *horitzontal move* to the tiles
%%   in OldBoard. Note: this move can slide one o more tiles.
step(OldBoard, NewBoard) :-
    append(RowsBefore, [OldRow | RowsAfter], OldBoard),
    nth1(OldI, OldRow, x, RestRow),      %% nth1(N, List, Elem, Rest): Select/insert element at index.
                                         %% True when Elem is the Nth (1-based) element of List
                                         %% and Rest is the remainder (as in by select/3) of List.
    nth1(NewI, NewRow, x, RestRow),
    OldI \= NewI,
    append(RowsBefore, [NewRow | RowsAfter], NewBoard).

%% oneStep(Cost, OldBoard, NewBoard) holds
%%   if Newboard is obtained by applying one move to the tiles
%%   in OldBoard. Note: Cost is always 1 regardless of transformation
oneStep(1, OldBoard, NewBoard) :-
    step(OldBoard, NewBoard).
oneStep(1, OldBoard, NewBoard) :-
    transpose(OldBoard, OldTrans),
    step(OldTrans, NewTrans),
    transpose(NewTrans, NewBoard).


main(N) :-
    example(N, Ini, Fin),
    between(0, 1000, Cost),
    path(Cost, Ini, Fin, [Ini], Path),
    reverse(Path, Path1),
    displaySol(Path1),
    nl, write('Cost: '), write(Cost), nl, halt.

path( 0, E, E, C,C ).
path( CostMax, Cur, Fin, PathSoFar, PathTotal ) :-
    CostMax > 0,
    oneStep( CostStep, Cur, Next ),
    \+ member( Next, PathSoFar ),
    CostMax1 is CostMax - CostStep,
    path(CostMax1, Next, Fin, [Next|PathSoFar], PathTotal).

displaySol([]).
displaySol([Board|L]) :-
    displayBoard(Board), nl,
    displaySol(L).

displayBoard(Board) :-
    nth1(_, Board, Row), nl, nth1(_, Row, E),
    write(E), write(' '), fail.
displayBoard(_).
