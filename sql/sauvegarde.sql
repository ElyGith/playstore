/*création de la sauvegarde de la table, Syntaxe différente en fonction du serveur 

SELECT * INTO playstore_backup
FROM playstore;

DROP TABLE playstore_backup;
*/
SELECT COUNT(*) AS TotalApplications FROM dbo.playstore_backup;
SELECT COUNT(*) AS TotalApplications FROM dbo.playstore;

SELECT * FROM playstore_backup

--Pour vérifier que toutes les transactions sont bien fermés
SELECT * FROM sys.dm_tran_active_transactions;

DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql += 'KILL ' + CAST(session_id AS NVARCHAR) + ';'
FROM sys.dm_exec_sessions
WHERE is_user_process = 1 
  AND session_id <> @@SPID;

-- Affiche les commandes pour vérification
PRINT @sql;

-- Exécution des commandes
EXEC sp_executesql @sql;
-------------------------------------------------
--Tout ce qui sera avant sera sauvegarder
BEGIN TRANSACTION;



-- Supprime toutes les données de la table playstore
DELETE FROM dbo.playstore;

-- Copie les données depuis la table de sauvegarde
INSERT INTO dbo.playstore
SELECT * FROM dbo.playstore_backup;

COMMIT TRANSACTION

-- ROLLBACK;



EXEC sp_help 'playstore_backup';

---------------------------------------------------------------------------
--Tout ce qui sera avant sera sauvegarder
BEGIN TRANSACTION;


-- Supprime toutes les données de la table playstore
DELETE FROM dbo.playstore_backup;


-- Copie les données depuis la table de sauvegarde
INSERT INTO dbo.playstore_backup
SELECT * FROM dbo.playstore;

ROLLBACK


COMMIT TRANSACTION