
numTeams(14).               % This number is always even.
noDoubles([2,8,13]).        % No team has a double on any of these rounds.
tvTeams([1,2,3,4,5,6]).     % The list of tv teams.

notHome( 1, [2,5,7,9,10]).  % Team 1 cannot play at home on round 2, also not on round 5, etc.
notHome( 2, [4,6,8,10]).
notHome( 3, [2,3,5,7,9,10]).
notHome( 4, [4,6,8,12]).
notHome( 5, [1,3,12]).
notHome( 6, [1,3,5,7,10]).
notHome( 7, [1,3,5,7,9]).
notHome( 8, [1,3,5,7,9]).
notHome( 9, [1,4,8,10]).
notHome(10, [2,4,8,9,11]).
notHome(11, [2,4,8,12]).
notHome(12, [6]).
notHome(13, [6,10,11,13]).
notHome(14, [2,4]).
