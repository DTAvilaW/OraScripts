----------------------------------------------------------------------------------------
--
-- File name:     show_object_growth_using_awr.sql
--
-- Purpose:       Show total database size detailed by storage component
--
-- Author:        Daniel T. Avila
--
-- Date/Version:  08/06/2018 version 1.0
--
-- Usage:         @show_object_growth_using_awr.sql
--                
-- Example:       @show_object_growth_using_awr.sql
--                <inform onwer, object_name and oldest AWR snap_id available>
--
--  Notes:     
-- 
--    Modified            MM/DD/YYYY
--    Daniel T. Avila     08/06/2018     
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
set pages 1000
column BEGIN_INTERVAL_TIME format a30
column OWNER format a20
column OBJECT_NAME format a40
SELECT ss.snap_id
     , sn.begin_interval_time
     , ss.TS#
     , ss.OBJ#
     , o.owner
     , o.object_name
     , round(SUM(ss.SPACE_USED_DELTA)/(1024*1024),2) Growth_MB
FROM DBA_HIST_SEG_STAT ss
    ,DBA_HIST_SNAPSHOT sn
    ,DBA_OBJECTS o
WHERE 1 = 1
and ss.dbid = sn.dbid
and ss.snap_id = sn.snap_id
and ss.instance_number = sn.instance_number
and ss.obj# = o.object_id
and o.OWNER = '&OWNER'
and o.object_name = '&OBJECT_NAME'
and ss.snap_id > &OLDEST_SNAP_ID
GROUP BY ss.snap_id
       , sn.begin_interval_time
       , ss.TS#, ss.OBJ#
       , o.owner
       , o.object_name
HAVING SUM(SPACE_USED_DELTA) > 0
order by ss.snap_id;
