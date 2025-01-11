camino( 0, _, _, E,E, C,C ). % Caso base: cuando el estado actual es el estado final.
camino( CosteMax, N, P, EstadoActual, EstadoFinal, CaminoHastaAhora, CaminoTotal ) :-
    CosteMax > 0,
    CosteMax < P,
    unPaso( CostePaso, N, EstadoActual, EstadoSiguiente ), % En B.1 y B.2, CostePaso es 1.
    \+ member( EstadoSiguiente, CaminoHastaAhora ),
    CosteMax1 is CosteMax-CostePaso,
    camino(CosteMax1, N,P ,EstadoSiguiente, EstadoFinal, [EstadoSiguiente|CaminoHastaAhora], CaminoTotal).

main:- EstadoInicial = [0,0], EstadoFinal = [8,8], N = 8, P = 100, between(1, 1000, CosteMax), % Buscamos solucion de coste 0; si no, de 1, etc.
    camino( CosteMax, N, P, EstadoInicial, EstadoFinal, [EstadoInicial], Camino ),
    reverse(Camino, Camino1), write(Camino1), write('con coste'), write(CosteMax), nl, halt. 
    
isCorrect(N,NextX,NextY):-
    NextX >= 0, NextX =< N,
    NextY >= 0, NextY =< N.


unPaso(1, N, [X,Y], [NextX, NextY]):-
    member([JumpX,JumpY],[[1,2],[-1,2],[-2,1],[-2,-1],[2,1],[2,-1],[-1,-2],[1,-2]]),
    NextX is JumpX + X,
    NextY is JumpY + Y,
    isCorrect(N,NextX,NextY).