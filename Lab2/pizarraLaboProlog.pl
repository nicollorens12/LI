
% Pizarra usada en las primeras dos clases de labo de Prolog, con ejemplos.

% 
% Una base de datos relacional es un conjunto de "relaciones". 
% Cada relación viene expresada mediante "tuplas".

% Por ejemplo, una relación "estudiante" puede tener las tuplas:
%    estudiante( juan,  21, barcelona, 'Carrer Aragó 453',    ... ). 
%    estudiante( pedro, 22, barcelona, 'Carrer Viladomat 4',  ... ). 
%    ... 
% 
% Si tenemos las relaciones de "padre" y de "hermano":
%  padre(juan,pedro).                  % el padre de juan es pedro
%  padre(maria,pedro).
%  ...                                 % n tuplas en la relación padre

%  hermano(pedro,vicente).             % el hermano de pedro es vicente
%  hermano(pedro,alberto).
%  ...                                 % m tuplas en la relación hermano
% 
% 
% ¿Cómo podríamos hacer la relación "tio"?  Con n x m tuplas?
%        Malgastamos espacio (es información que en realidad ya tenemos!!)
%        Problemas de consistencia....
%
%  Solución: bases de datos deductivas
%
%  Ponemos una regla:
%     forall S,T   tio(S,T) if exists P  such that padre(S,P) AND hermano(P,T)
%  
%  En Prolog:      tio(S,T):-     padre(S,P), hermano(P,T).
%                  ("el tio de S es T si el padre de S es P y el hermano de P es T")
%
% Programa Prolog === BD deductiva !!


%1 
padre(juan,pedro).      % El padre de juan es pedro.
%2 
padre(maria,pedro).
%3 
hermano(pedro,vicente). % El hermano de pedro es vicente.
%4 
hermano(pedro,alberto).
%5 
tio(S,T):- padre(S,P), hermano(P,T).  % S, P, T son variables.
                                      % El ámbito de las variables es la misma cláusula.

% Lo que hay en una línea detrás del porcentaje % es un comentario.
% En este archivo pizarraLaboProlog.pl  hay muchos comentarios!

% En Prolog, lo que comienza por Mayúscula o por subrayado  _  son variables.
%
% Lo demás son términos;    juan,  hermano(X,juan),  f(X,a),   f(g(a),Z),   ...

% Entramos (en Linux) en el SWI Prolog con el comando swipl
% Nos da mensaje de bienvenida y saca el prompt:
%
% ?-

% Ahora podemos decirle que lea este archivo, que se llama  pizarraLaboProlog.pl   :
% ?- [pizarraLaboProlog].

% Después de esto, ya podemos hacer consultas:
% ?- padre(juan,X).      % esto es nuestro "objetivo"   (inglés: goal)
% ?- padre(Y,pedro).


% ¿Cómo hace el intérprete de Prolog para "ejecutar" un programa Prolog?
% Busca la primera cláusula en la base de datos cuya "cabeza" sea "unificable" con el objetivo:
%  "cabeza".
%  "cabeza" :- "cola".

%  "unificar" = dadas dos expresiones, dar valores a sus variables, para que sean iguales:

%  El simbolo  = significa "es unificable"

% | ?- f(X,a) = f(b,Y).
% | ?- f(f(X),a)  =  f(Y,Y).
% | ?- f(f(X),a) \=  f(Y,Y).
% | ?- f(f(X),a)  =  f(Y,Z).


%?- tio(juan,Z).
% La pila de backtracking:  cuando llama a hermano(pedro,T), usa la 3. y empila la 4.
% Da la respuesta Z = vicente
% y si pido más respuestas (con el ;), entonces el backtracking usa lo empilado como alternativa, y usa la 4.


%?- tio(A,B)
% La pila de backtracking:  
%        cuando llama a padre(S,P), usa la 1. y empila la 2.
%        cuando llama a hermano(pedro,T), usa la 3. y empila la 4.
% da la respuesta:
%     A = juan
%     B = vicente
% En este momento la pila contiene  2,4
% y si pido más respuestas (con el ;), entonces el backtracking usa lo último empilado como alternativa, y usa la 4.
% Da la respuesta:
%     A = juan
%     B = alberto
% En este momento la pila contiene  2
% y si pido más respuestas (con el ;), entonces el backtracking usa la 2
%        cuando llama a hermano(pedro,T), usa la 3. y empila la 4.
% Da la respuesta:
%     A = maria
%     B = vicente
% En este momento la pila contiene  4
% y si pido más respuestas (con el ;), entonces el backtracking usa la 4
% da la respuesta:
%     A = maria
%     B = alberto
% En este momento la pila queda vacía y termina


% "listas"  [ a, b, f(a), g(f(a,X)), [c], X ]
% []                es la lista vacía
% [ a, b | L ]      la | separa los primeros elementos de la **lista** de los demás elementos

% ?- [a,b,c] = [X|L].


% Prolog es programación DECLARATIVA. NO imperativa
% Esto hace que los programas sean versátiles: la misma definición nos sirve para muchos tipos de consultas.
% Por ejemplo, podemos declarar (definir) qué es pertenecer a una lista: pert(X,L) "X pertenece a la lista L"

% pert(X,L) = "X pertenece a la lista L"
% (en realidad ya existe en SWI Prolog, y se llama member)
pert(X, [X|_] ).              % _ es una variable anónima.
pert(X, [_|L] ):- pert(X,L).

% concat(L1,L2,L3) = "L3 es la concatenacion de L1 con L2"
% Ya existe, y se llama append
concat( [],     L,  L       ).
concat( [X|L1], L2, [X|L3] ):- concat( L1, L2, L3).

% pert_con_resto(X,L,R) = "X pertenece a la lista L, y el resto de la lista es R"
% Ya existe en SWI Prolog, y se llama select
pert_con_resto(X,L,R):- concat(L1,[X|L2], L    ), 
                        concat(L1,   L2,  R).

% Aritmética!!
% Var is Expresion   = "unifica el resultado de evaluar Expresion con Var"

% fact(N,F) = "F es el factorial de N"  F será  N * (N-1) * ... * 1
fact(0,1).
fact(N,F):- N > 0, N1 is N-1,  fact(N1,F1), F is N * F1.

% long(L,N) = "la longitud de L es N"
% Ya existe, y se llama length
long([],0).
long([_|L],N):- long(L,N1), N is N1+1.


% permutacion(L,P) = "P es una permutacion de la lista L"
% Ya existe, y se llama permutation

permutacion([],[]).
permutacion([X|L], P):- permutacion(L,P1),     
			concat( Pa,    Pb, P1),
			concat( Pa, [X|Pb], P).


% subcjto(L,S) = "S es un subconjunto de L"
subcjto( [], [] ).
subcjto( [_|L],    S  ):-  subcjto(L,S).
subcjto( [X|L], [X|S] ):-  subcjto(L,S).


% cifras( L, N ) escribe las maneras de obtener N
% a partir de + - * / y los elementos de la lista L
% ejemplo:
% ?- cifras( [4,9,8,7,100,4], 380 ).
%    4 * (100-7) + 8         <-------------
%    ((100-9) + 4 ) * 4
%    ...

cifras(L,N):-
    subcjto(L,S),         % S = [4,8,7,100]
    permutation(S,P),     % P = [4,100,7,8]
    expresion(P,E),       % E = 4 * (100-7) + 8 
    N is E,
    write(E), nl, fail.


% E = ( 4  *  (100-7) )    +    8
%            +
%          /   \
%         *     8
%        / \
%       4   -
%          / \
%        100  7

% Ver página del You Tube: http://www.youtube.com/watch?v=lBcwA0TYEVo
% A partir del minuto 6.
% Hacer llamada:
% ?- cifras([8,75,25,7,6,5], 901).

expresion([X],X).
expresion( L, E1 +  E2 ):- append( L1, L2, L), 
			  L1 \= [], L2 \= [],
			  expresion( L1, E1 ),
			  expresion( L2, E2 ).
expresion( L, E1 -  E2 ):- append( L1, L2, L), 
			  L1 \= [], L2 \= [],
			  expresion( L1, E1 ),
			  expresion( L2, E2 ).
expresion( L, E1 *  E2 ):- append( L1, L2, L), 
			  L1 \= [], L2 \= [],
			  expresion( L1, E1 ),
			  expresion( L2, E2 ).
expresion( L, E1 // E2 ):- append( L1, L2, L), 
			  L1 \= [], L2 \= [],
			  expresion( L1, E1 ),
			  expresion( L2, E2 ),
                          K1 is E1,
                          K2 is E2,
                          K2\=0,    % evitamos que se produzcan divisiones por cero
                          0 is K1 mod K2. % imponemos divisiones exactas!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ejemplo para explicar
% bucles guiados por fallo (failure-driven loops)
% el operador de corte "!":

p(1).                           %1
p(2).                           %2

q(a).                           %3
q(b).                           %4

r(3,4,5).                       %5
r(X,Y,Z):- p(X), q(Y), !, s(Z). %6
%el corte ! quita de la pila las alternativas
% para p(..) q(..) y r(..)
r(5,6,7).                       %7

s(3).                           %8
s(4).                           %9

h(X,Y,Z):- r(X,Y,Z).            %10
% A B C      A B C  

h(a,b,c).                       %11

%% Se comporta así:

%% ?- p(A), write(A), nl, fail.
%% 1
%% 2
%% false.

%% ?- h(A,B,C), write( [A,B,C] ), nl, fail.
%% [3,4,5]
%% [1,a,3]
%% [1,a,4]
%% [a,b,c]
%% false.


%factorial(N,F) = "F es el factorial de N"  F será  N * (N-1) * ... * 1
factorial(0,1) :- !.
factorial(N,F) :- %write(N), nl,
                  N1 is N-1,  factorial(N1,F1), F is N * F1.

% ! es necesario por ejemplo aquí:
% ?- member(X, [1,2,3]), factorial(X, F), write(X->F), nl, fail.

% der( Expr, Var, Der )  == "la derivada de Expr con respecto Var es Der"
der( X, X, 1) :- !.
der(C, _, 0) :- atomic(C).
der( A+B, X, U+V )    :- der(A,X,U), der(B,X,V). 
der( A*B, X, A*V+B*U ):- der(A,X,U), der(B,X,V). 
% ...

% ! es necesario por ejemplo aquí:
% ?- der(x, x, D).


% union( L1, L2, U ) == "U es la union de L1 con L2 (como conjuntos, sin repeticiones)"
union( [],     L,  L ).
union( [X|L1], L2, U     ):-     member(X,L2),!, union( L1, L2, U ).
union( [X|L1], L2, [X|U] ):-                     union( L1, L2, U ).


% "not" es "negacion por fallo finito"  "negation by finite failure"

% ?- p(X), \+q(X).
% ?- p(X), not(q(X)).

% en realidad el "not" ya está definido en SWI Prolog, pero si lo tuviéramos que definir, "minot", sería así:
minot( X ):- call(X), !, fail.       %minot( X ):-  X, !, fail.   <--- esto daría error sintáctico; por eso existe el "call"
minot( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONVENIOS PARA LA NOTACIÓN DE ARGUMENTOS EN PREDICADOS

% ? cuando el argumento puede estar instanciado o no:
%
%     member(?Elem, ?List)
%     length(?List, ?Length)
%
% + cuando el argumento tiene que estar necesariamente instanciado
%   (no puede ser una variable). Puede ser ground o no.
% 
%     +Expr1 =< +Expr2
%     between(+Low, +High, ?Value)
%
% - cuando el argumento tiene que ser necesariamente una variable, que
%   quedara instanciada a un cierto término cuando el predicado se
%   satisface (a la práctica: un "resultado").
%
%     divmod(+N,+M, -Q, -R)
