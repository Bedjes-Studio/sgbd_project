/*
Tous les vélos de la station 1
*/
SELECT *
FROM VELO
WHERE ID_STATION=1;

/*
Tous les vélos actuellement empruntés
*/
SELECT ID_VELO,
         MARQUE,
         KILOMETRAGE
FROM VELO NATURAL
JOIN EMPRUNT
WHERE HEURE_RENDU IS NULL;

/*
Tous les adhérents de la commune 1
*/
SELECT id_adherent,
         NOM,
         COMMUNE
FROM ADHERENT
NATURAL JOIN COMMUNE
WHERE ADHERENT.COMMUNE = COMMUNE.ID_COMMUNE
AND COMMUNE.ID_COMMUNE=1;

/*
Les adhérents qui ont emprunté plus d'une fois un même vélo
*/
SELECT NOM,
       ID_VELO,
         COUNT(ID_VELO)
FROM ADHERENT
NATURAL JOIN EMPRUNT
NATURAL JOIN VELO
GROUP BY ID_ADHERENT
HAVING COUNT(ID_VELO) >= 2;
