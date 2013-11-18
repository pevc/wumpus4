:- load_files([wumpus1]).


init_agent:-
    writeln('agente inicializado...').

restart_agent:-
    init_agent.

run_agent(Pe,Ac):-
    agente004(Pe,Ac).


agente004([_,_,_,_,_],goforward).
