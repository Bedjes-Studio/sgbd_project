/*
COMMUNES
*/
insert into COMMUNE VALUES (1, 'Talence');
insert into COMMUNE VALUES (2, 'Bordeaux');
insert into COMMUNE VALUES (3, 'Pessac');
insert into COMMUNE VALUES (4, 'Gradignan');
insert into COMMUNE VALUES (5, 'Bègles');
insert into COMMUNE VALUES (6, 'Mérignac');
insert into COMMUNE VALUES (7, 'Eysines');
insert into COMMUNE VALUES (8, 'Cestas');

/*
adherents
*/
insert into ADHERENT VALUES (1, 'Guillaume', 'Fornes', 'Rue Marc Sangnier', 1, '2018-09-24');
insert into ADHERENT VALUES (2, 'Antoine', 'Gaudy', 'pala', 7, '2019-08-24');
insert into ADHERENT VALUES (3, 'Hugo', '', 'Langlais', 8, '2020-02-04');
insert into ADHERENT VALUES (4, 'Marwan', 'Zizi', 'Cours de l Intendance', 2, '2018-08-23');
insert into ADHERENT VALUES (5, 'Lucas', 'Marais', 'Rue Léo ferré', 1, '2016-04-16');
insert into ADHERENT VALUES (6, 'PJ', 'Morel', 'Rue Salvador Allende', 6, '2018-11-04');
insert into ADHERENT VALUES (7, 'Paul', 'Debrais', 'Rue VersleLeclerc', 8, '2021-09-22');
insert into ADHERENT VALUES (8, 'Germa', 'Emilie', 'Rue Peydavant', 6, '2020-05-18');
insert into ADHERENT VALUES (9, 'Jean', 'Pierre', 'Rue Jean Paul Sartre', 1, '2019-07-15');

/*
Stations
*/
insert into STATION VALUES (1, 'Arts et metiers', 1, 12, 10);
insert into STATION VALUES (1, 'ici', 1, 12, 10);
insert into STATION VALUES (1, 'ici', 1, 12, 10);
insert into STATION VALUES (1, 'ici', 1, 12, 10);

/*
Etat
*/
insert into ETAT VALUES (1, 'neuf');
insert into ETAT VALUES (2, 'bon');
insert into ETAT VALUES (3, 'endommagé');
insert into ETAT VALUES (4, 'HS');


/*
Velos
*/
insert into VELO VALUES (1, 'BTWIN', '2018-09-24', 1586, 1, 100, 2);
insert into VELO VALUES (2, 'ROCKRIDER', '2018-09-25', 120, 1, 100, 1);
insert into VELO VALUES (3, 'TRICYCLE', '2018-09-26', 2, 1, 100, 1);
insert into VELO VALUES (4, 'MONOCYCLE', '2018-09-27', 8000, 1, 100, 3);
insert into VELO VALUES (5, 'BMX STREET', '2018-09-20', 806181, 1, 100, 4);
insert into VELO VALUES (6, 'SCOOTEIRB', '2018-09-20', 806, 1, 100, 2);


/*
Emprunts
*/
INSERT INTO EMPRUNT VALUES (1, 1586, NULL, '2018-10-24 12:10:20', 1, 1, 1);
INSERT INTO EMPRUNT VALUES (2, 1586, NULL, '2018-10-24 12:10:20', 1, 1, 2);
INSERT INTO EMPRUNT VALUES (3, 1586, NULL, '2018-10-24 12:10:20', 2, 1, 3);
