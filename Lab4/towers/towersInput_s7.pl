
upperLimitTowers(9).             % maxim number of towers allowed
significantVillages([e,h,m]).    % list of villages where a tower is mandatory
map_size(36,60).                 % numrows, numcols; the left upper corner of the map has coordinates (1,1)

% village(ident,row,col,size):  row,col of left upper corner, and size of the square
village(a,2,2,3).
village(b,6,32,5).
village(c,10,12,2).
village(d,10,48,4).
village(e,11,25,5).
village(f,15,20,3).
village(g,20,2,2).
village(h,20,23,2).
village(i,20,49,4).
village(j,21,32,4).
village(k,23,41,5).
village(l,26,50,3).
village(m,27,9,4).
village(n,28,59,2).
village(o,35,59,2).


%% The output could look similar to this  (each "T" indicates a tower):
%%
%% Solution found with cost 8

%%     1.......10........20........30........40
%%
%%  1  ............................................................
%%  2  .aaa........................................................
%%  3  .aaa........................................................
%%  4  .aaa........................................................
%%  5  ............................................................
%%  6  ...............................bbbbb........................
%%  7  ...............................bbbbb........................
%%  8  ...............................bbbbb........................
%%  9  ...............................bbbbb........................
%% 10  ...........cc..................bbbbb...........dddd.........
%% 11  ...........cc...........eeeee..................dddd.........
%% 12  ........................eeeee..................dddd.........
%% 13  ........................eeeee..................dddd.........
%% 14  ........................eeeee...............................
%% 15  ...................fff..eeeeT...............................
%% 16  ...................fff......................................
%% 17  ...................fff......................................
%% 18  ............................................................
%% 19  ............................................................
%% 20  .Tg...................hh........................iiii........
%% 21  .gg...................hT.......Tjjj.............iiii........
%% 22  ...............................jjjj.............iiii........
%% 23  ...............................jjjj.....kkkkk...iiii........
%% 24  ...............................jjjj.....kkkkk...............
%% 25  ........................................kkkkk...............
%% 26  ........................................kkkkk....Tll........
%% 27  ........mmmm............................kkkkk....lll........
%% 28  ........mmmm.....................................lll......nn
%% 29  ........mmmm..............................................nT
%% 30  ........mmmT................................................
%% 31  ............................................................
%% 32  ............................................................
%% 33  ............................................................
%% 34  ............................................................
%% 35  ..........................................................oo
%% 36  ..........................................................oT
