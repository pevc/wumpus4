:- load_files([wumpus1]).
:- use_module(library(lists)).
:- dynamic([localizacao/2, %determina onde você está.
            angulo/1, %Determina para onde você está olhando.
            casa_segura/2, %Lugares que são seguros
            casa_inexplorada/1,%Lugares para explorar caso o caminho principal falhou
            turno/1,%contador de turno. O mais importante é o primeiro(fugir) e o 40(desistir de mais ouros)
            ouro/1, %verifica se possui o ouro ou não
            casa_adjacente/4, %Lista com as casas adjacentes, no formado casa_adjacente((origem),(final)).
            caminhos_ja_passados/1, %Impede loop ao buscar o caminho.
            modo_fuga/1
		   ]).

init_agent:-
    		writeln('agente inicializado...'),
			retractall(localizacao(_,_)),
            retractall(angulo(_)),
            retractall(casa_segura(_,_)),
            retractall(casa_inexplorada(_)),
            retractall(turno(_)),
            retractall(ouro(_)),
            retractall(casa_adjacente((_,_),(_,_))),
            retractall(modo_fuga(_)),
            assert(localizacao(1,1)),
            assert(angulo(0)),
            assert(casa_inexplorada([(1,1),(-5)])),
            assert(casa_segura(1,1)),
            assert(turno(1)),
            assert(ouro(0)),
            assert(modo_fuga(0)).
restart_agent:-
    init_agent.

run_agent(Pe,Ac):-
    pega_ouro(Pe,Ac);
	tempo_limite(Pe),
    correndo_tempo(Pe,Ac),
	turno1(Pe),
    desistindo(Pe,Ac).
pega_ouro([_,_,yes,_,_],grab):-
                                ouro(O),
                                On is O+1,
                                retractall(ouro(_)),
                                assert(ouro(On)),
                                turno(T),
                                Tn is T+1,
                                retractall(turno(_)),
                                assert(turno(Tn)).
								turno(1),
								retractall(ouro(_)),
								assert(ouro(1)).
tempo_limite(_):-
                turno(T),
                T>54,
                retractall(modo_fuga(_)),
                assert(modo_fuga(1)).

correndo_tempo(_,climb):-
                        modo_fuga(1),
                        localizacao(1,1).
correndo_tempo(_,Ac):-
                       modo_fuga(1),
                       localizacao(X,Y),
                       proximacasa((X,Y),(A,B),(1,1)),
                       !,
                       acao((A,B),Ac).

verificador(_):-
                casa_inexplorada([-5]),
                retractall(modo_fuga(_)),
                assert(modo_fuga(1)).
verificador(_).

turno1([yes,_,_,_,_]):-
                        turno(T),
                        T<2,
                        retractall(modo_fuga(_)),
                        assert(modo_fuga(1)).
turno1([_,yes,_,_,_]):-
                        turno(T),
                        T<2,
                        retractall(modo_fuga(_)),
                        assert(modo_fuga(1)).
turno1(_).

%Essas duas, pr sua vez, verificam se ha perigo ao redor das casas e se haver fogem.

%analise a situacao das casas ao redor de uma casa sem brisa e sem fedor, os testes atuais estao perfeitos...
desistindo(_,climb):-
                      modo_fuga(1),
                      localizacao(1,1).

desistindo(_,Ac):-
                  modo_fuga(1),
                  localizacao(X,Y),
                  proximacasa((X,Y),(A,B),(1,1)),
                  !,
                  acao((A,B),Ac).



atualizador([no,no,_,_,_]):-
                           localizacao(X,Y),
                           casa_inexplorada(Lista),
                           delete(Lista,(X,Y),Novalista),
                           retractall(casa_inexplorada(_)),
                           assert(casa_inexplorada(Novalista)),
                           Xn is X+1,
                           Xl is X-1,
                           Yn is Y+1,
                           Yl is Y-1,
                           turno(T),
                           Tn is T+1,
                           retract(turno(_)),
                           assert(turno(Tn)),
                           funcao_atualizador((X,Y),(X,Yl)),
                           funcao_atualizador((X,Y),(Xl,Y)),
                           funcao_atualizador((X,Y),(X,Yn)),
                           funcao_atualizador((X,Y),(Xn,Y)).


%Se ele sentir um fedor ou um buraco, ele diz que a casa atual e segura e as outtas nao importantes.

atualizador(_):-
                localizacao(X,Y),
                casa_inexplorada(Lista),
                delete(Lista,(X,Y),Novalista),
                retractall(casa_inexplorada(_)),
                assert(casa_inexplorada(Novalista)),
                turno(T),
                Tn is T+1,
                retractall(turno(_)),
                assert(turno(Tn)).

atualizador(_):- 
				turno(T),
                Tn is T+1,
                retractall(turno(_)),
                assert(turno(Tn)).


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

reto(1,1).
reto(1,2).
reto(1,3).
reto(1,4).
reto(2,4).
reto(3,4).
reto(3,3).
reto(3,2).
reto(3,1).
reto(4,1).



adjacente((A,B),(X,Y)):- Al is A+1,
						X = Al,
						Y = B,
						reto(Al,B),

%Essa parte, assim como as partes mais a direita da ementa, significa que ele vai e nao volta. Preciso colocar na funcao algo que reseta e da assert toda vez que ele chamar o caminho, e tentar simplificar.

         		   		caminho_horizontal(0),
				         retractall(caminho_horizontal(_)),
				         assert(caminho_horizontal(0)),
				         retractall(caminho_vertical(_)),
				         assert(caminho_vertical(1)),
				         assert(caminho_vertical(0)).

adjacente((A,B),(X,Y)):- An is A-1,
						X = An,
						Y = B,
						reto(An,B),
						
						caminho_horizontal(1),
						retractall(caminho_horizontal(_)),
						assert(caminho_horizontal(1)),
						retractall(caminho_vertical(_)),
						assert(caminho_vertical(1)),
						assert(caminho_vertical(0)).

adjacente((A,B),(X,Y)):- Bl is B+1,
						X = A,
						Y = Bl,
						reto(A,Bl),

						caminho_vertical(0),
						retractall(caminho_vertical(_)),
						assert(caminho_vertical(0)),
						retractall(caminho_horizontal(_)),
						assert(caminho_horizontal(1)),
						assert(caminho_horizontal(0)).



adjacente((A,B),(X,Y)):- Bn is B-1,
						X = A,
						Y = Bn,
						reto(A,Bn),

						caminho_vertical(1),
						retractall(caminho_vertical(_)),
						assert(caminho_vertical(1)),
						retractall(caminho_horizontal(_)),
						assert(caminho_horizontal(1)),
						assert(caminho_horizontal(0)).
							

%Fazendo testes para verificar caminho de uma casa a outra.

caminho((A,B),(X,Y)):- reto(A,B), reto(X,Y), adjacente((A,B),(X,Y)).
caminho((A,B),(X,Y)):- reto(A,B), reto(X,Y), adjacente((A,B),(E,F)),reto(E,F),!,caminho((E,F),(X,Y)).

maisproximo((A,B),(C,D),(E,F)):-adjacente((A,B),(C,D)), caminho((C,D),(E,F)).

% A ideia desse mais proximo eh verificar qual a casa mais proxima do agente que esteja no caminho, assim, ele apenas precisa se virar na direcao dele  e dar um 'go forward.




