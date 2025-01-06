%% --------- [3 points] ---------- %%

% findPath(P1, P2) finds the minimum-cost sequence of transpositions that
% transforms permutation P1 into permutation P2, where the cost of a
% transposition is the distance between the positions of the two elements
% that are exchanged. The total cost of the sequence of transpositions is
% the sum of the costs of the individual steps.

% Example:
% findPath([5,1,3,4,2,6],[1,2,3,4,5,6],Path,Cost) finds a Path of Cost 4 
% which corresponds to the sequence of 2 transpositions: 
%   [5,1,3,4,2,6] (exchange between positions 1 and 2; cost 1)
%   [1,5,3,4,2,6] (exchange between positions 2 and 5; cost 3)
%   [1,2,3,4,5,6] (total cost 1+3 = 4)

% startEnd(Id, InitialState, FinalState)
startEnd(a, [1,2,3,4], [1,2,3,4]). % optimal cost: 0
startEnd(b, [1,3,2,4], [1,2,3,4]). % optimal cost: 1
startEnd(c, [2,4,1,3], [1,2,3,4]). % optimal cost: 3
startEnd(d, [4,2,3,1], [1,2,3,4]). % optimal cost: 3
startEnd(e, [5,1,3,4,2,6], [1,2,3,4,5,6]). % optimal cost: 4
startEnd(f, [1,5,4,6,2,3], [1,2,3,4,5,6]). % optimal cost: 6
startEnd(g, [1,2,3,4,5,6], [1,2,3,4,5,6]). % optimal cost: 0
% Two bigger examples that can take longer.
startEnd(h, [5,6,1,3,2,4], [1,2,3,4,5,6]). % optimal cost: 8
startEnd(i, [5,4,3,1,2,7,6], [1,2,3,4,5,6,7]). % optimal cost: 7

% NOTE: In this clause (principal) neither _Path nor _Cost are used (they are
%       singleton variables), but our private *solution checker* uses them.
principal(Id) :-
    startEnd(Id, InitialState, FinalState),
    findPath(InitialState, FinalState, _Path, _Cost).

findPath(InitialState, FinalState, Path, Cost) :-
    nl, write('Solving: '),
    write(InitialState), write(' to '), write(FinalState), nl,
    length(FinalState, N), N2 is N*N,
    write('  Trying cost:'),
    between(0, N2, Cost), write(' '), write(Cost),
    computePath(Cost, InitialState, FinalState, [InitialState], Path),
    writeSolution(Cost, Path),
    !.

computePath(0, S, S, C, C).
computePath(Cost, State, FinalState, PathSoFar, TotalPath) :-
    Cost > 0,
    oneStep(CostStep, State, NextState),
    \+ member(NextState, PathSoFar),
    Cost1 is Cost - CostStep,
    computePath(Cost1, NextState, FinalState, [NextState|PathSoFar], TotalPath).

oneStep(CostStep, State, NextState) :-  % Queremos intercambiar X e Y
    append(U1, [Y|U0], State), % U1 es la lista de elementos antes de Y, Y es un elemento, U0 es la lista de elementos después de Y, State es la lista de elementos
    append(U3, [X|U2], U1), % U3 es la lista de elementos antes de X, X es un elemento, U2 es la lista de elementos después de X, U1 es la lista de elementos
    length(U2, L), % Ya que U2 es la lista de elementos después de X y antes de Y, por lo tanto es la distancia entre X e Y
    CostStep is L + 1, 
    V0 = U0, V2 = U2, V3 = U3,
    append(V3, [Y|V2], V1), % Volvemos a encadenar la lista con Y en la posición de X
    append(V1, [X|V0], NextState).

writeSolution(Cost, Path) :-
    nl, write('  Solution found at cost '), write(Cost),
    write(' with '), length(Path, L), L1 is L - 1, write(L1),
    (L1 =\= 1 -> write(' steps') ; write(' step')),
    nl, write('  Sequence of states: '), nl, writeSteps(Path).
    
writeSteps([]).
writeSteps([S|L]) :- writeSteps(L), write('    '), write(S), nl.
