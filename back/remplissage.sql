/*
COMMUNES
*/
insert into COMMUNE VALUES (1, 'bar');
insert into COMMUNE VALUES (2, 'BDE');

/*
adherents
*/
insert into ADHERENT VALUES (1, 'GUI', 'YOM', 'la', 1, '2018-09-24');
insert into ADHERENT VALUES (2, 'GODO', 'DO', 'pala', 2, '2018-08-24');

/*
Stations
*/
insert into STATION VALUES (1, 'ici', 1, 12, 10);

/*
Etat
*/
insert into ETAT VALUES (1, 'bon');


/*
Velos
*/
insert into VELO VALUES (1, 'BTWIN', '2018-09-24', 1586, 1, 100, 1);
insert into VELO VALUES (2, 'ROCKRIDER', '2018-09-25', 120, 1, 100, 1);
insert into VELO VALUES (3, 'TRICYCLE', '2018-09-26', 2, 1, 100, 1);
insert into VELO VALUES (4, 'MONOCYCLE', '2018-09-27', 8000, 1, 100, 1);
insert into VELO VALUES (5, 'BMX STREET', '2018-09-20', 806181, 1, 100, 1);


/*
Emprunts
*/
INSERT INTO EMPRUNT VALUES (1, 1586, NULL, '2018-10-24 12:10:20', 1, 1, 1);
INSERT INTO EMPRUNT VALUES (2, 1586, NULL, '2018-10-24 12:10:20', 1, 1, 2);
INSERT INTO EMPRUNT VALUES (3, 1586, NULL, '2018-10-24 12:10:20', 2, 1, 3);