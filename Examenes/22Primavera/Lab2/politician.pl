
%% 3 points.
%% Elections are coming!  A politician wants to do a road trip starting and finishing at city 1, driving in
%% total at most MaxKm kilometers, and visiting at least N cities (city 1 and N-1 different other ones),
%% without passing twice through the same city!  Complete the following predicate politician(N,MaxKm,Trip),


% road(A-B,K) means there is a road from A to B (or vice versa) of length K km.
road( 1-3, 3  ).
road( 1-6, 25 ).
road( 2-3, 41 ).
road( 2-4, 31 ).
road( 2-5, 7  ).
road( 2-6, 7  ).
road( 3-4, 32 ).
road( 4-7, 14 ).
road( 4-8, 29 ).
road( 5-6, 36 ).
road( 5-7, 45 ).
road( 5-8, 22 ).
road( 6-8, 11 ).
road( 7-8, 44 ).

road1(A-B,K):- road(A-B,K).
road1(B-A,K):- road(A-B,K).


politician(N,MaxKm,Trip):-     path(...).

% path( NumCitiesRemainingToBeVisited, RemainingKm, CurrentCity, CitiesAlreadyVisited, Path )

path( 0, RemainingKm, 1, _, [] ):- ..., !.
path( NumCitiesRemainingToBeVisited, RemainingKm, CurrentCity, CitiesAlreadyVisited, [CurrentCity1|Path] ):-
    road1( CurrentCity-CurrentCity1, K ),
    ...
    path( ... ).


%% Examples: this main writes the six trips below (in some order):

main:- politician(5,100,Trip),   write([1|Trip]), nl, fail.
main:- politician(6,120,Trip),   write([1|Trip]), nl, fail.
main:- halt.

%% [1,3,4,8,6,1]
%% [1,3,4,2,6,1]
%% [1,6,8,4,3,1]
%% [1,6,2,4,3,1]
%% [1,3,2,5,8,6,1]
%% [1,6,8,5,2,3,1]




