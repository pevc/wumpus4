:- load_files([wumpus1]).
:- use_module(library(lists)).
:- dynamic([localizacao/2, %determina onde você está.
            angulo/1, %Determina para onde você está olhando.
            casa_segura/2, %Lugares que você já explorou.
            casa_inexplorada/1,%Lugares seguros mas inexplorados para explorar caso o caminho principal falhou
            turno/1,%contador de turno. O mais importante é o primeiro(fugir) e o 40(desistir de mais ouros)
            casa_adjacente/4, %Lista com as casas adjacentes, no formado casa_adjacente((origem),(final)).
            caminhos_ja_passados/1, %Impede loop ao buscar o caminho.
            modo_fuga/1 %caso o turno limite seja atingido ou se não há mais casas para explorar, volta para a casa principal.
		   ]).

init_agent:-
    		writeln('agente inicializado...'),
			retractall(localizacao(_,_)),
            retractall(angulo(_)),
            retractall(casa_segura(_,_)),
            retractall(casa_inexplorada(_)),
            retractall(turno(_)),
            retractall(casa_adjacente((_,_),(_,_))),
            retractall(modo_fuga(_)),
            assert(localizacao(1,1)),
            assert(angulo(0)),
            assert(casa_inexplorada([(1,1),(-5)])),
            assert(casa_segura(1,1)),
            assert(turno(1)),
            assert(modo_fuga(0)).
restart_agent:-
    init_agent.

run_agent(Pe,Ac):-
    				pega_ouro(Pe,Ac);
					tempo_limite(Pe),
 					correndo_tempo(Pe,Ac);
					turno1(Pe),
    				desistindo(Pe,Ac);
   					atualizador(Pe),
					verificador(Pe),
   					movimento(Pe,Ac).

pega_ouro([_,_,yes,_,_],grab):- %O agente tem prioridade para pegar o ouro todas as vezes que ele passa por ele, mesmo no modo fuga.
                                turno(T),
                                Tn is T+1,
                                retractall(turno(_)),
                                assert(turno(Tn)).
tempo_limite(_):- %Tempo limite para ele buscar o ouro e ainda conseguir escapar. Caso o turno chegue no 54, ele começa a voltar para a base.
                	turno(T),
                	T>54,
                	retractall(modo_fuga(_)),
                	assert(modo_fuga(1)).


correndo_tempo(_,climb):- %Caso esteja no modo de fuga e na casa 1,1, ele foge.
                       		modo_fuga(1),
                       		localizacao(1,1).
correndo_tempo(_,Ac):- %Senao, se estiver no modo de fuga ele anda até a casa (1,1).
                       modo_fuga(1),
                       localizacao(X,Y),
                       proximacasa((X,Y),(A,B),(1,1)),
                       !,
                       acao((A,B),Ac).

verificador(_):- %verifica se a lista de casas inexploradas acabou(Condicao é quando só tem -5 na lista) e ativa o modo de fuga.
                casa_inexplorada([-5]),
                retractall(modo_fuga(_)),
                assert(modo_fuga(1)).
verificador(_).

%Caso exista casas perigosas ao redor da casa(1,1), ele dá prioridade a fugir.
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


%Caso o turno1 seja verdade, ele foge.
desistindo(_,climb):-
                      modo_fuga(1),
                      localizacao(1,1).

desistindo(_,Ac):-
                  modo_fuga(1),
                  localizacao(X,Y),
                  proximacasa((X,Y),(A,B),(1,1)),
                  !,
                  acao((A,B),Ac).


%Se não hourver fedor na brisa atual, atualiza a casa atual para sagura e verifica se as casas ao redor são inexploradas e existentes.
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

%Se ele estiver fazendo  backtracking, ele aumenta o turno por ação feita.
atualizador(_):- 
				turno(T),
                Tn is T+1,
                retractall(turno(_)),
                assert(turno(Tn)).


%Pega o valor da ultima casa inexplorada adicionada e verifica qual é a proxima casa que ele deve ir para se aproximar dessa casa. Caso seja necessario,muda a direcao para olhar na direcao dessa proxima casa. Senão anda para ela e repete o processo. 
movimento(_,Ac):-
                localizacao(X,Y),
                casa_inexplorada(Lista),
                nth0(0,Lista,Proximo),
                proximacasa((X,Y),(A,B),Proximo),
                !,
                acao((A,B),Ac).


acao((C,_),turnright):-
						localizacao(X,_),
                        X>C,
                        angulo(3),
                        retractall(angulo(_)),
                        assert(angulo(2)).

acao((C,_),turnleft):- 
						localizacao(X,_),
                        X>C,
                        angulo(I),
                        I<2,
                        In is I+1,
                        retractall(angulo(_)),
                        assert(angulo(In)).

acao((C,_),turnleft):- 
						localizacao(X,_),
                        X<C,
                        angulo(3),
                        retractall(angulo(_)),
                        assert(angulo(0)).

acao((C,_),turnright):-
						localizacao(X,_),
                        X<C,
                        angulo(I),
                        I>0,
                        In is I-1,
                        retractall(angulo(_)),
                        assert(angulo(In)).

acao((_,D),turnright):-
						localizacao(_,Y),
                        Y<D,
                        angulo(I),
                        I>1,
                        In is I-1,
                        retractall(angulo(_)),
                        assert(angulo(In)).

acao((_,D),turnleft):-
					 	localizacao(_,Y),
                     	Y<D,
                     	angulo(0),
                     	retractall(angulo(_)),
                     	assert(angulo(1)).

acao((_,D),turnright):-
					 	localizacao(_,Y),
                     	Y>D,
                     	angulo(0),
                     	retractall(angulo(_)),
                     	assert(angulo(3)).

acao((_,D),turnleft):-
					 	localizacao(_,Y),
                     	Y>D,
               		 	angulo(I),
                     	I<3,
                     	In is I+1,
                     	retractall(angulo(_)),
                     	assert(angulo(In)).

acao((_,_),goforward):-
                     	atualizador_localizacao,
                     	localizacao(X,Y),
                     	casa_inexplorada(Lista),
                     	delete(Lista,(X,Y),Novalista),
                      	retractall(casa_inexplorada(_)),
                      	assert(casa_inexplorada(Novalista)).
							

caminho((A,B),(C,D)):-
                     	casa_adjacente((A,B),(C,D)),
                     	impede_loop((A,B),(C,D)).

caminho((A,B),(C,D)):-
                     	casa_adjacente((A,B),(E,F)),
                     	impede_loop((A,B),(E,F)),
                     	caminho((E,F),(C,D)).

proximacasa((A,B),(C,D),(E,F)):-
                                casa_adjacente((A,B),(E,F)),
                                C is E,
                                D is F.

proximacasa((A,B),(C,D),(E,F)):-
                                casa_adjacente((A,B),(C,D)),
                                retractall(caminhos_ja_passados(_)),
                                assert(caminhos_ja_passados([[(50,50),(50,50)]])),
                                impede_loop((A,B),(C,D)),
                                caminho((C,D),(E,F)).
impede_loop((A,B),(C,D)):-
                       		caminhos_ja_passados(Lista),
                       		intersection([[(A,B),(C,D)]],Lista,[]),
                       		append([[(A,B),(C,D)],[(C,D),(A,B)]],Lista,Novalista),
                       		retractall(caminhos_ja_passados(_)),
                       		assert(caminhos_ja_passados(Novalista)).


%Essas funções atualizam a localizacao do Agente dependendo para onde ele está olhando.

atualizador_localizacao:-
       					localizacao(X,Y),
       					angulo(0),
       					Xn is X+1,
       					retractall(localizacao(_,_)),
       					assert(localizacao(Xn,Y)).

atualizador_localizacao:-
       					localizacao(X,Y),
       					angulo(1),
       					Yn is Y+1,
       					retractall(localizacao(_,_)),
       					assert(localizacao(X,Yn)).

atualizador_localizacao:-
       					localizacao(X,Y),
      					angulo(2),
       					Xn is X-1,
       					retractall(localizacao(_,_)),
       					assert(localizacao(Xn,Y)).

atualizador_localizacao:-
       					localizacao(X,Y),
       					angulo(3),
       					Yn is Y-1,
       					retractall(localizacao(_,_)),
       					assert(localizacao(X,Yn)).

%essas tres servem para verificar se as casas ao lado existem e nao sao exploradas.

funcao_atualizador((_,_),(A,B)):-
                               casa_segura(A,B).

funcao_atualizador((X,Y),(A,B)):-
            		            A>0,
                    		    A<5,
                    		    B>0,
                    		    B<5,
                                assert(casa_segura(A,B)),
                                casa_inexplorada(Lista),
                                append([(A,B)],Lista,Novalista),
                                retractall(casa_inexplorada(_)),
                                assert(casa_inexplorada(Novalista)),
                                assert(casa_adjacente((X,Y),(A,B))),
                                assert(casa_adjacente((A,B),(X,Y))).
funcao_atualizador((_,_),(_,_)).
