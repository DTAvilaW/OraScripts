----------------------------------------------------------------------------------------
--
-- File name:     check_instance_status.sql
--
-- Purpose:       Check Oracle instance start time, status and role
--
-- Author:        Daniel T. Avila
--
-- Date/Version:  07/02/2018 version 1.0
--
-- Usage:         @check_instance_status.sql
--
-- Example:       @check_instance_status.sql
--
--  Notes:     
-- 
--    Modified            MM/DD/YYYY
--    Daniel T. Avila     07/02/2018     
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
column host_name format a40
column starttime format a20
select i.inst_id
      ,i.instance_name
	  ,i.host_name
	  ,to_char(i.STARTUP_TIME,'MM/DD/YYYY HH24:MI:SS') starttime
	  ,i.status
	  ,d.open_mode
	  ,d.database_role
from gv$instance i,
     gv$database d
where 1 = 1
and i.inst_id = d.inst_id
order by 1;
