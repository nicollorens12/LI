%% --------- [2.5 points] ---------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remember that the Fibonacci sequence is defined as F(1) = 1, F(2) = 1, and
% F(N) = F(N-1) + F(N-2) for any N >= 3. Write the following predicates taking
% into account that they should run fast for values of N up to 1000:
%
% 1. fibo(N,K), that, given a natural number N, is true if F(N) = K.
%
% 2. fiboList(N,L), that, given a natural number N, holds if L is the list of all
% Fibonacci numbers F(1), F(2), ..., F(N) in this order.
% For example, fiboList(6, [1,1,2,3,5,8]) should hold,
% but not fiboList(6, [8,5,3,2,1,1]).
%
% 3. main(N), that, given a natural number N, writes the sequence of all
% Fibonacci numbers up to F(N) in consecutive lines.
% For example, main(6) should write:
%
% F(1) = 1
% F(2) = 1
% F(3) = 2
% F(4) = 3
% F(5) = 5
% F(6) = 8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fibo(N,K) :-
 fiboList(N,L),
 nth1(N,L,K).
fiboList(1,[1] ) :- !.
fiboList(2,[1,1]) :- !.
fiboList(N,L) :-
 N1 is N-1,
 fiboList(N1,L1),
 length(L1,K),
 K1 is K-1,
 K2 is K-2,
 nth0(K1,L1,E1),
 nth0(K2,L1,E2),
 Sum is E1+E2,
 append(L1,[Sum],L).

main(N):-
 fiboList(N,L),
 between(1,N,K),
 nth1(K,L,F), write('F('), write(K), write(') = '), write(F), nl, fail.
main(_).