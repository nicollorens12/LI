dades([[1,_,_,_,_,_],[2,_,_,_,_,_],[3,_,_,_,_,_],[4,_,_,_,_,_],[5,_,_,_,_,_]]).

% [numcasa,color,professio,animal,beguda,pais]

condicions(D):-
    member([_,vermell,_,_,_,peru],D),
    member([_,_,_,gos,_,francia],D),
    member([_,_,pintor,_,_,japo],D),
    member([_,_,_,_,ron,china],D),
    member([1,_,_,_,_,hongria],D),
    member([_,verd,_,_,conac,_],D),
    between(1,4,I),
    J is I+1,
    member([I,verd,_,_,_,_],D),
    member([J,blanca,_,_,_,_],D),
    member([_,_,escultor,cargols,_,_],D),
    member([_,groc,actor,_,_,_],D),
    member([3,_,_,_,cava,_],D),
    %11
    between(1,5,PosActor),
    member([PosActor,_,actor,_,_,_],D),
    Ve is PosActor-1,
    Vd is PosActor+1,
    member(VeiActor,[Ve,Vd]),
    between(1,5,VeiActor),
    member([VeiActor,_,_,cavall,_,_],D),
    %12
    between(1,5,PosCasaBlava),
    member([PosCasaBlava,_,_,_,_,_],D),
    Vecb is PosCasaBlava - 1,
    Vdcb is PosCasaBlava + 1,
    member(VeiHungares,[Vecb,Vdcb]),
    between(1,5,VeiHungares),
    member([VeiHungares,_,_,_,_,hongria],D),
    %13
    member([_,_,notari,_,whisky,_],D),
    %14
    between(1,5,PosMetge),
    member([PosMetge,_,actor,_,_,_],D),
    Vem is PosMetge - 1,
    Vdm is PosMetge + 1,
    member(VeiMetge,[Vem,Vdm]),
    between(1,5,VeiMetge),
    member([VeiMetge,_,_,esquirol,_,_],D).

solucio :-
    dades(D),
    condicions(D),
    write(D).
