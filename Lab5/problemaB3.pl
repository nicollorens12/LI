main :- EstatInicial = [[1, 2, 5, 8], [], o],     EstatFinal = [[], [1, 2, 5, 8], f], 
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

unPas(C, [LOrigenPre, LFinalPre, o], [LOrigenPost, LFinalPost, f]):- % Movem una persona d'origen a final
    select(X, LOrigenPre, LOrigenPost),
    C is X,
    append([X], LFinalPre, TMP2),
    sort(TMP2, LFinalPost).

unPas(C, [LOrigenPre, LFinalPre, o], [LOrigenPost, LFinalPost, f]):- % Movem dues persona d'origen a final
    select(X, LOrigenPre, TMP),
    select(Y, TMP, LOrigenPost),
    C is max(X, Y),
    append([X, Y], LFinalPre, TMP2),
    sort(TMP2, LFinalPost).

unPas(C, [LOrigenPre, LFinalPre, f], [LOrigenPost, LFinalPost, o]):- % Movem una persona final a origen
    select(X, LFinalPre, LFinalPost),
    C is X,
    append([X], LOrigenPre, TMP2),
    sort(TMP2, LOrigenPost).
    
unPas(C, [LOrigenPre, LFinalPre, f], [LOrigenPost, LFinalPost, o]):- % Movem dues persona final a origen
    select(X, LFinalPre, TMP),
    select(Y, TMP, LFinalPost),
    C is max(X, Y),
    append([X, Y], LOrigenPre, TMP2),
    sort(TMP2, LOrigenPost).