SELECT *
FROM VELO
WHERE ID_STATION=1;

SELECT ID_VELO,
         MARQUE,
         KILOMETRAGE
FROM VELO NATURAL
JOIN EMPRUNT
WHERE HEURE_RENDU IS NULL;

SELECT id_adherent,
         nom,
         prenom,
         NOM_COMMUNE
FROM ADHERENT 
NATURAL JOIN COMMUNE
WHERE ID_COMMUNE=1;

SELECT NOM,
         PRENOM,
         COUNT(ID_VELO)
FROM ADHERENT 
NATURAL JOIN EMPRUNT 
NATURAL JOIN VELO
GROUP BY ID_ADHERENT HAVING COUNT(ID_VELO) >= 2;