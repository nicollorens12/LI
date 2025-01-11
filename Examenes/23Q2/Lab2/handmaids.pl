%% --------- [4 points] ---------- %%

symbolicOutput(0).  % set to 1 for DEBUGGING: to see symbolic output only; 0 otherwise.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In a dystopian future, N handmaids walk to the supermarket in rows of K >= 3 
% every day for M consecutive days. As a security measure, they are arranged so
% that over the course of those M days, the largest number of days that any two
% handmaids can find themselves in the same row is minimized. 
% Additionally, some 'mandatory' groups of 3 handmaids should share a row someday 
% while other 'forbidden' groups of 3 should never share a row. 
% Find an optimal arrangement according to the rules. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% Example input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numHandmaids(18).    % N: number of handmaids (always a multiple of K)
rowSize(3).          % K: handmaids in a row    
numDays(7).          % M: number of days

% groups that should go in some row, some day
mandatory([[1,2,3],[2,3,4],[3,4,5],[4,5,6],[13,14,15],[14,15,16],[16,17,18]]).

% groups that never should go together in any row, any day
forbidden([[7,8,9],[10,11,12],[13,14,16],[1,6,11],[2,7,12],[3,8,13],[4,9,14],
           [5,10,15],[6,11,16],[7,12,17],[8,13,18]]).

% OPTIMAL SOLUTIONS HAVE 2 COINCIDENCES OF HANDMAIDS ON DIFFERENT DAYS (COST 2)

%%%%%%% Some helpful definitions to make the code cleaner: ====================================

handmaid(H):- numHandmaids(N), between(1,N,H).
row(R)     :- numHandmaids(N), rowSize(K), TotalRows is N//K, between(1,TotalRows,R).
day(D)     :- numDays(M), between(1,M,D).
maxCost(C) :- numDays(C).

%%%%%%% End helpful definitions ===============================================================


%%%%%%%  1. SAT Variables: ====================================================================

% hdr(H,D,R) means "on day D, handmaid H is in row R"
satVariable( hdr(H,D,R) ) :- handmaid(H), day(D), row(R).

% together(H1,H2,D,R) means "handmaids H1 and H2 share row R on day D"
satVariable( together(H1,H2,D,R) ) :- handmaid(H1), handmaid(H2), H1 < H2, day(D), row(R).

% coincide2(H1,H2,D) means "handmaids H1 and H2 coincide on day D on some row"
satVariable( coincide2(H1,H2,D) ) :- handmaid(H1), handmaid(H2), H1 < H2, day(D).

% coincide3(H1,H2,H3,D) means "handmaids H1, H2, and H3 coincide on day D on some row"
satVariable( coincide3(H1,H2,H3,D) ) :- handmaid(H1), handmaid(H2), handmaid(H3), 
                                        H1 < H2, H2 < H3, day(D).

%%%%%%%  2. Clause generation for the SAT solver: =============================================

writeClauses(infinite):- !, maxCost(C), writeClauses(C), !.
writeClauses(C) :-
    forEachDRexactlyKH,         % for each day and row there are exactly K handmaids
    forEachDHexactlyOneR,       % for each day and handmaid there is exactly one row
    forbiddenGroups,            % condition about forbidden groups
    relate_hdr_together,        % relate SAT variables hdr and together
    relate_together_coincide2,  % relate SAT variables together and coincide2
    maxCoincidences(C),         % this solution has at most C coincidences
    relate_coincide2_coincide3, % relate SAT variables coincide2 and coincide3
    mandatoryGroups,            % condition about mandatory groups
    true,!.
writeClauses(_) :- told, nl, write('writeClauses failed!'), nl, nl, halt.

forEachDRexactlyKH :-
    rowSize(K),
    day(D), row(R),
    findall(hdr(H,D,R),handmaid(H),L),
    exactly(K,L),
    fail.
forEachDRexactlyKH.

forEachDHexactlyOneR :-
    day(D), handmaid(H),
    findall(hdr(H,D,R), row(R), Lits),
    exactly(1,Lits),
    fail.
forEachDHexactlyOneR.

forbiddenGroups :-
    forbidden(L), member([H1,H2,H3],L), day(D),
    writeOneClause([-coincide3(H1,H2,H3,D)]),
    fail.
forbiddenGroups.

% hdr(H,D,R) means "on day D, handmaid H is in row R"
% together(H1,H2,D,R) means "handmaids H1 and H2 share row R on day D"
relate_hdr_together :-
    day(D), row(R),
    handmaid(H1), handmaid(H2), H1 < H2,
    writeOneClause([-hdr(H1,D,R),-hdr(H2,D,R),together(H1,H2,D,R)]),
    fail.
relate_hdr_together.

% together(H1,H2,D,R) means "handmaids H1 and H2 share row R on day D"
% coincide2(H1,H2,D) means "handmaids H1 and H2 coincide on day D on some row"
relate_together_coincide2 :-
    day(D),
    handmaid(H1), handmaid(H2), H1 < H2,
    row(R),
    writeOneClause([-together(H1,H2,D,R),coincide2(H1,H2,D)]),
    fail.
relate_together_coincide2.


% this solution has at most C coincidences
maxCoincidences(C) :-
    handmaid(H1), handmaid(H2), H1 < H2,
    findall(coincide2(H1,H2,D),day(D),Lits),
    atMost(C,Lits),
    fail.
maxCoincidences(_).

% coincide2(H1,H2,D) means "handmaids H1 and H2 coincide on day D on some row"
% coincide3(H1,H2,H3,D) means "handmaids H1, H2, and H3 coincide on day D on some row"
relate_coincide2_coincide3 :-
    day(D),
    handmaid(H1), handmaid(H2), handmaid(H3), H1 < H2, H2 < H3,
    writeOneClause([-coincide2(H1,H2,D),-coincide2(H2,H3,D),coincide3(H1,H2,H3,D)]),
    fail.
relate_coincide2_coincide3.

% condition about mandatory groups
% Additionally, some 'mandatory' groups of 3 handmaids should share a row someday 
% mandatory([[1,2,3],[2,3,4],[3,4,5],[4,5,6],[13,14,15],[14,15,16],[16,17,18]]).
mandatoryGroups :-
    mandatory(L1), member([H1,H2,H3],L1),
    findall(coincide3(H1,H2,H3,D),day(D),L2),
    atLeast(1,L2),
    fail.
mandatoryGroups.


%%%%%%%  3. DisplaySol: show the solution. Here M contains the literals that are true in the model:

% displaySol(M) :- write(M), nl, nl, fail.
displaySol(M) :-
    day(D), write('Rows on day '), write(D), write(':'), nl,
    row(R),
    findall(H,(handmaid(H),member(hdr(H,D,R),M)),L), write('   '), write(L), nl,
    fail.
displaySol(M) :- checkForEachDHexactlyOneR(M,L), L \= [],
		 write("failed check: for each day and handmaid there is exactly one row "),
		 write(L), nl, fail.
displaySol(M) :- checkForbiddenGroups(M,L), L \= [],
		 write("failed check: condition about forbidden groups "),
		 write(L), nl, fail.
displaySol(M) :- checkMandatoryGroups(M,L), L \= [], nl,
		 write("failed check: condition about mandatory groups "),
		 write(L), nl, fail.
displaySol(_) :- !.

checkForEachDHexactlyOneR(M, L) :-
    findall( [d(D),h(H)]-lr(LR), (day(D), handmaid(H), findall(R, (row(R), member(hdr(H,D,R), M)), LR), length(LR, LenR), LenR \= 1), L ), !.

checkForbiddenGroups(M, L) :-
    forbidden(LF),
    findall( [d(D),r(R)]-fg([H1,H2,H3]),
	     (member([H1,H2,H3], LF), day(D), row(R), member(hdr(H1,D,R), M), member(hdr(H2,D,R), M), H1 < H2, member(hdr(H3,D,R), M), H2 < H3),
	     L ), !.

checkMandatoryGroups(M, L) :-
    mandatory(LM),
    findall( mg([H1,H2,H3]),
	     (member([H1,H2,H3],LM),
	      findall( [D,R],
		       (day(D), row(R), member(hdr(H1,D,R),M), member(hdr(H2,D,R),M), member(hdr(H3,D,R),M)),
		       LDR ),
	      length(LDR, 0)),
	     L ), !.



%%%%%%%  4. This predicate computes the cost of a given solution M: ===========================

costOfThisSolution(M,Cost) :-
    maxCost(Max), between(1,Max,I), Cost is Max-I+1,
    handmaid(H1), handmaid(H2), H1 < H2,
    findall(D,(day(D),row(R),member(hdr(H1,D,R),M),member(hdr(H2,D,R),M)),L),
    sort(L,L1),
    length(L1,Cost), !.

%%%%%%% =======================================================================================



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
        write('Launching picosat...'), nl,
        shell('picosat -v infile.cnf > model', Result),  % if sat: Result=10; if unsat: Result=20.
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
        write('Launching picosat...'), nl,
        shell('picosat -v infile.cnf > model', Result),  % if sat: Result=10; if unsat: Result=20.
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
