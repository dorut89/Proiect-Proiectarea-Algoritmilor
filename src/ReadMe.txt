Echipa VOID 

Fisiere:

* AI.java  - main-ul proiectului , de aici se realizeaza conexiunea cu servarul .
* Data.java - un fisier in care sunt stocate toate variabilele pentru a putea lucra mai usor mai multi oameni la proiect.
* Engine.java - aici pt etapele urmatoare vor fi implementate metode de analiza si interpretare a hartii.

Exceptie :

* Cum din scheletul de cod care ne-a fost transmis, pt numele echipei se trimite header-ul apoi 1 
(lungimea numelui) , noi trebuie sa dam ca parametru in linia de comanda in main doar o litera pt 
nume caci in caz contrar se vor trimite mai multe caractere si server-ul va interpreta altceva.

Comportament:

* Pentru acesta etapa am implementat sa transmita si sa primeasca de la server header-ele in ordine(desi pt 2 harti din cele propuse alg pica). 
* In fisierul Engine.java am scris o functi care verifica daca masina merge in directia buna si modifica acceleratia , frana si unghiul dorit. Daca masina a atins marginea atunci masina se va roti spre stanga cu un unghi de 45 grade si apoi reevalueaza pozitia curenta. 

