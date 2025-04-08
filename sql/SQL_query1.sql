--SET QUERY_GOVERNOR_COST_LIMIT 30;


ALTER TABLE playstore
ADD id INT IDENTITY(1,1);

ALTER TABLE playstore_backup
ADD id INT IDENTITY(1,1);

ALTER TABLE playstore
DROP COLUMN id;



/* possibilité de récrée une table avec Select Distinct mais à éviter(si la table est très grande) pour traiter les doublons*/

SELECT App
from playstore
WHERE App ='Roblox';



/* ALTER TABLE dbo.playstore RENAME COLUMN 'Type' TO 'Type Jeu' */


/*
SELECT * FROM dbo.playstore
*/

SELECT COUNT(*) AS TotalApplications FROM dbo.playstore_backup;
SELECT COUNT(*) AS TotalApplications FROM dbo.playstore;


Select TOP 10 * FROM playstore_backup

Select TOP 10 * FROM playstore


/*
On récupère des infos sur chaque colonnes (types, ect)
*/
    EXEC sp_help 'playstore';

    -- Sélectionner les valeurs NULL , les éliminer ou les compléter si nécéssaire 
    -- mettre de coté ces 2 valeurs (fichier data_null)

SELECT *
FROM playstore
WHERE Content_Rating IS NULL ;

SELECT *
FROM playstore
WHERE Android_Ver IS NULL ;

SELECT *
FROM playstore
WHERE Current_Ver LIKE 'NaN' ;

-- on supprime les lignes problématiques après les avoir stocker
DELETE FROM playstore 
where id=1715 OR id=3422

/*
Change le nom pour éviter les erreurs de compilation (à) l'initial c'était Type)
*/
EXEC sp_rename 'playstore.Type', 'Mode_achat', 'COLUMN';


    /* Compte et affiche le nombre de doublons */

    SELECT COUNT(*) as nb_doublons,App,Rating
    FROM dbo.playstore
    GROUP BY App,Rating
    HAVING COUNT(*)>1
    ORDER BY nb_doublons DESC
    -- Affiche le nombre total de doublons
    SELECT SUM(nb_doublons-1) AS total_doublons
    FROM (
        SELECT COUNT(*) AS nb_doublons
        FROM dbo.playstore
        GROUP BY App, Rating
        HAVING COUNT(*) > 1
        
    ) AS subquery;

BEGIN TRANSACTION;


/*Elimine les doublons, pb il élimine tout les doublons sans en garder aucun*/ 
WITH CTE AS
(
SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY App,Rating  ORDER BY id) AS row -- Important le order by pour compter chaque colonne et pas juste attribuer le total a chaque fois 
FROM playstore
)
DELETE FROM playstore
WHERE id IN (
    SELECT id
    FROM CTE
    WHERE row > 1
);

COMMIT TRANSACTION

-- ROLLBACK;




-- Je dois changer le type de Size, Installs, Price qui sont des nvarchar alors que ce sont censé être des valeurs
SELECT top 20 Size, Installs,Price
FROM playstore;

--Pour price on va prendre ceux différents de 0
SELECT DISTINCT price
FROM playstore
WHERE price !='0'


BEGIN TRANSACTION

-- Exemple : Convertir les prix en nombre
UPDATE playstore
SET Price = REPLACE(Price, '$', '');

-- change définitivement le type
ALTER TABLE playstore
ALTER COLUMN Price FLOAT;

--affiche tout sauf 0
SELECT Price
FROM playstore
WHERE Price != 0;

COMMIT TRANSACTION




Select distinct Installs
from playstore;

BEGIN TRANSACTION

--  Convertir les Installs en nombre
UPDATE playstore
SET Installs = REPLACE(Installs, '+', '');


UPDATE playstore
SET Installs = REPLACE(Installs, ',', '');

-- change définitivement le type
ALTER TABLE playstore
ALTER COLUMN Installs INT;

COMMIT TRANSACTION

EXEC sp_help 'playstore';





--Pour Size on va laissé en chaine de caractère pour la partie 'Varies with devices' 
SELECT distinct Size
from playstore;


SELECT Size,COUNT(App)
from playstore
--where size LIKE 'V%'
group by Size
order by Size DESC

BEGIN TRANSACTION

UPDATE playstore
SET Size =REPLACE(Size,'k','000')

COMMIT;

--remettre en nvarchar pour pouvoir récuperer les données du backup
ALTER TABLE playstore
ALTER COLUMN Price nvarchar(300)
;



EXEC sp_help 'playstore';
EXEC sp_help 'playstore_backup';

--annule tout ce qui est entre begin et rollback
ROLLBACK;


--Fonction qui récupère le nom de toutes les colonnes et qui effectue une même opération sur chacune (ici LIKE 'NaN)
--1465 au total dont 1460 Rating et 7 Current Ver , j'imagine qu'il doit y avoir 2 qui ont 2 NaN (4 NaN Rating dans les Current_Ver)
DECLARE @sql nvarchar(max) ='';
DECLARE @table NVARCHAR(max) ='playstore';
DECLARE @parametre NVARCHAR(MAX) = 'LIKE  ''NaN''  ';


SELECT @sql =  STRING_AGG( COLUMN_NAME + ' '+@parametre,'  OR ')
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME=@table

SET @sql = 'SELECT * FROM ' + @table + ' WHERE ' + @sql;
PRINT @sql;


EXEC sp_executesql @sql;


-------------------------------------------------------------------------------------

SELECT *
FROM playstore
WHERE Current_Ver LIKE 'NaN';
