% Exemples (SWI-Prolog)
% Per la majoria d'exemples s'indica
% 1. el significat
% 2. entre parèntesis, el predicat equivalent predefinit 
%    de SWI-Prolog si existeix, amb el nombre d'arguments

% Introducció

mes_gran(elefant,cavall).
mes_gran(cavall,ruc).
mes_gran(ruc,gos).
mes_gran(ruc,gat).
mesGran(X,Y) :- mes_gran(X,Y).
mesGran(X,Y) :- mes_gran(X,Z), mesGran(Z,Y).

mortal(X) :- home(X).
home(socrates).

% pert(X,L): "X pertany a la llista L"
% (member/2)
pert(X,[X|_]).
pert(X,[_|L]):- pert(X,L).

% conc(L1,L2,L3): "L3 és la concatenació de L1 amb L2"
% (append/3)         
conc([],L,L).
conc([X|L1],L2,[X|L3]):- conc(L1,L2,L3).

% ultim(L,X): "X és l'últim element de la llista L"
% (last/2)
ultim(L,X) :- concat(_,[X],L).

% revessat(L,R): "R és la llista L revessada"
% (reverse/2)
revessat([],[]).
revessat(L,[X|Y]) :-
    append(T,[X],L),
    revessat(T,Y).

% permutacio(L,P): "P és una permutació de la llista L"
% (permutation/2)
permutacio([],[]).
permutacio([X | L], P) :-
	permutacio(L, Q),
	conc(Q1, Q2, Q),
	conc(Q1, [X | Q2], P).

% subconjunt(S,T): "S és un subconjunt de T"
% (subset/2)

subconjunt([],_).
subconjunt([X|R],T) :-
	pert(X,T),
	subconjunt(R,T).

% fact(N,F): "F és el factorial de N"
fact(0,1):- !.
fact(N,F):- N1 is N-1,  fact(N1,F1), F is N * F1.

% mida(L,N): "el nombre d'elemebts de L és N"
% (length/2)   
mida([],0).
mida([_|L],N):- mida(L,N1), N is N1+1.

% subcjt(C,S): permet generar subconjunts S de C
subcjt([],[]).
subcjt(S,[_|L]):- 
	subcjt(S,L).
subcjt([X|S],[X|L]):- 
	subcjt(S,L).

% xifres(L,N): escriu les maneres d'obtenir N a partir dels elements
%              de la llista L amb les operacions +, -, *, //
xifres(L,N):-
    subcjt(S,L),     % S = [4,8,7,100]
    permutacio(S,P),     % P = [4,100,7,8]
    expressio(P,E),      % E = 4 * (100-7) + 8 
    N is E,
    write(E), nl, false.

% expressio(L,E): "E és una expressió aritmètica que es pot formar amb els 
%                 elements del conjunt L i les operacions +, -, *"
expressio([X],X).
expressio( L, E1 + E2 ):- 
			  append( L1, L2, L), 
			  L1 \= [], L2 \= [],
			  expressio( L1, E1 ),
			  expressio( L2, E2 ).
expressio( L, E1 - E2 ):- 
			  append( L1, L2, L), 
			  L1 \= [], L2 \= [],
			  expressio( L1, E1 ),
			  expressio( L2, E2 ).
expressio( L, E1 * E2 ):- 
	   		  append( L1, L2, L), 
			  L1 \= [], L2 \= [],
			  expressio( L1, E1 ),
			  expressio( L2, E2 ).

% der(E,V,D): "la derivada de E respecte de V és D"
der(X,X,1):- var(X), !. 
der(C,_,0):- 
	number(C).
der(A+B,X,U+V):- 
	der(A,X,U), 
	der(B,X,V). 
der(A*B,X,A*V+B*U):- 
	der(A,X,U), 
	der(B,X,V). 

% funcionen com els operadors lògics amb el mateix nom
and(A,B) :- A, B.
or(A,B) :- A; B.
neg(A) :- A, !, false.
neg(_).
implies(A,B) :- A, !, B.
implies(_,_).

% interval(A,B,L): "L és la llista dels enters A, A+1, ..., B"
interval(A,B,[]) :-
	B < A, !.
interval(A,A,[A]) :- !.
interval(A,B,[A|X]) :-
	C is A + 1,
	interval(C,B,X).

% rang(A,B): escriu la llista dels enters A, A+1, ..., B
rang(A,B) :-
	interval(A,B,X),
	write(X).
