%% 2 points.
%% A Latin square is an n × n matrix filled with n different symbols,
%% each occurring exactly once in each row and exactly once in each
%% column. (Note that a sudoku is a 9x9 latin square with additional
%% constraints on the 3x3 boxes).

%% Extend this Prolog source for completing a partially filled Latin
%% square with the first n numbers 1, ..., n.

:- use_module(library(clpfd)). 

example1 :- latin([2,_,_,3,
                   3,_,_,_,
                   _,_,_,1,
                   _,_,4,_]).

example2 :- latin([5,3,9,_,7,_,_,_,8,
                   6,_,_,1,9,5,_,_,_,
                   _,9,8,_,_,_,_,6,_,
                   8,_,_,_,6,_,_,_,3,
                   4,_,_,8,_,3,_,_,1,
                   7,5,3,_,2,_,_,_,6,
                   _,6,7,_,_,_,2,8,_,
                   _,_,_,4,1,9,_,_,5,
                   2,_,_,_,8,_,_,7,9]).

latin(L) :-
    length(L, Len),
    S is round(sqrt(Len)),  %% sqrt means square root.  Len must be a perfect square
    L ins 1..S,
    matrixByRows(S, L, MatrixByRows),
    constraintsFromSubLists(MatrixByRows),
    ...
    pretty_print(S, L).

pretty_print(S, L):- pretty_print_aux(S, L, S).

pretty_print_aux(_, [], _).
pretty_print_aux(S, L, 0):- L\=[],  nl,  pretty_print_aux(S, L, S).
pretty_print_aux(S, [X|L], N):-
        N>0,  write(X),  write(' '),
        N1 is N-1,  pretty_print_aux(S, L, N1).

matrixByRows(...

constraintsFromSubLists(...
