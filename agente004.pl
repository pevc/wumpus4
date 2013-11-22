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

%analise a situacao das casas ao redor de uma casa sem brisa e sem fedor, os testes atuais estao perfeitos...
atualizador([no,no,_,_,_]):-
					localizacao(X,Y),
					Xn is X+1,
					Xl is X-1,
					Yn is Y+1,
					Yl is Y-1,
					retract(lugares_inexplorados(X,Y)),
					assert(lugares_explorados(X,Y)),
					funcao_atualizador(Xn,Y),
					funcao_atualizador(Xl,Y),
					funcao_atualizador(Yn,X),
					funcao_atualizador(Yl,X).

%Se ele sentir um fedor ou um buraco, ele diz que a casa atual e segura e as outtas nao importantes.
autalizador([_,_,_,_,_]):-
					retract(lugares_inexplorados(X,Y)),
					assert(lugares_explorados(X,Y)).

%essas tres servem para verificar se as casas ao lado existem e nao sao exploradas.
funcao_atualizador(X,Y):-
					lugares_explorados(X,Y).
funcao_atualizador(X,Y):-
					X>0,
					X<5,
					Y>0,
					Y<5,
					assert(lugares_inexplorados(X,Y)).
funcao_atualizador(X,Y).
