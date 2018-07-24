----------------------------------------------------------------------------------------
--
-- File name:     show_database_size.sql
--
-- Purpose:       Show total database size detailed by storage component
--
-- Author:        Daniel T. Avila
--
-- Date/Version:  07/24/2018 version 1.0
--
-- Usage:         @show_database_size.sql
--                
-- Example:       @show_database_size.sql
--
--  Notes:     
-- 
--    Modified            MM/DD/YYYY
--    Daniel T. Avila     07/24/2018     
--
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
---------------------------------------------------------------------------------------

set lines 800
set pages 10000
select datafile_size_minus_undo_GB
      ,undo_datafile_size_GB
      ,tempfile_size_GB
      ,logsize_GB
      ,nvl(standby_logsize_GB,0) standby_logsize_GB
      ,controlfile_GB
      ,( datafile_size_minus_undo_GB + undo_datafile_size_GB + tempfile_size_GB + logsize_GB + nvl(standby_logsize_GB,0) + controlfile_GB ) TotalGB
from ( select round(( select sum(bytes)/1024/1024/1024 from dba_data_files where tablespace_name not like '%UNDO%' ), 2) datafile_size_minus_undo_GB
             ,round(( select sum(bytes)/1024/1024/1024 from dba_data_files where tablespace_name like '%UNDO%'     ), 2) undo_datafile_size_GB
             ,round(( select sum(bytes)/1024/1024/1024 from dba_temp_files                                         ), 2) tempfile_size_GB
             ,round(( select sum(bytes)/1024/1024/1024 from v$log                                                  ), 2) logsize_GB
             ,round(( select sum(bytes)/1024/1024/1024 from v$standby_log                                          ), 2) standby_logsize_GB
             ,round(( select sum(block_size * file_size_blks)/1024/1024/1024 from v$controlfile                    ), 2) controlfile_GB
        from dual )
where 1 = 1;
