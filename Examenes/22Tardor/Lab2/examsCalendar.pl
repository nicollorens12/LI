%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To use this prolog template for other optimization problems, replace the code parts 1,2,3,4 below. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

symbolicOutput(0).  % set to 1 for debugging: to see symbolic output only; 0 otherwise.

%% ===================================================================================================
%% 5 points.
%% Extend this Prolog source for designing the exams calendar of FIB.
%% Exams should take place within the specified dates. In each day
%% there are several available slots. We know the list of students
%% (represented with their ID, from 1 to N) enrolled in each subject.
%% The exams of two different subjects cannot take place on the same
%% date and at the same slot if they share a common enrolled student.
%% Moreover, no student can have three exams (or more) on the same day.
%% On the other hand, it is allowed that students may have two exams on
%% the same day. But since this is highly undesirable (isn't it?), it
%% is wished to minimize the number of times this happens. For
%% instance, if there are just two students:
%%
%%   * student 1 enrolled in LI, LP, IA and TC,
%%   * student 2 enrolled in     LP, IA and TC,
%%
%% a calendar in which
%%
%%   the exams of LI, LP take place on (different slots of) 02/11/2022, and
%%   the exams of IA, TC take place on (different slots of) 03/11/2022
%%
%% would have cost 3 (= student 1 on 02/11/2022 +
%%                      student 1 on 03/11/2022 +
%%                      student 2 on 03/11/2022)
%% ===================================================================================================


%% ==== Example input:

numStudents(9).

day("18/01/2023").
day("19/01/2023").

slot("08:00-11:00").
%% slot("11:30-14:30").
slot("15:30-18:30").

subject(   'A', [1,2,3,7]).
subject(   'G', [2,3,4]).
subject(  'IA', [3,5,6,9]).
subject(  'LI', [6,7,8]).
subject(  'LP', [1,3,5]).
subject(  'TC', [2,4,6,7,9]).

%% ==== end input.


%%%%%% Some helpful definitions to make the code cleaner:

student(U) :- numStudents(N), between(1, N, U).
subject(S) :- subject(S, _).
studentSubject(U, S) :- subject(S, L), member(U, L).
shareSomeStudent(S1, S2)     :- studentSubject(U, S1), studentSubject(U, S2), !.
shareSomeStudent(S1, S2, S3) :- studentSubject(U, S1), studentSubject(U, S2), studentSubject(U, S3), !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%% It is MANDATORY to use these variables!
% 1.- Declare SAT variables with the intended meaning in all optimal solutions
satVariable( x(S, D, I) ):- subject(S), day(D), slot(I). % "exam of subject S is on day D at slot I"
satVariable( x(S, D)    ):- subject(S), day(D).          % "exam of subject S is on day D"
satVariable( t(U, D)    ):- student(U), day(D).          % "student U has two exams on day D"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. This predicate writeClauses(MaxCost) generates the clauses that guarantee that
% a solution with cost at most MaxCost is found

writeClauses(MaxCost):-
    eachExamOnOneDayAndSlot,
    nobodyWithTwoExamsOnSameDayAtSameSlot,
    definitionExamOnDay,                    % relates x(S,D) SAT variables with x(S,D,I) SAT variables
    nobodyWithThreeExamsOnSameDay,
    definitionTwoExamsOnSameDay,    % already implemented
    maxCost(MaxCost),               % already implemented
    true,!.
writeClauses(_):- told, nl, write('writeClauses failed!'), nl,nl, halt.

eachExamOnOneDayAndSlot :-
    subject(S),
    findall(x(S,D,I),(day(D),slot(I)),Lits),
    exactly(1,Lits),
    fail.
eachExamOnOneDayAndSlot.

nobodyWithTwoExamsOnSameDayAtSameSlot :-
    subject(S1), subject(S2), S1 \= S2, shareSomeStudent(S1, S2),
    day(D),slot(I),
    writeOneClause([-x(S1,D,I),-x(S2,D,I)]),
    fail.
nobodyWithTwoExamsOnSameDayAtSameSlot.

% "exam of subject S is on day D at slot I" x(S, D, I)
% "exam of subject S is on day D"           x(S, D)
% relates x(S,D) SAT variables with x(S,D,I) SAT variables
definitionExamOnDay :-
    subject(S),day(D),
    findall(x(S,D,I),slot(I),Lits),
    expressOr(x(S,D),Lits),
    fail.
definitionExamOnDay.

nobodyWithThreeExamsOnSameDay :-
    subject(S1), subject(S2), subject(S3), S1 \= S2, S1 \= S3, S2 \= S3,
    shareSomeStudent(S1, S2, S3),
    day(D),
    writeOneClause([-x(S1,D),-x(S2,D),-x(S3,D)]),
    fail.
nobodyWithThreeExamsOnSameDay.

definitionTwoExamsOnSameDay :-
    studentSubject(U, S1), studentSubject(U, S2), S1 \= S2,
    day(D),
    writeOneClause([ -x(S1, D), -x(S2, D), t(U, D) ]), fail.
definitionTwoExamsOnSameDay.

maxCost(infinite):- !.
maxCost(MaxCost):- findall(t(U, D), (student(U), day(D)), Lits), atMost(MaxCost, Lits).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. This predicate displays a given solution M:

writeDaySlot(D, I) :- write(D), write(' '), write(I).

displaySubjects(D, I, M) :- member(x(S, D, I), M), write(S), write(' '), fail.
displaySubjects(_, _, _) :- nl, !.

displayStudentExams(U, M):-
    day(D), slot(I), studentSubject(U, S),
    member(x(S,D,I), M), write(S), write(' -> '), writeDaySlot(D,I), write('    '), fail.
displayStudentExams(_, _):- nl, !.

writeStudentInfo(U, M):-
    write('Student: '), write(U), write('   '), displayStudentExams(U, M), fail.
writeStudentInfo(U, M):-
    write('             #(days with two exams) = '),
    findall( D, (studentSubject(U,S1), studentSubject(U,S2), S1\=S2,
                 member(x(S1,D,_),M), member(x(S2,D,_),M)), LD ),
    sort(LD,LDs), length(LDs,K), write(K), nl, !.

%displaySol(M):- write(M), nl, nl, fail.
displaySol(M):- day(D), slot(I), writeDaySlot(D, I), write('   '), displaySubjects(D, I, M), nl, nl, fail.
displaySol(M):- student(U), writeStudentInfo(U, M), nl, fail.
displaySol(_):- nl, !.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. This predicate computes the cost of a given solution M:

costOfThisSolution(M, Cost):-
    findall( U, (student(U),day(D),member(t(U,D),M)) ,Students), length(Students,Cost), !.



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
