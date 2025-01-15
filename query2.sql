SELECT TOP 10 * FROM playstore; 

SELECT Category, AVG(Rating)
from playstore;

BEGIN TRANSACTION
ALTER TABLE playstore

EXEC sp_updatestats;

ALTER INDEX ALL ON playstore REBUILD;

