-- Optimize index maintenance to improve query performance and reduce resource consumption
-- You can reduce index fragmentation and increase page density by using one of the following methods:
-- (a) Reorganize an index
-- (b) Rebuild an index

-- check the fragmentation and page density of a rowstore index using Transact-SQL
-- the below example determines the average fragmentation and page density for all rowstore indexes in the current database
-- uses the SAMPLED mode to return actionable results quickly.
-- or more accurate results, use the DETAILED mode. This requires scanning all index pages, and may take a long time.
SELECT OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
       OBJECT_NAME(ips.object_id) AS object_name,
       i.name AS index_name,
       i.type_desc AS index_type,
       ips.avg_fragmentation_in_percent,
       ips.avg_page_space_used_in_percent,
       ips.page_count,
       ips.alloc_unit_type_desc
FROM sys.dm_db_index_physical_stats(DB_ID(), default, default, default, 'SAMPLED') AS ips
INNER JOIN sys.indexes AS i 
ON ips.object_id = i.object_id
   AND
   ips.index_id = i.index_id
ORDER BY page_count DESC;



-- check the fragmentation of a columnstore index using Transact-SQL
-- the below example determines the average fragmentation for all columnstore indexes with compressed row groups in the current database.
SELECT OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
       OBJECT_NAME(i.object_id) AS object_name,
       i.name AS index_name,
       i.type_desc AS index_type,
       100.0 * (ISNULL(SUM(rgs.deleted_rows), 0)) / NULLIF(SUM(rgs.total_rows), 0) AS avg_fragmentation_in_percent
FROM sys.indexes AS i
INNER JOIN sys.dm_db_column_store_row_group_physical_stats AS rgs
ON i.object_id = rgs.object_id
   AND
   i.index_id = rgs.index_id
WHERE rgs.state_desc = 'COMPRESSED'
GROUP BY i.object_id, i.index_id, i.name, i.type_desc
ORDER BY schema_name, object_name, index_name, index_type;


-- T-SQL Query to reorganize an index
-- The example below reorganizes the IX_NamedIndexNode index on the dbo.TblNamed table in the database.
ALTER INDEX IX_NamedIndexNode
    ON dbo.TblNamed
    REORGANIZE;

-- T-SQL Query to reorganize an index
-- example reorganizes the IndNamedIndexNodeXL_CCI columnstore index on the dbo.TblNamedXL_CCI table in the database.
-- This command will force all closed and open row groups into columnstore.
ALTER INDEX IndNamedIndexNodeXL_CCI
    ON TblNamedXL_CCI
    REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);

-- T-SQL Query To reorganize all indexes in a table