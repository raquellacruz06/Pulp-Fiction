%Base de Conocimiento

personaje(pumkin,     ladron([licorerias, estacionesDeServicio])).
personaje(honeyBunny, ladron([licorerias, estacionesDeServicio])).
personaje(vincent,    mafioso(maton)).
personaje(jules,      mafioso(maton)).
personaje(marsellus,  mafioso(capo)).
personaje(winston,    mafioso(resuelveProblemas)).
personaje(mia,        actriz([foxForceFive])).
personaje(butch,      boxeador).

pareja(marsellus, mia).
pareja(pumkin,    honeyBunny).

%trabajaPara(Empleador, Empleado)
trabajaPara(marsellus, vincent).
trabajaPara(marsellus, jules).
trabajaPara(marsellus, winston).

amigo(vincent, jules).
amigo(jules, jimmie).
amigo(vincent, elVendedor).

%encargo(Solicitante, Encargado, Tarea). 
%las tareas pueden ser cuidar(Protegido), ayudar(Ayudado), buscar(Buscado, Lugar)
encargo(marsellus, vincent,   cuidar(mia)).
encargo(vincent,  elVendedor, cuidar(mia)).
encargo(vincent,  jules, cuidar(mia)). %agregado
encargo(marsellus, winston, ayudar(jules)).
encargo(marsellus, wiston, ayudar(vincent)).
encargo(marsellus, jules, ayudar(vincent)). %lo agregamos para probar sanCayetano
encargo(jules,  jimmie, cuidar(mia)). %agregado
encargo(marsellus, vincent, buscar(butch, losAngeles)).

/* Punto 1
esPeligroso/1. Nos dice si un personaje es peligroso. Eso ocurre cuando:
-realiza alguna actividad peligrosa: ser matón, o robar licorerías. 
- tiene empleados peligrosos
*/

esPeligroso(Personaje):-
    realizaActividadPeligrosa(Personaje).

esPeligroso(Personaje):-
    trabajaPara(Personaje, Empleado),
    esPeligroso(Empleado).

realizaActividadPeligrosa(Personaje):-
    personaje(Personaje, Actividad),
    actividadPeligrosa(Actividad).
    
actividadPeligrosa(ladron(SitiosQueRoba)):-
        member(licorerias, SitiosQueRoba).

actividadPeligrosa(mafioso(maton)).

/*Punto 2. 
duoTemible/2 que relaciona dos personajes cuando son peligrosos y 
además son pareja o amigos. Considerar que Tarantino también nos dió los siguientes hechos:*/

duoTemible(Personaje, OtroPersonaje):-
    esPeligroso(Personaje),
    esPeligroso(OtroPersonaje),
    seRelacionan(Personaje, OtroPersonaje).

seRelacionan(Personaje, OtroPersonaje):-
    amigo(Personaje, OtroPersonaje).

seRelacionan(Personaje, OtroPersonaje):-
    pareja(Personaje, OtroPersonaje).

%----------------Preguntar después por simetría de pareja y amigos------------------

/*estaEnProblemas/1: un personaje está en problemas cuando 
el jefe es peligroso y le encarga que cuide a su pareja
o bien, tiene que ir a buscar a un boxeador. 
Además butch siempre está en problemas. 
*/

estaEnProblemas(butch).

estaEnProblemas(Personaje):-
    trabajaPara(Jefe, Personaje),
    esPeligroso(Jefe),
    encargo(Jefe, Personaje, cuidar(Pareja)),
    pareja(Jefe, Pareja).

estaEnProblemas(Personaje):-
    encargo(_, Personaje, buscar(Persona)),
    personaje(Persona, boxeador).

/*Punto 4.  
sanCayetano/1:  es quien a todos los que tiene cerca les da trabajo (algún encargo). 
Alguien tiene cerca a otro personaje si es su amigo o empleado. 
*/

sanCayetano(Personaje):-
    encargo(Personaje, _,_),
    %personaje(Personaje, _), Con este me arroja todos los personajes para los cuales el antecedente es falso, ya que antecente falso indica predicado verdadero
    forall((personajeCercano(Personaje, PersonajeCercano), PersonajeCercano \= Personaje), encargo(Personaje, PersonajeCercano, _)).

personajeCercano(Personaje, PersonajeCercano):-
    amigo(Personaje, PersonajeCercano).

personajeCercano(Persona, PersonajeCercano):-
    trabajaPara(Persona, PersonajeCercano).

/*Punto 5. 
masAtareado/1. Es el más atareado aquel que tenga más encargos que cualquier otro personaje.*/






    

