%% --------- [2.5 points] ---------- %%
% compact(+L1, -L2) holds if the list L2 is the "compacted" version of the list L1,
% as explained in the following examples:
%
% ?- compact([a,a,b,b,b,a,a,a],L).
% L = [a-2, b-3, a-3]. % Note that only CONSECUTIVE EQUAL elements
% % are "compacted"
% ?- compact([a,a,b,a,c,c],L).
% L = [a-2, b, a, c-2]. % Note that SINGLE APPEARANCES of elements X
% % are NOT compacted to X-1, but simply to X.
compact([X], [X] ) :- !.
compact([X,X|L], [X-2|LC]) :- compact([X|L],[X|LC]), !.
compact([X,X|L], [X-N|LC]) :- compact([X|L],[X-N1|LC]), N is N1+1, !.
compact([X,Y|L], [X |LC]) :- X \= Y, compact([Y|L],LC), !.
