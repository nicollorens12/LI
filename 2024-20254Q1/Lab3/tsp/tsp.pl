%% Complete the following program to compute one such a route.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% begin input example tsp1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% maxCost(10).
%% numCities(20).
%%
%% adjacency(1,[10]).
%% adjacency(2,[7,5,17]).  % Three one-way roads from city 2:  2->7, 2->5 and 2->17.
%% adjacency(3,[6,20,11]).
%% adjacency(4,[14,15,1,8,5]).
%% adjacency(5,[16,4,9,10,11]).
%% adjacency(6,[1,13,17]).
%% adjacency(7,[16,9,13,11]).
%% adjacency(8,[7,3,10,6,17]).
%% adjacency(9,[6,17,11]).
%% adjacency(10,[7,11,5,6,4]).
%% adjacency(11,[20,8,15,4,1,16,3]).
%% adjacency(12,[15,11,3]).
%% adjacency(13,[5,2,19,3,6]).
%% adjacency(14,[10,12,9,7]).
%% adjacency(15,[20,1,14,18,12,2]).
%% adjacency(16,[7,6,4,8,2,10]).
%% adjacency(17,[20,5,16,3,8]).
%% adjacency(18,[15,16,7,14,3]).
%% adjacency(19,[13,6]).
%% adjacency(20,[12,6,18,7,16]).
%%
%%%%%%% end input example tsp1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% Some helpful definitions to make the code cleaner: ====================================

position(P) :- numCities(N), between(0,N,P).
city(I) :-     adjacency(I,_).
isAdjacent(C1,C2):- adjacency(C1,A), member(C2,A).

%%%%%%% End helpful definitions ===============================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% We want to solve a modified version of the Traveling Salesman Problem:
%% given a map with some (possibly one-way) roads between N cities,
%% we want find a route starting and finishing in city 1 such that
%% each city is visited exactly once. Moreover, we want to find a
%% route with cost at most maxCost, considering that:
%%  -trajects between cities with the same parity have cost 0 euros
%%  -trajects between cities of different parity  have cost 1 euro
%% For example, the following solution has cost 10:
%%   1 10 4 8 3 20 18 14 12 11 15 2 5 9 17 16 7 13 19 6 1 
%%    ^      ^ ^           ^     ^ ^      ^  ^       ^ ^

symbolicOutput(0).  % set to 1 for DEBUGGING: to see symbolic output only; 0 otherwise.

%%%%%%%  1. SAT Variables: ====================================================================

satVariable( visited(I,P) ) :-  city(I), position(P). % visited(I,P) meaning "city I is visited in position P"
% Warning: more types of variables might be needed or convenient.


%%%%%%%  2. Clause generation for the SAT solver: =============================================

writeClauses :-
    startOneEndOne,
    allCitiesVisitedOnce,
    withNoRep,
    allValidRoutes,
    true, !.
writeClauses :- told, nl, write('writeClauses failed!'), nl, nl, halt.

startOneEndOne:-
        numCities(K),
        writeOneClause([visited(1,0)]),
        writeOneClause([visited(1,K)]),
        position(P), P =\= 0, P =\= K,
        writeOneClause([-visited(1,P)]),
        fail.
startOneEndOne.   

allCitiesVisitedOnce:-
        city(C),
        C =\= 1,
        numCities(K),
        findall(visited(C,P),(position(P), P =\= 0, P =\= K), Lits),
        exactly(1,Lits),
        fail.
allCitiesVisitedOnce.


withNoRep :- 
        position(P), position(Q),
        P =\= Q, city(I), I =\= 1,
        writeOneClause([-visited(I,P), -visited(I,Q)]),
        fail.
withNoRep.

allValidRoutes:-
        city(C),
        position(P),
        numCities(K),
        P < K,
        P1 is P+1,
        city(C1),isAdjacent(C,C1),
        writeOneClause([-visited(C,P),visited(C1,P1)]),
        fail.

allValidRoutes.




%%%%%%%  3. DisplaySol: show the solution. Here M contains the literals that are true in the model:

% displaySol(M) :- nl, write(M), nl, nl, fail.
displaySol(M) :- position(P), member(visited(City,P),M), write(City), write(' '), fail.
displaySol(_) :- nl.

%%%%%%% =======================================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Everything below is given as a standard library, reusable for solving
%%    with SAT many different problems.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% Cardinality constraints on arbitrary sets of literals Lits: ===========================

exactly(K,Lits) :- symbolicOutput(1), write( exactly(K,Lits) ), nl, !.
exactly(K,Lits) :- atLeast(K,Lits), atMost(K,Lits),!.

atMost(K,Lits) :- symbolicOutput(1), write( atMost(K,Lits) ), nl, !.
atMost(K,Lits) :-   % l1+...+ln <= k:  in all subsets of size k+1, at least one is false:
      negateAll(Lits,NLits),
      K1 is K+1,    subsetOfSize(K1,NLits,Clause), writeOneClause(Clause),fail.
atMost(_,_).

atLeast(K,Lits) :- symbolicOutput(1), write( atLeast(K,Lits) ), nl, !.
atLeast(K,Lits) :-  % l1+...+ln >= k: in all subsets of size n-k+1, at least one is true:
      length(Lits,N),
      K1 is N-K+1,  subsetOfSize(K1, Lits,Clause), writeOneClause(Clause),fail.
atLeast(_,_).

negateAll( [], [] ).
negateAll( [Lit|Lits], [NLit|NLits] ) :- negate(Lit,NLit), negateAll( Lits, NLits ),!.

negate( -Var,  Var) :- !.
negate(  Var, -Var) :- !.

subsetOfSize(0,_,[]) :- !.
subsetOfSize(N,[X|L],[X|S]) :- N1 is N-1, length(L,Leng), Leng>=N1, subsetOfSize(N1,L,S).
subsetOfSize(N,[_|L],   S ) :-            length(L,Leng), Leng>=N,  subsetOfSize( N,L,S).


%%%%%%% Express equivalence between a variable and a disjunction or conjunction of literals ===

% Express that Var is equivalent to the disjunction of Lits:
expressOr( Var, Lits ) :- symbolicOutput(1), write( Var ), write(' <--> or('), write(Lits), write(')'), nl, !.
expressOr( Var, Lits ) :- member(Lit,Lits), negate(Lit,NLit), writeOneClause([ NLit, Var ]), fail.
expressOr( Var, Lits ) :- negate(Var,NVar), writeOneClause([ NVar | Lits ]),!.

%% expressOr(a,[x,y]) genera 3 clausulas (como en la Transformación de Tseitin):
%% a == x v y
%% x -> a       -x v a
%% y -> a       -y v a
%% a -> x v y   -a v x v y

% Express that Var is equivalent to the conjunction of Lits:
expressAnd( Var, Lits) :- symbolicOutput(1), write( Var ), write(' <--> and('), write(Lits), write(')'), nl, !.
expressAnd( Var, Lits) :- member(Lit,Lits), negate(Var,NVar), writeOneClause([ NVar, Lit ]), fail.
expressAnd( Var, Lits) :- findall(NLit, (member(Lit,Lits), negate(Lit,NLit)), NLits), writeOneClause([ Var | NLits]), !.


%%%%%%% main: =================================================================================

main :- current_prolog_flag(os_argv, Argv),
        nth0(1, Argv, InputFile),
        main(InputFile), !.
main :-  write('Usage: $ ./<executable> <example>          or ?- main(<example>).'), nl, halt.

main(InputFile) :-
        symbolicOutput(1), !,
        consult(InputFile),
        writeClauses, halt.   % print the clauses in symbolic form and halt Prolog
main(InputFile) :-
        consult(InputFile),
        initClauseGeneration,
        tell(clauses), writeClauses, told,          % generate the (numeric) SAT clauses and call the solver
        tell(header),  writeHeader, told,
        numVars(N), numClauses(C),
        write('Generated '), write(C), write(' clauses over '), write(N), write(' variables. '),nl,
        shell('cat header clauses > infile.cnf',_),
        write('Calling solver....'), nl,
        shell('kissat -v infile.cnf > model', Result),  % if sat: Result=10; if unsat: Result=20.
        treatResult(Result),!.

treatResult(20) :- write('Unsatisfiable'), nl, halt.
treatResult(10) :- write('Solution found: '), nl, see(model), symbolicModel(M), seen, displaySol(M), nl,nl,halt.
treatResult( _) :- write('cnf input error. Wrote anything strange in your cnf?'), nl,nl, halt.


initClauseGeneration :-  %initialize all info about variables and clauses:
        retractall(numClauses(   _)),
        retractall(numVars(      _)),
        retractall(varNumber(_,_,_)),
        assert(numClauses( 0 )),
        assert(numVars(    0 )),     !.

writeOneClause([]) :- symbolicOutput(1),!, nl.
writeOneClause([]) :- countClause, write(0), nl.
writeOneClause([Lit|C]) :- w(Lit), writeOneClause(C),!.
w(-Var) :- symbolicOutput(1), satVariable(Var), write(-Var), write(' '),!.
w( Var) :- symbolicOutput(1), satVariable(Var), write( Var), write(' '),!.
w(-Var) :- satVariable(Var),  var2num(Var,N),   write(-), write(N), write(' '),!.
w( Var) :- satVariable(Var),  var2num(Var,N),             write(N), write(' '),!.
w( Lit) :- told, write('ERROR: generating clause with undeclared variable in literal '), write(Lit), nl,nl, halt.


% given the symbolic variable V, find its variable number N in the SAT solver:
:- dynamic(varNumber / 3).
var2num(V,N) :- hash_term(V,Key), existsOrCreate(V,Key,N),!.
existsOrCreate(V,Key,N) :- varNumber(Key,V,N),!.                            % V already existed with num N
existsOrCreate(V,Key,N) :- newVarNumber(N), assert(varNumber(Key,V,N)), !.  % otherwise, introduce new N for V

writeHeader :- numVars(N),numClauses(C), write('p cnf '),write(N), write(' '),write(C),nl.

countClause :-     retract( numClauses(N0) ), N is N0+1, assert( numClauses(N) ),!.
newVarNumber(N) :- retract( numVars(   N0) ), N is N0+1, assert(    numVars(N) ),!.

% Getting the symbolic model M from the output file:
symbolicModel(M) :- get_code(Char), readWord(Char,W), symbolicModel(M1), addIfPositiveInt(W,M1,M),!.
symbolicModel([]).
addIfPositiveInt(W,L,[Var|L]) :- W = [C|_], between(48,57,C), number_codes(N,W), N>0, varNumber(_,Var,N),!.
addIfPositiveInt(_,L,L).
readWord( 99,W) :- repeat, get_code(Ch), member(Ch,[-1,10]), !, get_code(Ch1), readWord(Ch1,W),!. % skip line starting w/ c
readWord(115,W) :- repeat, get_code(Ch), member(Ch,[-1,10]), !, get_code(Ch1), readWord(Ch1,W),!. % skip line starting w/ s
readWord( -1,_) :-!, fail. %end of file
readWord(C, []) :- member(C,[10,32]), !. % newline or white space marks end of word
readWord(Char,[Char|W]) :- get_code(Char1), readWord(Char1,W), !.

%%%%%%% =======================================================================================
