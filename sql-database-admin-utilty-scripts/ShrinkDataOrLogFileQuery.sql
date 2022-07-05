-- Shrink the size of a data file named DataFile1 in the UserDB database to 7 MB.
USE UserDB;
GO
DBCC SHRINKFILE (DataFile1, 7);
GO

-- Reduces the size of the data and log files in the UserDB user database to allow for 10 percent free space in the database.
DBCC SHRINKDATABASE (UserDB, 10);  
GO  

-- Shrinks the data and log files in the AdventureWorks sample database to the last assigned extent.
DBCC SHRINKDATABASE (AdventureWorks2012, TRUNCATEONLY);  

-- reduce the size of the data and log files in the AdventureWorks2022 database to allow for 20% free space in the database.
--- If a lock cannot be obtained within one minute, the shrink operation will abort.
DBCC SHRINKDATABASE ([AdventureWorks2022], 20) WITH WAIT_AT_LOW_PRIORITY (ABORT_AFTER_WAIT = SELF);