DROP TRIGGER IF EXISTS `creation_emprunt`;
DROP TRIGGER IF EXISTS `rendu_velo`;
DROP TRIGGER IF EXISTS `plus_de_place`;
DROP TRIGGER IF EXISTS `trop_tot`;

-- Creation d'emprunt
DELIMITER #
CREATE TRIGGER creation_emprunt
BEFORE INSERT ON EMPRUNT FOR EACH ROW
BEGIN
    DECLARE DATE_EMPRUNT DATE;
    DECLARE KILOMETRAGE_DEP INTEGER;
    DECLARE STATION_DEPART INTEGER;

    SELECT KILOMETRAGE, ID_STATION INTO KILOMETRAGE_DEP, STATION_DEPART
    FROM VELO WHERE ID_VELO=NEW.ID_VELO;

    SET NEW.KILOMETRAGE_DEPART = KILOMETRAGE_DEP; -- WHERE ID_EMPRUNT=NEW.ID_EMPRUNT;
    -- IF KILOMETRAGE_DEP != NEW.KILOMETRAGE_DEPART THEN
    --     UPDATE EMPRUNT SET EMPRUNT.KILOMETRAGE_DEPART = KILOMETRAGE_DEP
    --     WHERE ID_EMPRUNT=NEW.ID_EMPRUNT;
    -- END IF;
    -- UPDATE STATION
    -- SET STATION.NB_BORNES_DISPO=NB_BORNES_DISPO-1 WHERE STATION.ID_STATION=STATION_DEPART;
    -- IF NEW.HEURE_DEPART != NULL THEN
    --    UPDATE STATION
    --    SET STATION.NB_BORNES_DISPO=NB_BORNES_DISPO+1 WHERE STATION.ID_STATION=STATION_DEPART;
    -- END IF;
    -- -- A VOIR PLUS TARD
    -- UPDATE EMPRUNT
    -- SET DATE_EMPRUNT=NOW()
    -- WHERE ID_EMPRUNT=NEW.ID_EMPRUNT;

END #

-- Rendu d'un velo
-- CREATE TRIGGER rendu_velo
-- BEFORE UPDATE ON EMPRUNT FOR EACH ROW
-- BEGIN
--     DECLARE DATE_EMPRUNT DATE;
--     DECLARE KILOMETRAGE_DEP INTEGER;
--     DECLARE STATION_DEPART INTEGER;

--     SELECT KILOMETRAGE, ID_STATION INTO KILOMETRAGE_DEP, STATION_DEPART
--     FROM VELO WHERE ID_VELO=NEW.ID_VELO;

--     SET NEW.KILOMETRAGE_DEPART = KILOMETRAGE_DEP; -- WHERE ID_EMPRUNT=NEW.ID_EMPRUNT;
--     -- IF KILOMETRAGE_DEP != NEW.KILOMETRAGE_DEPART THEN
--     --     UPDATE EMPRUNT SET EMPRUNT.KILOMETRAGE_DEPART = KILOMETRAGE_DEP
--     --     WHERE ID_EMPRUNT=NEW.ID_EMPRUNT;
--     -- END IF;
--     SELECT 
--     UPDATE VELO SET KILOMETRAGE 

--     UPDATE STATION
--     SET STATION.NB_BORNES_DISPO=NB_BORNES_DISPO-1 WHERE STATION.ID_STATION=STATION_DEPART;
-- END #


-- Not enough bornes
-- CREATE TRIGGER pas_assez_de_bornes
-- BEFORE UPDATE ON STATION FOR EACH ROW
-- BEGIN
--     DECLARE 
--         NB_BORNES_TOTAL INT;
--         NB_BORNES_VIDES INT;

--     SELECT NB_BORNES INTO NB_BORNES_TOTAL
--     FROM STATION WHERE ID_STATION=NEW.ID_STATION;

--     IF NB_BORNES_TOTAL < 


-- Create new Station

CREATE TRIGGER new_station BEFORE
INSERT
ON STATION FOR EACH ROW
BEGIN
    SET NEW.NB_BORNES_DISPO = NEW.NB_BORNES;
END #

 -- INSERTION VELO

CREATE TRIGGER plus_de_place BEFORE
INSERT ON VELO FOR EACH ROW 
BEGIN 
    DECLARE NB_VELO INT DEFAULT 0;

    SELECT NB_BORNES_DISPO INTO NB_VELO
    FROM STATION WHERE ID_STATION=NEW.ID_STATION;

    IF NB_VELO > 0 THEN
        UPDATE STATION SET STATION.NB_BORNES_DISPO=NB_VELO-1
        WHERE ID_STATION=NEW.ID_STATION;
    ELSE 
        signal sqlstate '45000' set message_text = 'Plus de place dans la station d??so';
    END IF;

END #


-- EMPRUNT AVANT LA MISE EN SERVICE DU VELO
CREATE TRIGGER trop_tot
BEFORE INSERT ON EMPRUNT FOR EACH ROW
BEGIN
    DECLARE MISE_EN_SERVICE DATE;
    DECLARE DATE_EMPRUNT_VOULU DATE;

    SELECT DATE_MISE_EN_SERVICE INTO MISE_EN_SERVICE
    FROM VELO
    WHERE ID_VELO=NEW.ID_VELO;

    SELECT HEURE_RENDU INTO DATE_EMPRUNT_VOULU
    FROM EMPRUNT WHERE ID_EMPRUNT=NEW.ID_EMPRUNT;

    IF DATE_EMPRUNT_VOULU < MISE_EN_SERVICE THEN
        signal sqlstate '45000' set message_text = 'Emprunt illegal, date d emprunt avant celle de la cr??ation du v??lo';
        -- RAISE ERROR
    END IF;
END #

-- DATE RENDU APR??S DATE D'EMPRUNT
-- CREATE TRIGGER rendu_trop_tot
-- BEFORE UPDATE ON EMPRUNT FOR EACH ROW
-- BEGIN
--     DECLARE DATE_EMPRUNT_DEBUT DATE;
--     DECLARE DATE_EMPRUNT_FIN DATE;

--     SELECT HEURE_RENDU, HEURE_DEPART INTO DATE_EMPRUNT_DEBUT, DATE_EMPRUNT_FIN
--     FROM EMPRUNT
--     WHERE ID_VELO=NEW.ID_VELO;

--     SELECT HEURE_RENDU INTO DATE_EMPRUNT_VOULU
--     FROM EMPRUNT WHERE ID_EMPRUNT=NEW.ID_EMPRUNT;

--     IF DATE_EMPRUNT_VOULU < MISE_EN_SERVICE THEN
--         signal sqlstate '45000' set message_text = 'Emprunt illegal, date d emprunt avant celle de la cr??ation du v??lo';
--         -- RAISE ERROR
--     END IF;
-- END #

-- Cr??ation d'un emprunt avec une date de d??but
DROP PROCEDURE IF EXISTS creation_emprunt_timer;

CREATE PROCEDURE creation_emprunt_timer
    (IN id_adherent_emprunt INT,
    IN id_velo_emprunt INT,
    IN date_debut_emprunt DATETIME)
BEGIN
    DECLARE kilometrage_depart_emprunt INT DEFAULT 0;
    DECLARE id_station_emprunt INT;
    DECLARE nb_emprunt_en_cours INT;

-- count nb_emprunt en cours avec ce v??lo
    SELECT COUNT(*) INTO @nb_emprunt_en_cours FROM EMPRUNT WHERE ID_VELO = id_velo_emprunt AND HEURE_RENDU IS NULL;

    IF @nb_emprunt_en_cours = 0 THEN
        -- select id_station
        SELECT ID_STATION INTO @id_station_emprunt 
        FROM VELO WHERE ID_VELO=id_velo_emprunt;

        -- update le nombre de bornes dispo apr??s emprunt
        UPDATE STATION SET NB_BORNES_DISPO=NB_BORNES_DISPO+1 
        WHERE ID_STATION=@id_station_emprunt;

        -- Mettre id_station ?? null dans le velo
        UPDATE VELO SET ID_STATION=NULL 
        WHERE ID_VELO=id_velo_emprunt;

        SELECT KILOMETRAGE INTO @kilometrage_depart_emprunt
        FROM VELO WHERE ID_VELO=id_velo_emprunt;

        INSERT INTO `EMPRUNT` (`KILOMETRAGE_DEPART`, `HEURE_DEPART`, `ID_ADHERENT`, `ID_STATION`, `ID_VELO`)
        VALUES (@kilometrage_depart_emprunt, date_debut_emprunt, id_adherent_emprunt, @id_station_emprunt, id_velo_emprunt);
    -- ELSE 
    --     signal sqlstate '45000' set message_text = 'Un emprunt est d??ja en cours avec ce v??lo, tu forces';
    END IF;
    
END #

-- CREATION D'UN EMPRUNT
DROP PROCEDURE IF EXISTS creation_emprunt;
-- DELIMITER #
CREATE PROCEDURE creation_emprunt 
    (IN id_adherent_emprunt INT,
    IN id_velo_emprunt INT)
BEGIN
    DECLARE heure_depart DATETIME DEFAULT NOW();
    DECLARE kilometrage_depart_emprunt INT DEFAULT 0;
    DECLARE id_station_emprunt INT;
    DECLARE nb_emprunt_en_cours INT;

-- count nb_emprunt en cours avec ce v??lo
    SELECT COUNT(*) INTO @nb_emprunt_en_cours FROM EMPRUNT WHERE ID_VELO = id_velo_emprunt AND HEURE_RENDU IS NULL;

    IF @nb_emprunt_en_cours > 0 THEN
        signal sqlstate '45000' set message_text = 'Un emprunt est d??ja en cours avec ce v??lo, tu forces';
    END IF;

-- select id_station
    SELECT ID_STATION INTO @id_station_emprunt 
    FROM VELO WHERE ID_VELO=id_velo_emprunt;

-- update le nombre de bornes dispo apr??s emprunt
    UPDATE STATION SET NB_BORNES_DISPO=NB_BORNES_DISPO+1 
    WHERE ID_STATION=@id_station_emprunt;

-- Mettre id_station ?? null dans le velo
    UPDATE VELO SET ID_STATION=NULL 
    WHERE ID_VELO=id_velo_emprunt;

    SELECT KILOMETRAGE INTO @kilometrage_depart_emprunt
    FROM VELO WHERE ID_VELO=id_velo_emprunt;

    INSERT INTO `EMPRUNT` (`KILOMETRAGE_DEPART`, `HEURE_DEPART`, `ID_ADHERENT`, `ID_STATION`, `ID_VELO`)
    VALUES (@kilometrage_depart_emprunt, heure_depart, id_adherent_emprunt, @id_station_emprunt, id_velo_emprunt);
    
END #

-- rendu d'un velo apr??s emprunt
DROP PROCEDURE IF EXISTS rendu_emprunt;
-- DELIMITER #
CREATE PROCEDURE rendu_emprunt 
    (IN id_station_rendu INT,
    IN id_velo_emprunt INT)
BEGIN
    DECLARE heure_rendu_velo DATETIME;
    -- DECLARE kilometrage_depart INTEGER;
    DECLARE nb_bornes_disponibles INTEGER;
    DECLARE id_emprunt_a_rendre INTEGER;

    SET @heure_rendu_velo=NOW();

    -- check si assez de bornes dispo dans la station
    -- fAIT MARCHER EN DESSOUS
    SELECT NB_BORNES_DISPO INTO @nb_bornes_disponibles FROM STATION
    WHERE ID_STATION=id_station_rendu;
    
    -- Diminution du nombre de bornes disponnibles
    -- CA MARCHE !!
    UPDATE STATION SET NB_BORNES_DISPO=@nb_bornes_disponibles-1
    WHERE ID_STATION=id_station_rendu;

    -- update kilometrage et station velo
    UPDATE VELO SET KILOMETRAGE = (
        SELECT MAX(KILOMETRAGE_DEPART + DISTANCE)
        FROM EMPRUNT JOIN DISTANCE ON ID_STATION=ID_STATION1 
        WHERE ID_STATION2=id_station_rendu AND ID_VELO=1 AND HEURE_RENDU IS NULL
    ) WHERE ID_VELO=id_velo_emprunt;

    -- Update emprunt.heure_rendu 
    UPDATE EMPRUNT SET HEURE_RENDU=NOW()
    WHERE ID_VELO=id_velo_emprunt AND HEURE_RENDU IS NULL;

    -- CA MARCHE
    UPDATE VELO SET ID_STATION=id_station_rendu
    WHERE ID_VELO=id_velo_emprunt;
END #

-- rendu d'un velo apr??s emprunt ?? une date donn??e
DROP PROCEDURE IF EXISTS rendu_emprunt_timer;
-- DELIMITER #
CREATE PROCEDURE rendu_emprunt_timer
    (IN id_station_rendu INT,
    IN id_velo_emprunt INT,
    IN heure_rendu_velo DATETIME)
BEGIN
    -- DECLARE kilometrage_depart INTEGER;
    DECLARE nb_bornes_disponibles INTEGER;
    DECLARE id_emprunt_a_rendre INTEGER;


    -- check si assez de bornes dispo dans la station
    -- fAIT MARCHER EN DESSOUS
    SELECT NB_BORNES_DISPO INTO @nb_bornes_disponibles FROM STATION
    WHERE ID_STATION=id_station_rendu;
    
    -- Diminution du nombre de bornes disponnibles
    -- CA MARCHE !!
    UPDATE STATION SET NB_BORNES_DISPO=@nb_bornes_disponibles-1
    WHERE ID_STATION=id_station_rendu;

    -- Update emprunt.heure_rendu 
    UPDATE EMPRUNT SET HEURE_RENDU=heure_rendu_velo
    WHERE ID_VELO=id_velo_emprunt AND HEURE_RENDU IS NULL;

    -- update kilometrage et station velo
    UPDATE VELO SET KILOMETRAGE = (
        SELECT MAX(KILOMETRAGE_DEPART + DISTANCE)
        FROM EMPRUNT JOIN DISTANCE ON ID_STATION=ID_STATION1 
        WHERE ID_STATION2=id_station_rendu
    ) WHERE ID_VELO=id_velo_emprunt;

    -- CA MARCHE
    UPDATE VELO SET ID_STATION=id_station_rendu
    WHERE ID_VELO=id_velo_emprunt;
END #

 -- Insertion d'une distance pour rajouter la distance inverse
DROP PROCEDURE IF EXISTS distance_station;
CREATE PROCEDURE distance_station
    (IN id_station1 INT, 
    IN id_station2 INT,
    IN distance INT)
BEGIN
    IF id_station1 = id_station2 AND distance != 0 THEN
        signal sqlstate '45000' set message_text = 'La distance entre une station et elle m??me doit ??tre 0';
    END IF;
    IF id_station1 != id_station2 THEN
        INSERT INTO DISTANCE 
        VALUES (id_station1, id_station2, distance);
        INSERT INTO DISTANCE 
        VALUES (id_station2, id_station1, distance);
    ELSE
        INSERT INTO DISTANCE 
        VALUES (id_station1, id_station2, distance);
    END IF;
END #

DELIMITER #
DROP PROCEDURE IF EXISTS generation_emprunts_aleatoires;

CREATE PROCEDURE generation_emprunts_aleatoires ()

BEGIN
    DECLARE date_courante DATETIME;
    DECLARE i INT default 0;
    DECLARE id_velo_current INT default 0;
    DECLARE id_station_current INT default 0;
    DECLARE id_adherent_current INT default 0;
    DECLARE nb_emprunt_par_jour INT;
    DECLARE time_courant TIME;

    SET date_courante = CURDATE() - INTERVAL 7 DAY;
    WHILE date_courante <= CURDATE() DO
        SET i = 0;
        SET id_velo_current = 1;
        SET id_station_current = 1;
        SET id_adherent_current = 1;
        SET nb_emprunt_par_jour = ROUND (RAND() * 50);
        set time_courant = '00:00:00';

        WHILE i <= nb_emprunt_par_jour or time_courant <= '23:00:00' DO
            
            SET id_velo_current = ROUND( RAND() * ((SELECT COUNT(*) FROM VELO) - 1) + 1 );
            
            SET id_adherent_current = ROUND( RAND() * ((SELECT COUNT(*) FROM ADHERENT) - 1) + 1 );
            
            CALL creation_emprunt_timer(id_adherent_current, id_velo_current, date_courante + time_courant);

            SET id_station_current = ROUND( RAND() * ((SELECT COUNT(*) FROM STATION) - 1) + 1 );
            WHILE ((SELECT NB_BORNES_DISPO FROM STATION WHERE ID_STATION = id_station_current) = 0) DO
                SET id_station_current = ROUND( RAND() * ((SELECT COUNT(*) FROM STATION) - 1) + 1 );
            END WHILE;
            CALL rendu_emprunt_timer(id_station_current, id_velo_current, date_courante + SEC_TO_TIME(TIME_TO_SEC(time_courant) + (300 + ROUND(RAND() * 1800))));

            SET i = i + 1;
            SET time_courant = SEC_TO_TIME(TIME_TO_SEC(time_courant) + (600 + ROUND(RAND() * 2000)));
            -- END IF;
        END WHILE; -- Emprunt par jour
    SET date_courante = date_courante + INTERVAL 1 DAY;
    END WHILE; -- Date 

END #
DELIMITER ;
