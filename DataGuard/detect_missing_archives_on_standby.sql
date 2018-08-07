----------------------------------------------------------------------------------------
--
-- File name:     detect_missing_archives_on_standby.sql
--
-- Purpose:       Check missing archives on standby database causing gap
--
-- Author:        Daniel T. Avila
--
-- Date/Version:  08/07/2018 version 1.0
--
-- Usage:         Run in standby database side
--                @detect_missing_archives_on_standby.sql
--                
-- Example:       @detect_missing_archives_on_standby.sql
--
--  Notes:     
-- 
--    Modified            MM/DD/YYYY
--    Daniel T. Avila     08/07/2018     
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

-- Run this script at standby database

Declare
  --
  Cursor c_gap is
    select primary.thread#, primary.maxsequence primaryseq, standby.maxsequence standbyseq, primary.maxsequence - standby.maxsequence gap
    from ( select thread#, max(sequence#) maxsequence from v$archived_log where archived = 'YES' and resetlogs_change# = ( select d.resetlogs_change# from v$database d ) group by thread# order by thread# ) primary,
         ( select thread#, max(sequence#) maxsequence from v$archived_log where applied = 'YES' and resetlogs_change# = ( select d.resetlogs_change# from v$database d ) group by thread# order by thread# ) standby
    where primary.thread# = standby.thread#;
  --
  type t_archived_log is table of v$archived_log%rowtype index by pls_integer;
  l_archived_log t_archived_log;
  --
  v_exists number := 0;
  v_resetlogs_change number := 0; 
  v_prev_sequence number := 0;
  v_minseq number := 0;
  v_maxseq number := 0;
  --
Begin
  --
  dbms_output.put_line('Start');
  --
  select d.resetlogs_change# 
  into v_resetlogs_change
  from v$database d;
  --
  For j in c_gap loop
    --
    dbms_output.put_line('>>>> Thread#: ' || j.thread#);
    --
    select *
    bulk collect into l_archived_log
    from v$archived_log
    where 1 = 1
      and dest_id = 1
      and resetlogs_change# = v_resetlogs_change
      and thread# = j.thread#
      and sequence# >= j.standbyseq
      and name is not null;
    --
    v_minseq := 0;
    v_maxseq := 0;
    --
    For i in j.standbyseq..j.primaryseq loop
      v_exists := 0;
      for indx in 1..l_archived_log.count loop
        if l_archived_log(indx).sequence# = i then
          v_exists := 1;
        end if;
      end loop;
      if v_exists = 0 then
        if v_minseq = 0 then
          v_minseq := i;
        end if;
        if v_maxseq < i then
          v_maxseq := i;
        end if;
        --
        dbms_output.put_line('NOT FOUND thread#: ' || j.thread# || ' - sequence#: ' || i);
        --
      end if;
    end loop;
	--
	if v_minseq != 0 or v_maxseq != 0 then  
      dbms_output.put_line('<<<< Thread#: ' || j.thread# || ' missing interval minseq: ' || v_minseq || ' maxseq: ' || v_maxseq);
	else
	  dbms_output.put_line('<<<< Thread#: ' || j.thread# );
	end if;
    --
  end loop;
  --
  dbms_output.put_line('End');
  --
end;
/
