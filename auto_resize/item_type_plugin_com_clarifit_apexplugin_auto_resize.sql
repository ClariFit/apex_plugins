set define off
set verify off
set serveroutput on size 1000000
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
begin wwv_flow.g_import_in_progress := true; end; 
/
 
--       AAAA       PPPPP   EEEEEE  XX      XX
--      AA  AA      PP  PP  EE       XX    XX
--     AA    AA     PP  PP  EE        XX  XX
--    AAAAAAAAAA    PPPPP   EEEE       XXXX
--   AA        AA   PP      EE        XX  XX
--  AA          AA  PP      EE       XX    XX
--  AA          AA  PP      EEEEEE  XX      XX
prompt  Set Credentials...
 
begin
 
  -- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040000 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,1252528927987481));
 
end;
/

begin wwv_flow.g_import_in_progress := true; end;
/
begin 

select value into wwv_flow_api.g_nls_numeric_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';

end;

/
begin execute immediate 'alter session set nls_numeric_characters=''.,''';

end;

/
begin wwv_flow.g_browser_language := 'en'; end;
/
prompt  Check Compatibility...
 
begin
 
-- This date identifies the minimum version required to import this file.
wwv_flow_api.set_version(p_version_yyyy_mm_dd=>'2010.05.13');
 
end;
/

prompt  Set Application ID...
 
begin
 
   -- SET APPLICATION ID
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,111);
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
 
end;
/

prompt  ...plugins
--
--application/shared_components/plugins/item_type/com_clarifit_apexplugin_auto_resize
 
begin
 
wwv_flow_api.create_plugin (
  p_id => 2438802035566693 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_type => 'ITEM TYPE'
 ,p_name => 'COM.CLARIFIT.APEXPLUGIN.AUTO_RESIZE'
 ,p_display_name => 'ClariFit Auto Resize'
 ,p_image_prefix => '#PLUGIN_PREFIX#'
 ,p_plsql_code => 
'-- *** Auto Resize ***'||chr(10)||
'-- Developed By ClariFit: http://www.ClariFit.com'||chr(10)||
'-- Based on: http://james.padolsey.com/javascript/jquery-plugin-autoresize/'||chr(10)||
''||chr(10)||
'c_version   CONSTANT VARCHAR2 (10) := ''_1.04''; -- When updating makesure the filenames all are suffixed with this version number'||chr(10)||
''||chr(10)||
'FUNCTION render_autoresize (p_item                  IN apex_plugin.t_page_item,'||chr(10)||
'                            p_plugin    '||
'            IN apex_plugin.t_plugin,'||chr(10)||
'                            p_value                 IN VARCHAR2,'||chr(10)||
'                            p_is_readonly           IN BOOLEAN,'||chr(10)||
'                            p_is_printer_friendly   IN BOOLEAN)'||chr(10)||
'  RETURN apex_plugin.t_page_item_render_result'||chr(10)||
'AS'||chr(10)||
'  v_result             apex_plugin.t_page_item_render_result;'||chr(10)||
'  v_name               p_item.name%TYPE;'||chr(10)||
''||chr(10)||
'  -- Plugin Para'||
'meters'||chr(10)||
'  v_animate            apex_application_page_items.attribute_02%TYPE := p_item.attribute_02;'||chr(10)||
'  v_animate_duration   apex_application_page_items.attribute_03%TYPE := p_item.attribute_03;'||chr(10)||
'  v_extra_space        apex_application_page_items.attribute_05%TYPE := p_item.attribute_05;'||chr(10)||
'  v_limit              apex_application_page_items.attribute_06%TYPE := p_item.attribute_06;'||chr(10)||
''||chr(10)||
'BEGIN'||chr(10)||
'  -- Debug'||chr(10)||
'  I'||
'F apex_application.g_debug THEN'||chr(10)||
'    apex_plugin_util.debug_page_item (p_plugin                => p_plugin,'||chr(10)||
'                                      p_page_item             => p_item,'||chr(10)||
'                                      p_value                 => p_value,'||chr(10)||
'                                      p_is_readonly           => p_is_readonly,'||chr(10)||
'                                      p_is_printer_friendly   => p'||
'_is_printer_friendly);'||chr(10)||
'  END IF;'||chr(10)||
''||chr(10)||
'  -- Handle Read Only and Printer Friendly'||chr(10)||
'  IF p_is_readonly'||chr(10)||
'  OR  p_is_printer_friendly THEN'||chr(10)||
'    -- emit hidden field if necessary'||chr(10)||
'    apex_plugin_util.print_hidden_if_readonly (p_item_name             => p_item.name,'||chr(10)||
'                                               p_value                 => p_value,'||chr(10)||
'                                               p_is_readonly   '||
'        => p_is_readonly,'||chr(10)||
'                                               p_is_printer_friendly   => p_is_printer_friendly);'||chr(10)||
'    -- emit display span with the value'||chr(10)||
'    apex_plugin_util.print_display_only (p_item_name          => p_item.name,'||chr(10)||
'                                         p_display_value      => p_value,'||chr(10)||
'                                         p_show_line_breaks   => FALSE,'||chr(10)||
'            '||
'                             p_escape             => TRUE,'||chr(10)||
'                                         p_attributes         => p_item.element_attributes);'||chr(10)||
'  ELSE'||chr(10)||
'    -- Not Read Only'||chr(10)||
'    -- Get name'||chr(10)||
'    v_name := apex_plugin.get_input_name_for_page_item (p_is_multi_value => FALSE);'||chr(10)||
'    -- Open text area'||chr(10)||
'    sys.htp.'||chr(10)||
'     p ('||chr(10)||
'         ''<textarea  name="'''||chr(10)||
'      || v_name'||chr(10)||
'      || ''" id="'''||chr(10)||
'      || p_it'||
'em.name'||chr(10)||
'      || ''" cols="'''||chr(10)||
'      || p_item.element_width'||chr(10)||
'      || ''" rows="'''||chr(10)||
'      || p_item.element_height'||chr(10)||
'      || ''" style="display:block;" '' -- display:block required for animation'||chr(10)||
'      || p_item.element_attributes'||chr(10)||
'      || ''>'');'||chr(10)||
''||chr(10)||
'    -- Print Value'||chr(10)||
'    sys.htp.escape_sc (p_value);'||chr(10)||
''||chr(10)||
'    -- Close Textarea'||chr(10)||
'    sys.htp.p (''</textarea>'');'||chr(10)||
''||chr(10)||
'    -- Load JavaScript'||chr(10)||
'    apex_javascript.add_library ('||
'p_name => ''autoresize.jquery.min'', p_directory => p_plugin.file_prefix, p_version => c_version);'||chr(10)||
''||chr(10)||
'    -- Run onLoad code'||chr(10)||
'    apex_javascript.'||chr(10)||
'     add_onload_code ('||chr(10)||
'      p_code =>   '''||chr(10)||
'  $("#'''||chr(10)||
'               || p_item.name'||chr(10)||
'               || ''").autoResize({'''||chr(10)||
'               || ''onResize: function(){$(this).trigger("onresize");}, '' -- Trigger the onresize event'||chr(10)||
'               || ''animate: '''||chr(10)||
'        '||
'       || v_animate'||chr(10)||
'               || '', animateDuration: '''||chr(10)||
'               || v_animate_duration'||chr(10)||
'               || '', animateCallback: function(){$(this).trigger("animatecallback");}, '''||chr(10)||
'               -- Trigger the animatecallback event'||chr(10)||
'               || ''extraSpace : '''||chr(10)||
'               || v_extra_space'||chr(10)||
'               || '',  limit: '''||chr(10)||
'               || v_limit'||chr(10)||
'               || '''||chr(10)||
'  });'||chr(10)||
'  '');'||chr(10)||
''||chr(10)||
'    --'||
' Tell APEX that this field is navigable'||chr(10)||
'    v_result.is_navigable := TRUE;'||chr(10)||
'  END IF; -- Read Only'||chr(10)||
''||chr(10)||
'  RETURN v_result;'||chr(10)||
'END render_autoresize;'
 ,p_render_function => 'render_autoresize'
 ,p_standard_attributes => 'VISIBLE:SESSION_STATE:READONLY:SOURCE:ELEMENT:WIDTH:HEIGHT:ENCRYPT'
 ,p_help_text => '<p>'||chr(10)||
'	The textarea will expand when required until the limit is reached, at which time it brings back the scrollbar. If you were to then delete all the contents of the textarea it would only return to it&#39;s original size (no smaller).</p>'||chr(10)||
'<p>'||chr(10)||
'	This will create 2 events available for Dynamic Actions:<br />'||chr(10)||
'	<br />'||chr(10)||
'	<strong>onResize</strong> - Fired every time the textarea is resized. Within the function &#39;this&#39; refers to the textarea being resized.<br />'||chr(10)||
'	<strong>animateCallback</strong>&nbsp;Fired every time an animation completes. Note: not the same as the <code>onResize</code> callback.</p>'||chr(10)||
''
 ,p_version_identifier => '1.0'
 ,p_about_url => 'http://www.clarifit.com'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 2443420238811313 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 2438802035566693 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Animate'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'true'
 ,p_is_translatable => false
 ,p_help_text => 'If set to Yes no animation will take place, the height will immediately change when necessary. By default it''s set to Yes'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 2444023008812134 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 2443420238811313 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Yes'
 ,p_return_value => 'true'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 2444425086812638 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 2443420238811313 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'No'
 ,p_return_value => 'false'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 2452509058242014 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 2438802035566693 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'Animate Duration'
 ,p_attribute_type => 'INTEGER'
 ,p_is_required => true
 ,p_default_value => '150'
 ,p_display_length => 3
 ,p_max_length => 3
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 2443420238811313 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => 'true'
 ,p_help_text => 'Millisecond duration of animation, by default it''s set to 150.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 2451011004233131 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 2438802035566693 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 5
 ,p_display_sequence => 50
 ,p_prompt => 'Extra Space'
 ,p_attribute_type => 'INTEGER'
 ,p_is_required => true
 ,p_default_value => '20'
 ,p_display_length => 3
 ,p_max_length => 3
 ,p_is_translatable => false
 ,p_help_text => 'A pixel value to be added to the total necessary height when applied to the textarea. By default it''s set to 20. The idea behind this is to reassure users that they have more space to continue writing.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 2462130101893266 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 2438802035566693 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 6
 ,p_display_sequence => 60
 ,p_prompt => 'Limit'
 ,p_attribute_type => 'INTEGER'
 ,p_is_required => true
 ,p_default_value => '1000'
 ,p_display_length => 4
 ,p_max_length => 6
 ,p_is_translatable => false
 ,p_help_text => 'Once the textarea reaches this height it will stop expanding. By default it''s set to 1000.'
  );
wwv_flow_api.create_plugin_event (
  p_id => 2459323980749675 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 2438802035566693 + wwv_flow_api.g_id_offset
 ,p_name => 'animatecallback '
 ,p_display_name => 'animateCallback '
  );
wwv_flow_api.create_plugin_event (
  p_id => 2456729817446671 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 2438802035566693 + wwv_flow_api.g_id_offset
 ,p_name => 'onresize'
 ,p_display_name => 'onResize'
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A202A206A5175657279206175746F526573697A6520287465787461726561206175746F2D726573697A6572290A202A2040636F70797269676874204A616D6573205061646F6C73657920687474703A2F2F6A616D65732E7061646F6C7365792E63';
wwv_flow_api.g_varchar2_table(2) := '6F6D0A202A204076657273696F6E20312E30340A202A2F0A0A2866756E6374696F6E2861297B612E666E2E6175746F526573697A653D66756E6374696F6E286A297B76617220623D612E657874656E64287B6F6E526573697A653A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(3) := '297B7D2C616E696D6174653A747275652C616E696D6174654475726174696F6E3A3135302C616E696D61746543616C6C6261636B3A66756E6374696F6E28297B7D2C657874726153706163653A32302C6C696D69743A313030307D2C6A293B746869732E';
wwv_flow_api.g_varchar2_table(4) := '66696C7465722827746578746172656127292E656163682866756E6374696F6E28297B76617220633D612874686973292E637373287B726573697A653A276E6F6E65272C276F766572666C6F772D79273A2768696464656E277D292C6B3D632E68656967';
wwv_flow_api.g_varchar2_table(5) := '687428292C663D2866756E6374696F6E28297B766172206C3D5B27686569676874272C277769647468272C276C696E65486569676874272C27746578744465636F726174696F6E272C276C657474657253706163696E67275D2C683D7B7D3B612E656163';
wwv_flow_api.g_varchar2_table(6) := '68286C2C66756E6374696F6E28642C65297B685B655D3D632E6373732865297D293B72657475726E20632E636C6F6E6528292E72656D6F7665417474722827696427292E72656D6F76654174747228276E616D6527292E637373287B706F736974696F6E';
wwv_flow_api.g_varchar2_table(7) := '3A276162736F6C757465272C746F703A302C6C6566743A2D393939397D292E6373732868292E617474722827746162496E646578272C272D3127292E696E736572744265666F72652863297D2928292C693D6E756C6C2C673D66756E6374696F6E28297B';
wwv_flow_api.g_varchar2_table(8) := '662E6865696768742830292E76616C28612874686973292E76616C2829292E7363726F6C6C546F70283130303030293B76617220643D4D6174682E6D617828662E7363726F6C6C546F7028292C6B292B622E657874726153706163652C653D6128746869';
wwv_flow_api.g_varchar2_table(9) := '73292E6164642866293B696628693D3D3D64297B72657475726E7D693D643B696628643E3D622E6C696D6974297B612874686973292E63737328276F766572666C6F772D79272C2727293B72657475726E7D622E6F6E526573697A652E63616C6C287468';
wwv_flow_api.g_varchar2_table(10) := '6973293B622E616E696D6174652626632E6373732827646973706C617927293D3D3D27626C6F636B273F652E73746F7028292E616E696D617465287B6865696768743A647D2C622E616E696D6174654475726174696F6E2C622E616E696D61746543616C';
wwv_flow_api.g_varchar2_table(11) := '6C6261636B293A652E6865696768742864297D3B632E756E62696E6428272E64796E53697A27292E62696E6428276B657975702E64796E53697A272C67292E62696E6428276B6579646F776E2E64796E53697A272C67292E62696E6428276368616E6765';
wwv_flow_api.g_varchar2_table(12) := '2E64796E53697A272C67297D293B72657475726E20746869737D7D29286A5175657279293B';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 2440828258706994 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 2438802035566693 + wwv_flow_api.g_id_offset
 ,p_file_name => 'autoresize.jquery.min_1.04.js'
 ,p_mime_type => 'application/x-javascript'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

commit;
begin 
execute immediate 'begin dbms_session.set_nls( param => ''NLS_NUMERIC_CHARACTERS'', value => '''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''','''''''''''') || ''''''''); end;';
end;
/
set verify on
set feedback on
prompt  ...done
