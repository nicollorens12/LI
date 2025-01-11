%% --------- [3 points] ---------- %%

%% For given naturals n and m,
%% a *Golomb ruler* of order n and length m
%% is a set of n natural numbers t1 < ... < tn such that m = tn - t1
%% and no two different pairs of numbers in the set are the same distance apart.

%% For example, [0, 1, 4, 6] is a Golomb ruler of order 4 and length 6.
%% The distances between all different pairs of numbers are:
%% 1 - 0 = 1
%% 4 - 0 = 4
%% 6 - 0 = 6
%% 4 - 1 = 3
%% 6 - 1 = 5
%% 6 - 4 = 2
%% Indeed, no two different pairs of numbers are the same distance apart.

%% Extend this Prolog source so that, given naturals N and M, predicate golomb(N, M)
%% writes a Golomb ruler of order N and length M, if there is one.

%% For example:
%% ?- golomb(4, 6), fail.
%% [0,1,4,6]
%% [0,2,5,6]
%% false.

%% ?- golomb(5, 11), fail.
%% [0,1,4,9,11]
%% [0,2,7,8,11]
%% [0,2,7,10,11]
%% [0,3,4,9,11]
%% false.

%% Hint: define and use predicates
%%
%%    o increasing(L): given a list L of variables, 
%%                     it posts the constraints expressing that 
%%                     the values in the list should be strictly increasing.
%%
%%    o diff(LP, LV):  given a list LP of pairs of different pairs of indices
%%                     [I, J] and [K, L] and a list of variables LV such that the values of I,J,K,L are in 1..len(LV),
%%                     for each element of LP it posts the constraints that 
%%                     the distance between the values assigned to the I-th and J-th variables 
%%                     is different from 
%%                     the distance between the values assigned to the K-th and L-th variables.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- use_module(library(clpfd)).

golomb(N, M) :-
    length(V, N),
    V ins ..., %% We can assume wlog t1 = 0, tn = m
    ...
    label(V),
    write(V), nl.

...
