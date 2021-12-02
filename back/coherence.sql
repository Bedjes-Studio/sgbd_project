-- Creation d'emprunt
DELIMITER #
CREATE TRIGGER creation_emprunt
AFTER INSERT ON EMPRUNT FOR EACH ROW
BEGIN
    DECLARE DATE_EMPRUNT DATE;
    DECLARE KILOMETRAGE_DEP INTEGER;
    DECLARE STATION_DEPART INTEGER;

    SELECT KILOMETRAGE, ID_STATION INTO KILOMETRAGE_DEP, STATION_DEPART
    FROM VELO;-- WHERE EMPRUNT.ID_VELO=NEW.ID_VELO;

    IF KILOMETRAGE_DEP != KILOMETRAGE_DEPART THEN
        UPDATE EMPRUNT
        SET EMPRUNT.KILOMETRAGE_DEPART=KILOMETRAGE_DEP;
        -- WHERE EMPRUNT.ID_VELO=NEW.ID_VELO;
    END IF;

    -- UPDATE STATION
    -- SET NB_BORNES_DISPO=NB_BORNES_DISPO-1
    -- WHERE ID_STATION=STATION_DEPART;

    -- -- A VOIR PLUS TARD
    -- UPDATE EMPRUNT
    -- SET DATE_EMPRUNT=NOW()
    -- WHERE ID_EMPRUNT=NEW.ID_EMPRUNT;

END #

-- Rendu d'un velo


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

-- CREATE TRIGGER new_station BEFORE
-- INSERT
--     ON STATION FOR EACH ROW
--     BEGIN
-- UPDATE STATION
-- SET
--     NB_BORNES_DISPO = NB_BORNES
--     WHERE ID_STATION=NEW.ID_STATION;

-- END # 


 -- 


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

    SELECT HEURE_DEPART INTO DATE_EMPRUNT_VOULU
    FROM EMPRUNT WHERE ID_EMPRUNT=NEW.ID_EMPRUNT;

    -- IF DATE_EMPRUNT_VOULU < MISE_EN_SERVICE THEN
    --     -- RAISE ERROR
    -- END IF;
END #
-- DATE RENDU APRÈS DATE D'EMPRUNT

-- 

DELIMITER ;