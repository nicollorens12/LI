calcE(List1, List2, E) :-
    calcE_helper(List1, List2, 0, E).

calcE_helper([], [], E, E).

calcE_helper([Fx|Xs], [Fy|Ys], Acc, E) :-
    Fx \= Fy,
    calcE_helper(Xs, Ys, Acc, E).

calcE_helper([Fx|Xs], [Fx|Ys], Acc, E) :-
    Acc1 is Acc + 1,
    calcE_helper(Xs, Ys, Acc1, E).

eliminar_iguales([], [], [], []).
eliminar_iguales([X|Xs], [X|Ys], Rest1, Rest2) :-
    eliminar_iguales(Xs, Ys, Rest1, Rest2).
eliminar_iguales([X|Xs], [Y|Ys], [X|Rest1], [Y|Rest2]) :-
    X \= Y,
    eliminar_iguales(Xs, Ys, Rest1, Rest2).

contar_elementos([], _, 0).
contar_elementos([X|Xs], Ys, D) :-
    member(X, Ys), !,
    contar_elementos(Xs, Ys, D1),
    D is D1 + 1.
contar_elementos([_|Xs], Ys, D) :-
    contar_elementos(Xs, Ys, D).

calcD(List1, List2, D) :-
    eliminar_iguales(List1, List2, Rest1, Rest2),
    contar_elementos(Rest1, Rest2, D).

resposta([], [], 0, 0).
resposta(Lista1, Lista2, E, D) :-
    calcE(Lista1, Lista2, E),
    calcD(Lista1, Lista2, D).
