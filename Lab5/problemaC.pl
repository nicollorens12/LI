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

resposta(Lista1, Lista2, E, D) :-
    calcE(Lista1, Lista2, E),
    calcD(Lista1, Lista2, D).

intents([ [ [v,b,g,l], [1,1] ], [ [m,t,g,l], [1,0] ], [ [g,l,g,l], [0,0] ], [ [v,b,m,m], [1,1] ], [ [v,t,b,t], [2,2] ]]).


consistent_with_attempt(Guess, [Attempt, [E, D]]) :-
    resposta(Guess, Attempt, E1, D1),
    E1 =:= E,
    D1 =:= D.

consistent_with_all_attempts(_, []).
consistent_with_all_attempts(Guess, [Attempt|Rest]) :-
    consistent_with_attempt(Guess, Attempt),
    consistent_with_all_attempts(Guess, Rest).

color(v).
color(b). 
color(g).
color(l).
color(m).
color(t).

generate_guess([A, B, C, D]) :-
    color(A), color(B), color(C), color(D).

nouIntent(Guess) :-
    intents(HistoricalAttempts),
    generate_guess(Guess),
    consistent_with_all_attempts(Guess, HistoricalAttempts).







