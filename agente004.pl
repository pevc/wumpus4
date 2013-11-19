:- load_files([wumpus1]).
:- use_module(library(lists)).
:- dynamic([localizacao/2, %determina onde você está.
     		direcao/1, %Determina para onde você está olhando.
			lugares_seguros/2, %Lugares que são seguros
			lugares_inexplorados/2,%Lugares para explorar caso o caminho principal falhou
			turno/1%contador de turno. O mais importante é o primeiro(fugir) e o 40(desistir de mais ouros)
		]).



init_agent:-
    writeln('agente inicializado...').

restart_agent:-
    init_agent.

run_agent(Pe,Ac):-
    agente004(Pe,Ac).


agente004([_,_,_,_,_],goforward).
