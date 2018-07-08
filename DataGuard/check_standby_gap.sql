----------------------------------------------------------------------------------------
--
-- File name:     check_standby_gap.sql
--
-- Purpose:       Check standby database gap to primary per thread and print total
--
-- Author:        Daniel T. Avila
--
-- Date/Version:  07/02/2018 version 1.0
--
-- Usage:         Run in standby database side
--                @check_standby_gap.sql
--                
-- Example:       @check_standby_gap.sql
--
--  Notes:     
-- 
--    Modified            MM/DD/YYYY
--    Daniel T. Avila     07/08/2018     
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

SET LINES 800
SET PAGESIZE 10000
BREAK ON REPORT
COMPUTE SUM LABEL TOTAL OF GAP ON REPORT
select primary.thread#
     , primary.maxsequence primaryseq
     , standby.maxsequence standbyseq
     , primary.maxsequence - standby.maxsequence gap
from ( select thread#, max(sequence#) maxsequence from v$archived_log where archived = 'YES' and resetlogs_change# = ( select d.resetlogs_change# from v$database d ) group by thread# order by thread# ) primary,
     ( select thread#, max(sequence#) maxsequence from v$archived_log where applied = 'YES' and resetlogs_change# = ( select d.resetlogs_change# from v$database d ) group by thread# order by thread# ) standby
where primary.thread# = standby.thread#;
