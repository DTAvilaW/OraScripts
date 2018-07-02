----------------------------------------------------------------------------------------
--
-- File name:     monitor_master_and_parallel_sessions.sql
--
-- Purpose:       Monitor master and parallel sessions per sql_id
--
-- Author:        Daniel T. Avila
--
-- Date/Version:  07/02/2018 version 1.0
--
-- Usage:         @monitor_master_and_parallel_sessions.sql
--
-- Example:       @monitor_master_and_parallel_sessions.sql
--                <inform SQL_ID>
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

SELECT px.SID "SID"
       ,p.PID
       ,p.SPID "SPID"
       ,px.INST_ID "Inst"
       ,px.SERVER_GROUP "Group"
       ,px.SERVER_SET "Set"
       ,px.DEGREE "Degree"
       ,px.REQ_DEGREE "Req Degree"
       ,w.event "Wait Event"
       ,s.program
       ,s.machine
       --,'alter system kill session ''' || s.sid || ',' || s.serial# || ',@' || s.inst_id || ''' immediate;' kill_cmd
FROM GV$SESSION s,
     GV$PX_SESSION px,
     GV$PROCESS p,
     GV$SESSION_WAIT w
WHERE 1 = 1
AND s.sql_id = '&SQL_ID'
AND s.sid(+) = px.sid
AND s.inst_id(+) = px.inst_id
AND s.sid = w.sid(+)
AND s.inst_id = w.inst_id(+)
AND s.paddr = p.addr(+)
AND s.inst_id = p.inst_id(+)
ORDER BY DECODE (px.QCINST_ID, NULL, px.INST_ID, px.QCINST_ID),
         px.QCSID,
         DECODE (px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
         px.SERVER_SET,
         px.INST_ID;