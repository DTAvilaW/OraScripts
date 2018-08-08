----------------------------------------------------------------------------------------
--
-- File name:     show_segment_size.sql
--
-- Purpose:       Show total database size detailed by storage component
--
-- Author:        Daniel T. Avila
--
-- Date/Version:  08/08/2018 version 1.0
--
-- Usage:         @show_segment_size.sql
--                
-- Example:       @show_segment_size.sql
--
--  Notes:     
-- 
--    Modified            MM/DD/YYYY
--    Daniel T. Avila     08/08/2018     
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

set termout on
set echo on
set timing on
set time off
set trimspool on
set linesize 1000
set pagesize 50000
set verify off
set define "&"
set serveroutput on size 1000000

column owner format a30
column segment_name format a40
column segment_type format a20

select owner
     , segment_name
	 , segment_type
	 , sum(bytes)/1024/1024 sizeMB
	 , sum(bytes)/1024/1024/1024 sizeGB
from dba_segments
where 1 = 1
and owner = '&OWNER'
and segment_name = '&SEGMENT_NAME'
group by owner, segment_name, segment_type;
