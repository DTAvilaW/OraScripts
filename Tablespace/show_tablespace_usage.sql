----------------------------------------------------------------------------------------
--
-- File name:     show_tablespace_usage.sql
--
-- Purpose:       Show tablespace usage
--
-- Author:        Daniel T. Avila
--
-- Date/Version:  07/02/2018 version 1.0
--
-- Usage:         @show_tablespace_usage.sql
--
-- Example:       @show_tablespace_usage.sql
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
set pagesize 10000
set trimspool on

break on report
compute sum of mb_alloc on report
compute sum of mb_used on report
compute sum of mb_free on report
compute sum of mb_max on report
compute sum of totfreemb on report

col tablespace_name format a25          	heading 'Tablespace Name'
col mb_max          format 99G999G990    	heading 'Max Size of TS'
col totfreemb       format 99G999G990   	heading 'Max Space Free'
col totpct_free     format 990D9        	heading '% Max Size Free'

col mb_alloc        format 99G999G990   	heading 'Space Allocated'
col mb_used         format 99G999G990    	heading 'Allocated Used'
col mb_free         format 99G999G990    	heading 'Allocated Free'
col pct_free        format 990D9        	heading '% Allocated Free'

select a.tablespace_name,
       round(maxbytes/1048576 ) mb_Max,
       round(maxbytes/1048576) - ((a.bytes_alloc - nvl(b.bytes_free, 0)) / 1024 / 1024 ) totfreemb,
       100 - round(( ((a.bytes_alloc - nvl(b.bytes_free, 0)) / (maxbytes) ) * 100),2) totPct_free,
       round(a.bytes_alloc / 1024 / 1024  ) mb_alloc,
       round((a.bytes_alloc - nvl(b.bytes_free, 0)) / 1024 / 1024 ) mb_used,
       round(nvl(b.bytes_free, 0) / 1024 / 1024 ) mb_free,
       round(((nvl(b.bytes_free, 0) / a.bytes_alloc) * 100),2) Pct_Free
from  ( select  f.tablespace_name,
               sum(f.bytes) bytes_alloc,
               sum(decode(f.autoextensible, 'YES',f.maxbytes,'NO', f.bytes)) maxbytes
        from dba_data_files f
        group by tablespace_name) a,
      ( select  f.tablespace_name,
               sum(f.bytes)  bytes_free
        from dba_free_space f
        group by tablespace_name) b
where a.tablespace_name = b.tablespace_name (+)
order by totPct_free;
