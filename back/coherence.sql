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
        signal sqlstate '45000' set message_text = 'Plus de place dans la station déso';
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
        signal sqlstate '45000' set message_text = 'Emprunt illegal, date d emprunt avant celle de la création du vélo';
        -- RAISE ERROR
    END IF;
END #

-- DATE RENDU APRÈS DATE D'EMPRUNT
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
--         signal sqlstate '45000' set message_text = 'Emprunt illegal, date d emprunt avant celle de la création du vélo';
--         -- RAISE ERROR
--     END IF;
-- END #


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

-- count nb_emprunt en cours avec ce vélo
    SELECT COUNT(*) INTO @nb_emprunt_en_cours FROM EMPRUNT WHERE ID_VELO = id_velo_emprunt AND HEURE_RENDU IS NULL;

    IF @nb_emprunt_en_cours > 0 THEN
        signal sqlstate '45000' set message_text = 'Un emprunt est déja en cours avec ce vélo, tu forces';
    END IF;

-- select id_station
    SELECT ID_STATION INTO @id_station_emprunt 
    FROM VELO WHERE ID_VELO=id_velo_emprunt;

-- update le nombre de bornes dispo après emprunt
    UPDATE STATION SET NB_BORNES_DISPO=NB_BORNES_DISPO+1 
    WHERE ID_STATION=@id_station_emprunt;

-- Mettre id_station à null dans le velo
    UPDATE VELO SET ID_STATION=NULL 
    WHERE ID_VELO=id_velo_emprunt;

    SELECT KILOMETRAGE INTO @kilometrage_depart_emprunt
    FROM VELO WHERE ID_VELO=id_velo_emprunt;

    INSERT INTO `EMPRUNT` (`KILOMETRAGE_DEPART`, `HEURE_DEPART`, `ID_ADHERENT`, `ID_STATION`, `ID_VELO`)
    VALUES (@kilometrage_depart_emprunt, heure_depart, id_adherent_emprunt, @id_station_emprunt, id_velo_emprunt);
    
END #

-- UPDATE VELO SET KILOMETRAGE=420 WHERE ID_VELO<3;

-- rendu d'un velo après emprunt
DROP PROCEDURE IF EXISTS rendu_emprunt;
-- DELIMITER #
CREATE PROCEDURE rendu_emprunt 
    (IN id_station_rendu INT,
    IN id_velo_emprunt INT)
BEGIN
    DECLARE heure_rendu_velo DATETIME DEFAULT NOW();
    -- DECLARE kilometrage_depart INTEGER;
    DECLARE nb_bornes_disponibles INTEGER;
    DECLARE id_emprunt_a_rendre INTEGER;

-- RECUP ID_EMPRUNT
    SELECT ID_EMPRUNT INTO @id_emprunt_a_rendre FROM EMPRUNT 
    WHERE ID_VELO=@id_velo_emprunt AND HEURE_RENDU IS NULL;

    -- check si assez de bornes dispo dans la station
    -- fAIT MARCHER EN DESSOUS
    SELECT NB_BORNES_DISPO INTO @nb_bornes_disponibles FROM STATION
    WHERE ID_STATION=id_station_rendu;
    
    -- Diminution du nombre de bornes disponnibles
    -- CA MARCHE !!
    UPDATE STATION SET NB_BORNES_DISPO=@nb_bornes_disponibles-1
    WHERE ID_STATION=id_station_rendu;

    -- Update emprunt.heure_rendu 
    UPDATE EMPRUNT SET HEURE_RENDU=@heure_rendu_velo
    WHERE ID_VELO=@id_velo_emprunt AND HEURE_RENDU IS NULL;

    -- update kilometrage et station velo
    -- MARCHE PRESQUE, JUSTE L'ADDITION MARCHE AP
    UPDATE VELO SET KILOMETRAGE = (
        SELECT KILOMETRAGE_DEPART + DISTANCE
        FROM EMPRUNT JOIN DISTANCE ON ID_STATION=ID_STATION1 
        WHERE ID_STATION2=id_station_rendu
    ) WHERE ID_VELO=@id_velo_emprunt;

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
        signal sqlstate '45000' set message_text = 'La distance entre une station et elle même doit être 0';
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

DELIMITER ;
