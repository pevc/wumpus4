:- load_files([wumpus1]).
:- use_module(library(lists)).
:- dynamic([localizacao/2, %determina onde você está.
     		direcao/1, %Determina para onde você está olhando.
			lugares_seguros/2, %Lugares que são seguros
			lugares_inexplorados/2,%Lugares para explorar caso o caminho principal falhou
			turno/1%contador de turno. O mais importante é o primeiro(fugir) e o 40(desistir de mais ouros)
		]).



init_agent:-
    writeln('agente inicializado...'),
		retractall(localizacao(_,_)),
		retractall(direcao(_)),
		retractall(lugares_explorados(_,_)),
		retractall(lugares_inexplorados(_,_)),
		retractall(turno(_)),
		retractall(ouro(_)),
		assert(localizacao(1,1)),
		assert(direcao(0)),
		assert(lugares_inexplorados(1,1)),
		assert(turno(1)),
		assert(ouro(0)).

restart_agent:-
    init_agent.

run_agent(Pe,Ac):-
    turno1(Pe,Ac).

turno1([_,_,yes,_,_],grab):-
					turno(1),
					retractall(ouro(_)),
					assert(ouro(1)).
turno1([_,_,_,_,_],climb):-
					ouro(1).
%esses dois verificam se ha ouro na casa 1/1, pega o ouro e sai.

turno1([yes,_,_,_,_],climb):-
						turno(1),
						writeln('Sua morte vira outro dia, Wumpus, tenha certeza disso.').
turno1([_,yes,_,_,_],climb):-
						turno(1),
						writeln('Isso eh demais para mim,Adeus!').
%Essas duas, pr sua vez, verificam se ha perigo ao redor das casas e se haver fogem.



