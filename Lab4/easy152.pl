maxHour(168).

%% task( taskID, Duration, ListOFResourcesUsed ).
task(1,19,[1,2]).
task(2,52,[1,2]).
task(3,16,[1,3]).
task(4,52,[1,3]).
task(5,16,[2,3]).
task(6,20,[2,3]).
task(7,45,[2,3]).

%% resourceUnits( resourceID, NumUnitsAvailable ).
resourceUnits(1,2).
resourceUnits(2,1).
resourceUnits(3,2).
