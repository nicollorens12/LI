%% ----------- [2.5 points] ---------- %%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define a predicate rotate(L,K,T) that, given a list L and an integer K, is true
% when T is the K-rotation of L. The K-rotation of a list L of length N is the list
% starting with the last K mod N elements of L followed by the rest of elements of L
% in the same order. In particular, the 0-rotation of a list L is the same list L.
% For example, both rotate([a,b,c,d,e],2,[d,e,a,b,c]), and rotate([a,b,c,d,e],-2,[c,d,e,a,b])
% should be true. Instead, rotate([a,b,c,d,e],2,[a,a,a]) should be false.
%
% Using rotate(L,K,T), also define a predicate periodic(L) that, given a list L with N elements, 
% is true when some K-rotation of L, for 0 < K < N, equals L. For example,
% periodic([a,b,a,b,a,b]) should be true (K=2), and periodic([a,b,a,b,a]) should not.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rotate(+L,+K,?T) holds if
%    T is the K-rotation of L
rotate(L,K,T) :-
    length(L,N),
    D is (K mod N),
    append(L1,L2,L),
    length(L2,D),
    append(L2,L1,T).


% periodic(+L) holds if
%    L equals some K-rotation of L, with 0 < K < N, where N is the length of L
periodic(L) :-
    length(L,N),
    N1 is N-1,
    between(1,N1,K),
    rotate(L,K,L).
