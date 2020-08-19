%Base de Conocimiento

personaje(pumkin,     ladron([licorerias, estacionesDeServicio])).
personaje(honeyBunny, ladron([licorerias, estacionesDeServicio])).
personaje(vincent,    mafioso(maton)).
personaje(jules,      mafioso(maton)).
personaje(marsellus,  mafioso(capo)).
personaje(winston,    mafioso(resuelveProblemas)).
personaje(mia,        actriz([foxForceFive])).
personaje(butch,      boxeador).
personaje(elVendedor, vender).%Lo agregamos para que lo tuviera en cuenta en el predicado cantidadDeEncargos

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
%encargo(vincent,  jules, cuidar(mia)). %agregado
encargo(marsellus, winston, ayudar(jules)).
encargo(marsellus, winston, ayudar(vincent)).
%encargo(marsellus, jules, ayudar(vincent)). %lo agregamos para probar sanCayetano
%encargo(jules,  jimmie, cuidar(mia)). %agregado
encargo(marsellus, vincent, buscar(butch, losAngeles)). %butch

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

masAtareado(Personaje):-
    cantidadDeEncargos(Personaje, CantidadDeEncargosMayor),
    not(((cantidadDeEncargos(OtraPersona, OtraCantidad), OtraPersona\= Personaje), OtraCantidad >= CantidadDeEncargosMayor)).
%Preguntar si sirve mayor o igual
%not((cantidadDeEncargos(_, OtraCantidad), , OtraCantidad > CantidadDeEncargosMayor)). Primera opcion, no falta el distinto porque sólo se evalua mayor

cantidadDeEncargos(Personaje, CantidadDeEncargos):-
    personaje(Personaje, _), %lo agregamos para que sea inversible por la variable Personaje
    findall(Encargo, encargo(_, Personaje, Encargo), ListaEncargos),
    length(ListaEncargos, CantidadDeEncargos).

/*Punto 6. 
personajesRespetables/1: genera la lista de todos los personajes respetables. 
Es respetable cuando su actividad tiene un nivel de respeto mayor a 9. Se sabe que:
Las actrices tienen un nivel de respeto de la décima parte de su cantidad de peliculas.
Los mafiosos que resuelven problemas tienen un nivel de 10 de respeto, los matones 1 y los capos 20.
Al resto no se les debe ningún nivel de respeto. 
*/

/*Opcion con Lista
personajesRespetables(ListaPersonajes):-
    forall(member(Personaje, ListaPersonajes), esRespetable(Personaje)).*/

personajesRespetables(ListaPersonajes):-
    findall(Personaje, esRespetable(Personaje), ListaPersonajes).

esRespetable(Personaje):-
    nivelRespeto(Personaje, NivelRespeto),
    NivelRespeto > 9.

nivelRespeto(Personaje, NivelRespeto):-
    personaje(Personaje, Actividad),
    nivelDeRespetoSegunActividad(Actividad, NivelRespeto).

nivelDeRespetoSegunActividad(actriz(Peliculas), NivelRespeto):-
    length(Peliculas, CantidadPeliculas),
    NivelRespeto is CantidadPeliculas // 10.

nivelDeRespetoSegunActividad(mafioso(resuelveProblemas), 10).
nivelDeRespetoSegunActividad(mafioso(maton), 1).
nivelDeRespetoSegunActividad(mafioso(capo), 20).

/*Punto 7
hartoDe/2: un personaje está harto de otro, cuando todas las tareas asignadas al primero 
requieren interactuar con el segundo (cuidar, buscar o ayudar) o un amigo del segundo. Ejemplo:*/

hartoDe(Hartado, Persona):-
    encargo(_, Hartado, _), %para ligar el hartado
    personaje(Persona, _), %para ligar la persona
    forall(encargo(_, Hartado, Tarea), requiereInteractuar(Persona, Tarea)).

requiereInteractuar(Persona, Tarea):-
    estaEnLaTarea(Persona, Tarea).

requiereInteractuar(Persona, Tarea):-
    amigo(Persona, Amigo),
    estaEnLaTarea(Amigo, Tarea).

estaEnLaTarea(Personaje, cuidar(Personaje)).
estaEnLaTarea(Personaje, ayudar(Personaje)).
estaEnLaTarea(Personaje, buscar(Personaje, _)).

/*Punto 8
Ah, algo más: nuestros personajes tienen características. Lo cual es bueno, porque nos ayuda a
 diferenciarlos cuando están de a dos. Por ejemplo:

Desarrollar duoDiferenciable/2, que relaciona a un dúo (dos amigos o una pareja) en el que uno 
tiene al menos una característica que el otro no. */

caracteristicas(vincent,  [negro, muchoPelo, tieneCabeza]).
caracteristicas(jules,    [tieneCabeza, muchoPelo]).
caracteristicas(jimmie,   [negro]).

duoDiferenciable(Persona, OtraPersona):-
    seRelacionan(Persona, OtraPersona),
    tienenCaracteristicaDistinta(Persona, OtraPersona).

/*tienenCaracteristicaDistinta(Persona, OtraPersona):-
    hallarCaracteristica(Persona, Caracteristica),
    hallarCaracteristica(OtraPersona, OtraCaracteristica),
    Caracteristica \= OtraCaracteristica.*/

hallarCaracteristica(Persona, Caracteristica):-
    caracteristicas(Persona, Caracteristicas),
    member(Caracteristica, Caracteristicas).

tienenCaracteristicaDistinta(Persona, OtraPersona):-
    hallarCaracteristica(Persona, Caracteristica),
    caracteristicas(OtraPersona, OtrasCaracteristicas),
    not(member(Caracteristica, OtrasCaracteristicas)).







    












    

