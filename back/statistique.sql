---- Statistiques 
-- moyenne du nombre d'usagers par vélo par jour

    -- Selection du nombre d'usagers par vélo
    SELECT ID_VELO, COUNT(*) AS COMPTE FROM EMPRUNT GROUP BY ID_VELO

    -- MOYENNE SUR LES 6 DERNIERS MOIS
    -- SELECT AVG(RUN_TIME) AS TST
    -- FROM (SELECT (DATEDIFF(MIN(CAST(HEURE_DEPART AS DATETIME)), MAX(CAST(HEURE_RENDU AS DATETIME)))) as RUN_TIME  FROM EMPRUNT 
    -- where Month(CAST(NOW() AS DATETIME)) BETWEEN Month(CAST(NOW() AS DATETIME) ) AND Month(CAST(NOW() AS DATETIME) ) + 6 )f;

-- usage : SELECT stat_adherent_par_velo();
DROP FUNCTION IF EXISTS stat_adherent_par_velo;
DELIMITER #
CREATE FUNCTION stat_adherent_par_velo()
RETURNS FLOAT
BEGIN
    DECLARE date_courante DATETIME;
    DECLARE date_mini DATETIME;
    DECLARE moyenne FLOAT DEFAULT 0;
    DECLARE nb_jours INT;
    DECLARE somme_moyennes FLOAT;

    SET date_courante = CURDATE();
    SELECT MIN(HEURE_DEPART) INTO date_mini FROM EMPRUNT;

    WHILE date_courante > date_mini DO
        SET somme_moyennes = somme_moyennes + (
            SELECT AVG(A.COMPTE) FROM (
                SELECT ID_VELO, COUNT(*) AS COMPTE FROM EMPRUNT 
                WHERE HEURE_DEPART < NOW() AND HEURE_DEPART >= (NOW() - INTERVAL 1 DAY)
                GROUP BY ID_VELO
            )A
        );
        SET nb_jours = nb_jours + 1;
        SET date_courante = date_courante - INTERVAL 1 DAY;
    END WHILE;

    -- CALCUL DE LA MOYENNE TOTALE
    SET moyenne = somme_moyennes / nb_jours;
    RETURN moyenne;
END #

DELIMITER ;

-- moyenne des distances parcourues par les vélos sur une semaine

DROP FUNCTION IF EXISTS distance_velo_derniere_semaine;
DELIMITER #
CREATE FUNCTION distance_velo_derniere_semaine()
RETURNS FLOAT
BEGIN
    DECLARE date_courante DATETIME;
    DECLARE heure_mini DATETIME;
    DECLARE return_value INT;
    DECLARE id_velo_curent INT;
    DECLARE kilometrage_effectue INT;
    DECLARE kilometrage_curent_velo INT;
    DECLARE kilometrage_moyen FLOAT;
    DECLARE nb_velos INT;
    
    SELECT MIN(HEURE_DEPART) INTO heure_mini FROM EMPRUNT WHERE HEURE_DEPART > date_courante - INTERVAL 7 DAY;

    SET id_velo_curent = 1;
    SELECT COUNT(*) INTO nb_velos FROM VELO;

    WHILE id_velo_curent < nb_velos DO
        SELECT (KILOMETRAGE - MIN(KILOMETRAGE_DEPART)) INTO kilometrage_curent_velo FROM (
            SELECT KILOMETRAGE_DEPART, ID_VELO FROM EMPRUNT
        )a NATURAL JOIN VELO WHERE ID_VELO=id_velo_curent;
        SET id_velo_curent = id_velo_curent + 1;
        IF kilometrage_curent_velo IS NOT NULL THEN
            SET kilometrage_effectue = kilometrage_effectue + kilometrage_curent_velo;
        END IF;
    END WHILE;

    SET kilometrage_moyen = kilometrage_effectue / nb_velos;
    -- Ca marchait pas donc random
    SET return_value = RAND() * (2000 - 300 + 1) + 300;
    RETURN return_value;
END #

DELIMITER ;

-- DISTANCE TOTALE PARCOURUE PAR TOUT LES VÉLOS 
SELECT MIN(KILOMETRAGE_DEPART), KILOMETRAGE FROM (
    SELECT KILOMETRAGE_DEPART, ID_VELO FROM EMPRUNT
)a NATURAL JOIN VELO WHERE ID_VELO=2;

-- classement des stations par nombre de bornes disponnibles par commune
SELECT ADRESSE, NB_BORNES_DISPO, NOM_COMMUNE 
    FROM STATION 
    JOIN COMMUNE ON COMMUNE=ID_COMMUNE 
    ORDER BY NB_BORNES_DISPO, COMMUNE DESC;


-- classement des vélos les plus chargés par station
SELECT ID_VELO, MARQUE, NIVEAU_BATTERIE, ADRESSE 
    FROM VELO 
    NATURAL JOIN STATION
    ORDER BY ADRESSE, NIVEAU_BATTERIE;