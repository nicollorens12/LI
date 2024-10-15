:- use_module(library(clpfd)).

exemple( 0,  26, [1,2,5,10]           ).  % Solució: [1,0,1,2]
exemple( 1, 361, [1,2,5,13,17,35,157] ).

main :- 
    exemple(0, Amount, Coins),
    nl, write('Paying amount '), write(Amount), write(' using the minimal number of coins of values '), write(Coins), nl, nl,

%1: Variables i dominis:
    length(Coins, N), 
    length(Vars,  N),           % obté una llista de N variables prolog
    ...

%2: Constraints:
    ...

%3: Labeling:
    ...

%4: Escrivim el resultat:
    ...
    nl, write(Vars), nl, nl, halt.
