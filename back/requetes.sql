-- Tout les vélos de la station 1
SELECT *
FROM VELO
WHERE ID_STATION=1;

-- Tout les vélos actuellement empruntés

SELECT ID_VELO,
         MARQUE,
         KILOMETRAGE
FROM VELO NATURAL
JOIN EMPRUNT
WHERE HEURE_DEPART IS NULL;

-- Tous les adhérents de la commune 1

SELECT id_adherent,
         NOM,
         COMMUNE
FROM ADHERENT
NATURAL JOIN COMMUNE
WHERE ADHERENT.COMMUNE = COMMUNE.ID_COMMUNE
AND COMMUNE.ID_COMMUNE=1;


-- Les adhérents qui ont emprunté plus d'une fois un même vélo
SELECT NOM,
       ID_VELO,
         COUNT(ID_VELO)
FROM ADHERENT
NATURAL JOIN EMPRUNT
NATURAL JOIN VELO
GROUP BY ID_ADHERENT
HAVING COUNT(ID_VELO) >= 2;

---- Statistiques 
-- moyenne du nombre d'usagers par vélo par jour


-- moyenne des distances parcourues par les vélos sur une semaine


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