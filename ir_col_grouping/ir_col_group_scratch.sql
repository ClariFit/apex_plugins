select *
from apex_dictionary
where column_id = 0
and apex_view_name like '%COL%';

-- TODO to avoid context switching I may want to just calling function later on rather than in SQL statement
select '{"column_alias":"' || column_alias || '","column_group":"' ||  column_group || '"}' -- TODO call escape JSON function
from APEX_APPLICATION_PAGE_IR_COL
where application_id = 108 -- TODO replace with var
and page_id = 1  -- TODO replace with var
and column_group is not null;


-- TODO this is from APEX code need to change it up before I use it
-- TODO perhaps rename to f_json_escape
create or replace FUNCTION JSON_REPLACE(
     P_TEXT     IN VARCHAR2 DEFAULT NULL
 ) RETURN VARCHAR2 IS
     L_TEXT         VARCHAR2(32767);
 BEGIN
     L_TEXT := REPLACE(P_TEXT, '\', '\\');
     L_TEXT := REPLACE(L_TEXT, '"', '\"');
     L_TEXT := REPLACE(L_TEXT,CHR(13)||CHR(10),CHR(10));
     L_TEXT := REPLACE(L_TEXT,CHR(10)||CHR(13),CHR(10));
     L_TEXT := REPLACE(L_TEXT,CHR(10),'\n');
     RETURN L_TEXT;
 END JSON_REPLACE;
 
 
select *
from logger_logs
order by id desc; 
