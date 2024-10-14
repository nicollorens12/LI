main:- 
        EstadoInicial = [0, 0],
        EstadoFinal = [0, 4],
        between(1,1000,CosteMax),
        camino( CosteMax, EstadoInicial, EstadoFinal, [EstadoInicial], Camino ),
        reverse(Camino, Camino1), write(Camino1), write(" con coste "), write(CosteMax), nl, halt.

camino( 0, E,E, C,C ).              % Caso base: cuando el estado actual es el estado final.
camino( CosteMax, EstadoActual, EstadoFinal, CaminoHastaAhora, CaminoTotal ):-
    CosteMax>0,
    unPaso( CostePaso, EstadoActual, EstadoSiguiente ),  % En B.1 y B.2, CostePaso es 1.
    \+member( EstadoSiguiente, CaminoHastaAhora ),
    CosteMax1 is CosteMax-CostePaso,
    camino( CosteMax1, EstadoSiguiente, EstadoFinal, [EstadoSiguiente|CaminoHastaAhora], CaminoTotal ).


unPaso(1, [_, Y], [5, Y]).
unPaso(1, [X, _], [X, 8]).
unPaso(1, [_, Y], [0, Y]).
unPaso(1, [X, _], [X, 0]).

unPaso(1, [X1, Y1], [X2, Y2]) :-
    Y2 is min((Y1 + X1), 8),
    X2 is X1 - (Y2 - Y1).

unPaso(1, [X1, Y1], [X2, Y2]) :-
    X2 is min((X1 + Y1), 5),
    Y2 is Y1 - (X2 - X1).