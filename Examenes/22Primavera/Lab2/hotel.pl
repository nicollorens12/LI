%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To use this prolog template for other optimization problems, replace the code parts 1,2,3,4 below. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
symbolicOutput(0).  % set to 1 for debugging: to see symbolic output only; 0 otherwise.
    

%% =================================================================================================================
%% Complete the prolog code below to use a SAT solver for solving the following problem.
%% We want to assign N gangsters, numbered from 1 to N, to rooms in a hotel with (individual) rooms.
%% We know the list of pairs of neighbouring rooms, and also the list of pairs of "enemy" gangsters.
%% Two enemies should of course not have neighboring rooms, so it may not be possible to accommodate all gangsters.
%% Gangsters are ordered by importance, gangster number 1 being the most important one, etc., so rooms
%% are assigned by this order: a gangster gets a room only if all more important gangsters also have one.
%% Our aim is to minimize the number NumUnAssigned of gangsters without a room.
%% Note that this is equivalent to maximizing the value NumAssigned such that exactly
%% the gangsters 1,2,...,NumAssigned have a room, where NumUnAssigned is N-NumAssigned).
%%
%% =======================================================================================


%%%===  Example input:

numRooms(22).
numGangsters(20).

% rooms 1 and 3 are neighboring, rooms 1 and 5 too, etc.
neighborRooms([1-3,1-5,1-6,1-10,1-11,1-12,1-16,1-19,2-3,2-11,2-16,2-17,2-18,2-22,3-4,3-5,3-8,3-9,3-13,3-14,3-15,3-16,3-18,3-19,3-20,4-5,4-8,4-11,4-13,4-15,4-18,4-19,4-20,4-22,5-13,5-15,5-16,5-19,6-7,6-9,6-10,6-13,6-16,6-20,6-21,7-10,7-12,7-13,7-18,7-20,8-9,8-10,8-12,8-14,8-15,8-19,9-18,9-19,9-22,10-11,10-14,10-16,10-17,10-18,10-19,10-21,10-22,11-12,11-14,11-16,11-20,12-14,12-17,12-20,12-21,12-22,13-14,13-16,13-17,13-18,13-19,13-22,14-15,14-16,14-17,14-19,14-20,14-22,15-16,15-17,15-18,15-19,15-20,15-21,15-22,16-17,16-18,16-19,16-20,16-21,16-22,17-18,17-19,17-20,17-21,17-22,18-19,18-20,18-21,18-22,19-20,19-21,19-22,20-21,20-22,21-22]).


% gangsters 1 and 2 are enemies, gangsters 1 and 4 too, etc.
enemies([1-2,1-4,1-5,1-6,1-9,1-10,1-12,1-15,1-17,1-18,2-9,2-14,2-15,2-16,3-4,3-5,3-8,3-13,3-14,4-5,4-6,4-7,4-13,4-18,4-19,4-20,5-9,5-10,5-11,5-13,5-15,5-18,6-7,6-8,6-9,6-10,6-14,6-15,6-16,6-17,6-18,6-20,7-10,7-11,7-12,7-15,7-16,7-18,7-19,8-11,8-12,8-13,8-15,8-16,8-17,8-19,9-10,9-11,10-11,10-14,10-15,10-16,10-18,10-19,10-20,11-12,11-14,11-16,11-17,11-18,11-19,11-20,12-13,12-14,12-15,12-16,14-19,14-20,15-16,15-17,15-18,15-19,16-18,16-19,17-18,17-19,17-20,18-19,18-20,19-20]).

%%%=== end input.



%%%%%% Some helpful definitions to make the code cleaner:

gangster(G):- numGangsters(N),  between(1,N,G).
room(R):-     numRooms(M),      between(1,M,R).

enemies(G1,G2):-       enemies(L),        member(G1-G2,L).
enemies(G2,G1):-       enemies(L),        member(G1-G2,L).

neighborRooms(R1,R2):- neighborRooms(L),  member(R1-R2,L).
neighborRooms(R2,R1):- neighborRooms(L),  member(R1-R2,L).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1.- Declare SAT variables to be used

satVariable( gr(G,R) ):- gangster(G), room(R).  % means "gangster G is in room R".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. This predicate writeClauses(MaxCost) generates the clauses that guarantee that
%    a solution with cost at most MaxCost is found


%% HINT: Use NO cardinality constraints atLeast(K,..), atMost(K,..), or exactly(K,...) with K>1  !!


writeClauses(infinite):- !, numGangsters(N), NumUnAssigned is N-1, writeClauses(NumUnAssigned),!.
writeClauses(NumUnAssigned):-
    numGangsters(N), NumAssigned is N - NumUnAssigned,
    exactlyOneRoomPerGangster(NumAssigned),
    atMostOneGangsterPerRoom(NumAssigned),
    noEnemiesOnNeighborRoom(NumAssigned),
    true,!.                    % this way you can comment out ANY previous line of writeClauses
writeClauses:- told, nl, write('writeClauses failed!'), nl,nl, halt.

exactlyOneRoomPerGangster(NumAssigned):-
        gangster(G), G =< NumAssigned,
        findall(gr(G,R),room(R),Lits),
        exactly(1,Lits),
        fail.
exactlyOneRoomPerGangster(_).

atMostOneGangsterPerRoom(NumAssigned):-
    room(R), findall( gr(G,R), (gangster(G), G=< NumAssigned), Lits ), atMost(1,Lits), fail.
atMostOneGangsterPerRoom(_).

noEnemiesOnNeighborRoom(NumAssigned):-
        enemies(G1,G2), G1 =< NumAssigned, G2 =< NumAssigned,
        neighborRooms(R1,R2),
        writeOneClause([-gr(G1,R1),gr(G2,R2)]),
        fail.
noEnemiesOnNeighborRoom.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. This predicate displays a given solution M:

% displaySol(M):- nl,write(M),nl,nl,fail.
displaySol(M):- gangster(G1), member(gr(G1,R1),M),
		gangster(G2), member(gr(G2,R2),M),
		enemies(G1,G2),
		neighborRooms(R1,R2),
		write('ERROR!'), nl,
		write('Gangster '), write2(G1), write(' is in room '), write2(R1), nl,
		write('Gangster '), write2(G2), write(' is in room '), write2(R2), nl,
		write(' which are enemies in neighboring rooms!!! '), nl,nl, halt.
displaySol(M):- gangster(G),  write('Gangster '), write2(G), write(' is in room '), writeRoom(G,M), nl, fail.
displaySol(_):- nl,nl.

writeRoom(G,M):- member(gr(G,R),M), write2(R),!.
writeRoom(_,_):- write('--'),!.

write2(N):- N < 10, !, write(' '), write(N),!.
write2(N):- write(N),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. This predicate computes the cost of a given solution M:

costOfThisSolution(M,Cost):-
        findall(G-R, member(gr(G,R),M),AssignedGangsters),
        length(NumAssignedGngsters,AssignedGangsters), numGangsters(N),
        Cost is N - NumAssignedGngsters.


%%%%%% ========================================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Everything below is given as a standard library, reusable for solving
%%    with SAT many different problems.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% Cardinality constraints on arbitrary sets of literals Lits: ===========================

exactly(K,Lits):- symbolicOutput(1), write( exactly(K,Lits) ), nl, !.
exactly(K,Lits):- atLeast(K,Lits), atMost(K,Lits),!.

atMost(K,Lits):- symbolicOutput(1), write( atMost(K,Lits) ), nl, !.
atMost(K,Lits):-   % l1+...+ln <= k:  in all subsets of size k+1, at least one is false:
      negateAll(Lits,NLits),
      K1 is K+1,    subsetOfSize(K1,NLits,Clause), writeOneClause(Clause),fail.
atMost(_,_).

atLeast(K,Lits):- symbolicOutput(1), write( atLeast(K,Lits) ), nl, !.
atLeast(K,Lits):-  % l1+...+ln >= k: in all subsets of size n-k+1, at least one is true:
      length(Lits,N),
      K1 is N-K+1,  subsetOfSize(K1, Lits,Clause), writeOneClause(Clause),fail.
atLeast(_,_).

negateAll( [], [] ).
negateAll( [Lit|Lits], [NLit|NLits] ):- negate(Lit,NLit), negateAll( Lits, NLits ),!.

negate( -Var,  Var):-!.
negate(  Var, -Var):-!.

subsetOfSize(0,_,[]):-!.
subsetOfSize(N,[X|L],[X|S]):- N1 is N-1, length(L,Leng), Leng>=N1, subsetOfSize(N1,L,S).
subsetOfSize(N,[_|L],   S ):-            length(L,Leng), Leng>=N,  subsetOfSize( N,L,S).


%%%%%%% Express equivalence between a variable and a disjunction or conjunction of literals ===

% Express that Var is equivalent to the disjunction of Lits:
expressOr( Var, Lits ):- symbolicOutput(1), write( Var ), write(' <--> or('), write(Lits), write(')'), nl, !.
expressOr( Var, Lits ):- member(Lit,Lits), negate(Lit,NLit), writeOneClause([ NLit, Var ]), fail.
expressOr( Var, Lits ):- negate(Var,NVar), writeOneClause([ NVar | Lits ]),!.

%% expressOr(a,[x,y]) genera 3 clausulas (como en la Transformación de Tseitin):
%% a == x v y
%% x -> a       -x v a
%% y -> a       -y v a
%% a -> x v y   -a v x v y

% Express that Var is equivalent to the conjunction of Lits:
expressAnd( Var, Lits) :- symbolicOutput(1), write( Var ), write(' <--> and('), write(Lits), write(')'), nl, !.
expressAnd( Var, Lits):- member(Lit,Lits), negate(Var,NVar), writeOneClause([ NVar, Lit ]), fail.
expressAnd( Var, Lits):- findall(NLit, (member(Lit,Lits), negate(Lit,NLit)), NLits), writeOneClause([ Var | NLits]), !.


%%%%%%% main: =================================================================================

main:-  symbolicOutput(1), !, writeClauses(infinite), halt.   % print the clauses in symbolic form and halt
main:-
        told, write('Looking for initial solution with arbitrary cost...'), nl,
        initClauseGeneration,
        tell(clauses), writeClauses(infinite), told,
        tell(header),  writeHeader, told,
        numVars(N), numClauses(C),
        write('Generated '), write(C), write(' clauses over '), write(N), write(' variables. '),nl,
        shell('cat header clauses > infile.cnf',_),
        write('Launching kissat...'), nl,
        shell('kissat -v infile.cnf > model', Result),  % if sat: Result=10; if unsat: Result=20.
        treatResult(Result,[]),!.

treatResult(20,[]       ):- write('No solution exists.'), nl, halt.
treatResult(20,BestModel):-
        nl,costOfThisSolution(BestModel,Cost), write('Unsatisfiable. So the optimal solution was this one with cost '),
        write(Cost), write(':'), nl, displaySol(BestModel), nl,nl,halt.
treatResult(10,_):- %   shell('cat model',_),
        nl,write('Solution found '), flush_output,
        see(model), symbolicModel(M), seen,
        costOfThisSolution(M,Cost),
        write('with cost '), write(Cost), nl,nl,
        displaySol(M), 
        Cost1 is Cost-1,   nl,nl,nl,nl,nl,  write('Now looking for solution with cost '), write(Cost1), write('...'), nl,
        initClauseGeneration, tell(clauses), writeClauses(Cost1), told,
        tell(header),  writeHeader,  told,
        numVars(N),numClauses(C),
        write('Generated '), write(C), write(' clauses over '), write(N), write(' variables. '),nl,
        shell('cat header clauses > infile.cnf',_),
        write('Launching kissat...'), nl,
        shell('kissat -v infile.cnf > model', Result),  % if sat: Result=10; if unsat: Result=20.
        treatResult(Result,M),!.
treatResult(_,_):- write('cnf input error. Wrote something strange in your cnf?'), nl,nl, halt.


initClauseGeneration:-  %initialize all info about variables and clauses:
        retractall(numClauses(   _)),
        retractall(numVars(      _)),
        retractall(varNumber(_,_,_)),
        assert(numClauses( 0 )),
        assert(numVars(    0 )),     !.

writeOneClause([]):- symbolicOutput(1),!, nl.
writeOneClause([]):- countClause, write(0), nl.
writeOneClause([Lit|C]):- w(Lit), writeOneClause(C),!.
w(-Var):- symbolicOutput(1), satVariable(Var), write(-Var), write(' '),!.
w( Var):- symbolicOutput(1), satVariable(Var), write( Var), write(' '),!.
w(-Var):- satVariable(Var),  var2num(Var,N),   write(-), write(N), write(' '),!.
w( Var):- satVariable(Var),  var2num(Var,N),             write(N), write(' '),!.
w( Lit):- told, write('ERROR: generating clause with undeclared variable in literal '), write(Lit), nl,nl, halt.


% given the symbolic variable V, find its variable number N in the SAT solver:
:-dynamic(varNumber / 3).
var2num(V,N):- hash_term(V,Key), existsOrCreate(V,Key,N),!.
existsOrCreate(V,Key,N):- varNumber(Key,V,N),!.                            % V already existed with num N
existsOrCreate(V,Key,N):- newVarNumber(N), assert(varNumber(Key,V,N)), !.  % otherwise, introduce new N for V

writeHeader:- numVars(N),numClauses(C), write('p cnf '),write(N), write(' '),write(C),nl.

countClause:-     retract( numClauses(N0) ), N is N0+1, assert( numClauses(N) ),!.
newVarNumber(N):- retract( numVars(   N0) ), N is N0+1, assert(    numVars(N) ),!.

% Getting the symbolic model M from the output file:
symbolicModel(M):- get_code(Char), readWord(Char,W), symbolicModel(M1), addIfPositiveInt(W,M1,M),!.
symbolicModel([]).
addIfPositiveInt(W,L,[Var|L]):- W = [C|_], between(48,57,C), number_codes(N,W), N>0, varNumber(_,Var,N),!.
addIfPositiveInt(_,L,L).
readWord( 99,W):- repeat, get_code(Ch), member(Ch,[-1,10]), !, get_code(Ch1), readWord(Ch1,W),!. % skip line starting w/ c
readWord(115,W):- repeat, get_code(Ch), member(Ch,[-1,10]), !, get_code(Ch1), readWord(Ch1,W),!. % skip line starting w/ s
readWord(-1,_):-!, fail. %end of file
readWord(C,[]):- member(C,[10,32]), !. % newline or white space marks end of word
readWord(Char,[Char|W]):- get_code(Char1), readWord(Char1,W), !.

%%%%%%% =======================================================================================

