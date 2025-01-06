%% --------- [4 points] ---------- %%

symbolicOutput(0).  % set to 1 for DEBUGGING: to see symbolic output only; 0 otherwise.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To use this prolog template for other optimization problems, replace the code parts 1,2,3,4 below. %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extend this Prolog source for designing a "speed dating" event.
%% We have a list of couples of potential partners, who must meet in 7-minute slots.
%% This is NOT a one-on-one dating, where every participant meets each other.
%% There is a maximum number of tables where to hold meetings (numTables),
%% and an initial maximum time to complete all dates (maxSlots).
%% Additional restrictions:
%% * participants must "rest" after some number of consecutive dates
%% * some participants are considered VIPs. No date between two VIP participants
%%   can occur after a date between two non-VIP participants.
%% The aim is to minimize the number of slots needed to complete all dates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% Begin example input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maxSlots(15).    % maxim number of (7-minute) slots
numTables(4).
maxConsecutiveDates(3).
vips([a,c,e,j,k]).
date(a-b).
date(a-c).
date(a-f).
date(a-h).
date(b-c).
date(b-d).
date(b-e).
date(b-h).
date(b-i).
date(c-e).
date(c-h).
date(c-i).
date(c-k).
date(d-e).
date(d-g).
date(d-i).
date(d-j).
date(e-g).
date(f-h).
date(g-h).
date(h-i).
date(h-k).
date(j-k).

%% OPTIMAL SOLUTIONS REQUIRE 9 SLOTS (COST=9)

%%%%%%% End example input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% Some helpful definitions to make the code cleaner: ====================================

participant(P):- findall(P, (date(P-_);date(_-P)) , LP), sort(LP, LPs), member(P, LPs).
slot(S):- maxSlots(N), between(1,N,S).
shareParticipant(P-P2, P-P4) :- P2 \= P4, !.
shareParticipant(P-P2, P3-P) :- P2 \= P3, !.
shareParticipant(P1-P, P-P4) :- P1 \= P4, !.
shareParticipant(P1-P, P3-P) :- P1 \= P3, !.
kConsecutiveSlots(MaxSlots,K,LS):- SMaxStart is MaxSlots-K+1, between(1,SMaxStart,SStart),
				  findall(X, (between(1,K,Pos), X is SStart+Pos-1), LS).

%%%%%%% End helpful definitions ===============================================================


%%%%%%%  1. Declare SAT variables to be used: =================================================

satVariable( pps(P1-P2,S) ) :- date(P1-P2), slot(S).     %% the date P1-P2 takes place at slot S
satVariable( ps(P,S) )      :- participant(P), slot(S).  %% the participant P has a date at slot S

%%%%%%%  2. Clause generation for the SAT solver: =============================================

% This predicate writeClauses(MaxCost) generates the clauses that guarantee that
% a solution with cost at most MaxCost is found

writeClauses(infinite):- !, maxSlots(N), writeClauses(N), !.
writeClauses(MaxSlots):-
    eachDateExactlyOneSlot(MaxSlots),
    noIncompatibleDatesAtSameSlot(MaxSlots),
    relatePSwithPPS(MaxSlots),
    restEveryKConsecutiveDates(MaxSlots),
    maxDatesAtTheSameSlot(MaxSlots),
    betweenVipsBefore(MaxSlots),
    true,!.
writeClauses(_):- told, nl, write('writeClauses failed!'), nl,nl, halt.

eachDateExactlyOneSlot(MaxSlots):- date(P1-P2), findall(pps(P1-P2,S), (slot(S), between(1,MaxSlots,S)), Lits), exactly(1, Lits), fail.
eachDateExactlyOneSlot(_).

noIncompatibleDatesAtSameSlot(MaxSlots):- 
        date(P1-P2), date(P3-P4),
        
        , fail.
noIncompatibleDatesAtSameSlot(_).

%% pps(P1-P2,S) the date P1-P2 takes place at slot S
%% ps(P,S) ) the participant P has a date at slot S
relatePSwithPPS(MaxSlots):-

        ,fail.
relatePSwithPPS(_).

restEveryKConsecutiveDates(MaxSlots):- maxConsecutiveDates(K), K1 is K+1, ..., fail.
restEveryKConsecutiveDates(_).

maxDatesAtTheSameSlot(MaxSlots):- ..., fail.
maxDatesAtTheSameSlot(_).

betweenVipsBefore(MaxSlots):- ..., fail.
betweenVipsBefore(_).


%%%%%%%  3. DisplaySol: this predicate displays a given solution M: ===========================

%displaySol(M):- nl, write(M), nl, nl, fail.
displaySol(M):- slot(S), nl, write(S), write(':\t'), displaySlot(S,M), fail.
displaySol(M):- nl, participant(P), nl, write(P), write(':\t'), displayPart(P,M), fail.
displaySol(_):- nl,!.

displaySlot(S,M):- date(P1-P2), member(pps(P1-P2,S), M), write(P1-P2), write(' '), fail.
displaySlot(_,_).

displayPart(P,M):- slot(S), (member(pps(P-P1,S),M),write(P-P1);member(pps(P1-P,S),M),write(P1-P)), write([S]), write('  '), fail.
displayPart(_,_).

%%%%%%%  4. This predicate computes the cost of a given solution M: ===========================

costOfThisSolution(M,Cost):- ...


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

