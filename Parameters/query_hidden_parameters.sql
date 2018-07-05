----------------------------------------------------------------------------------------
--
-- File name:     query_hidden_parameters.sql
--
-- Purpose:       Query for Oracle instance hidden parameter value
--
-- Author:        Daniel T. Avila
--
-- Date/Version:  07/05/2018 version 1.0
--
-- Usage:         Run as SYS or DBA account
--                @query_hidden_parameters.sql
--                <inform parameter name>
--
-- Example:       @query_hidden_parameters.sql
--
--  Notes:     
-- 
--    Modified            MM/DD/YYYY
--    Daniel T. Avila     07/05/2018     
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
set trimspool on
set trim on
column name format a30
column value format a30
column description format a40
select a.ksppinm name
      ,b.ksppstvl value
      ,b.ksppstdf deflt
      ,decode(a.ksppity, 1,'boolean', 2,'string', 3,'number', 4,'file', a.ksppity) type
      ,a.ksppdesc description
from  sys.x$ksppi a
     ,sys.x$ksppcv b
where 1 = 1
and a.indx = b.indx
and a.ksppinm like '\_%&PARM_NAME%' escape '\'
order by name;
