main :- EstatInicial = [3,3,0,0],    EstatFinal = [0,0,3,3],
        between(1, 1000, CostMax),                  % Busquem solució de cost 0; si no, de 1, etc.
        cami(CostMax, EstatInicial, EstatFinal, [EstatInicial], Cami),
        reverse(Cami, Cami1), write(Cami1), write(' amb cost '), write(CostMax), nl, halt.

cami(0, E, E, C, C).                                % Cas base: quan l'estat actual és l'estat final.
cami(CostMax, EstatActual, EstatFinal, CamiFinsAra, CamiTotal) :-
        CostMax > 0, 
        unPas(CostPas, EstatActual, EstatSeguent),  % En B.1 i B.2, CostPas és 1.
        \+ member(EstatSeguent, CamiFinsAra),
        CostMax1 is CostMax-CostPas,
        cami(CostMax1, EstatSeguent, EstatFinal, [EstatSeguent|CamiFinsAra], CamiTotal).

unPas(1,[C1,M1,C2,M2],[C1a,M1a,C2a,M2a]) :-               %Un de cada a la banda 2
        C1 > 0, M1 > 0,
        C1a is C1-1, M1a is M1-1,
        C2a is C2+1, M2a is M2+1.

unPas(1,[C1,M1,C2,M2],[C1a,M1,C2a,M2]) :-               %Dos canibals a la banda 2
        C1 > 1,
        C1a is C1-2,
        C2a is C2+2,
        C2a =< M2.

unPas(1,[C1,M1,C2,M2],[C1,M1a,C2,M2a]) :-               %Dos misioners a la banda 2
        M1 > 1,
        M1a is M1-2,
        M2a is M2+2,
        M1a >= C1.

unPas(1,[C1,M1,C2,M2],[C1a,M1a,C2a,M2a]) :-               %Un de cada a la banda 1
        M2 > 0, C2 > 0,
        M1a is M1+1, C1a is C1+1,
        M2a is M2-1, C2a is C2-1.

unPas(1,[C1,M1,C2,M2],[C1a,M1,C2a,M2]) :-               %Dos canibales a la banda 1
        C2 > 1,
        C2a is C2-2,
        C1a is C1+2,
        C1a =< M1.

unPas(1,[C1,M1,C2,M2],[C1,M1a,C2,M2a]) :-               %Dos misioneros a la banda 1
        M2 > 1,
        M2a is M2-2,
        M1a is M1+2,
        M1a >= C1.
