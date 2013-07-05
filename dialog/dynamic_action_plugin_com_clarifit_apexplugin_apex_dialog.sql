set define off
set verify off
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
 
  -- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040100 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,10037412111408177));
 
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
wwv_flow_api.set_version(p_version_yyyy_mm_dd=>'2011.02.12');
 
end;
/

prompt  Set Application ID...
 
begin
 
   -- SET APPLICATION ID
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,106);
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
 
end;
/

prompt  ...plugins
--
--application/shared_components/plugins/dynamic_action/com_clarifit_apexplugin_apex_dialog
 
begin
 
wwv_flow_api.create_plugin (
  p_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_type => 'DYNAMIC ACTION'
 ,p_name => 'COM.CLARIFIT.APEXPLUGIN.APEX_DIALOG'
 ,p_display_name => 'ClariFit Dialog'
 ,p_category => 'EFFECT'
 ,p_image_prefix => '#PLUGIN_PREFIX#'
 ,p_plsql_code => 
' -- *** Dialog ***  '||unistr('\000a')||
'  FUNCTION f_render_dialog ('||unistr('\000a')||
'    p_dynamic_action IN apex_plugin.t_dynamic_action,'||unistr('\000a')||
'    p_plugin         IN apex_plugin.t_plugin )'||unistr('\000a')||
'    RETURN apex_plugin.t_dynamic_action_render_result'||unistr('\000a')||
'  AS'||unistr('\000a')||
'    -- Application Plugin Attributes'||unistr('\000a')||
'    v_background_color apex_appl_plugins.attribute_01%TYPE := p_plugin.attribute_01; '||unistr('\000a')||
'    v_background_opacitiy apex_appl_plugins.attribute_01%TYPE := p_'||
'plugin.attribute_02; '||unistr('\000a')||
' '||unistr('\000a')||
'    -- DA Plugin Attributes'||unistr('\000a')||
'    v_modal apex_application_page_items.attribute_01%TYPE := p_dynamic_action.attribute_01; -- y/n'||unistr('\000a')||
'    v_close_on_esc apex_application_page_items.attribute_01%TYPE := p_dynamic_action.attribute_02; -- y/n'||unistr('\000a')||
'    v_title apex_application_page_items.attribute_01%TYPE := p_dynamic_action.attribute_03; -- text'||unistr('\000a')||
'    v_hide_on_load apex_application_page_it'||
'ems.attribute_01%TYPE := upper(p_dynamic_action.attribute_04); -- y/n'||unistr('\000a')||
'    v_on_close_visible_state apex_application_page_items.attribute_01%TYPE := lower(p_dynamic_action.attribute_05); -- prev, show, hide'||unistr('\000a')||
'    v_action apex_application_page_items.attribute_01%type := lower(p_dynamic_action.attribute_06); -- open,close'||unistr('\000a')||
'        '||unistr('\000a')||
'    -- Return '||unistr('\000a')||
'    v_result apex_plugin.t_dynamic_action_render_result;'||
''||unistr('\000a')||
'    '||unistr('\000a')||
'    -- Other variables'||unistr('\000a')||
'    v_html varchar2(4000);'||unistr('\000a')||
'    v_affected_elements apex_application_page_da_acts.affected_elements%type;'||unistr('\000a')||
'    v_affected_elements_type apex_application_page_da_acts.affected_elements_type%type;'||unistr('\000a')||
'    v_affected_region_id apex_application_page_da_acts.affected_region_id%type;'||unistr('\000a')||
'    v_affected_region_static_id apex_application_page_regions.static_id%type;'||unistr('\000a')||
'    '||unistr('\000a')||
'    -- Convert '||
'Y/N to True/False (text)'||unistr('\000a')||
'    -- Default to true'||unistr('\000a')||
'    FUNCTION f_yn_to_true_false_str(p_val IN VARCHAR2)'||unistr('\000a')||
'    RETURN VARCHAR2'||unistr('\000a')||
'    AS'||unistr('\000a')||
'    BEGIN'||unistr('\000a')||
'      RETURN'||unistr('\000a')||
'        CASE '||unistr('\000a')||
'          WHEN p_val IS NULL OR lower(p_val) != ''n'' THEN ''true'''||unistr('\000a')||
'          ELSE ''false'''||unistr('\000a')||
'        END;'||unistr('\000a')||
'    END f_yn_to_true_false_str;'||unistr('\000a')||
''||unistr('\000a')||
'  BEGIN'||unistr('\000a')||
'    -- Debug information (if app is being run in debug mode)'||unistr('\000a')||
'    IF apex_application.g_debug'||
' THEN'||unistr('\000a')||
'      apex_plugin_util.debug_dynamic_action ('||unistr('\000a')||
'        p_plugin => p_plugin,'||unistr('\000a')||
'        p_dynamic_action => p_dynamic_action);'||unistr('\000a')||
'    END IF;'||unistr('\000a')||
'    '||unistr('\000a')||
'    -- Cleaup values'||unistr('\000a')||
'    v_modal := f_yn_to_true_false_str(p_val => v_modal);'||unistr('\000a')||
'    v_close_on_esc := f_yn_to_true_false_str(p_val => v_close_on_esc);'||unistr('\000a')||
''||unistr('\000a')||
'    -- If Background color is not null set the CSS'||unistr('\000a')||
'    -- This will only be done once per page'||unistr('\000a')||
'    IF v_'||
'background_color IS NOT NULL AND v_action != ''close'' THEN'||unistr('\000a')||
'      v_html := q''!'||unistr('\000a')||
'        .ui-widget-overlay{'||unistr('\000a')||
'          background-image: none ;'||unistr('\000a')||
'          background-color: %BG_COLOR%;'||unistr('\000a')||
'          opacity: %OPACITY%;'||unistr('\000a')||
'        }!'';'||unistr('\000a')||
'      '||unistr('\000a')||
'      v_html := REPLACE(v_html, ''%BG_COLOR%'', v_background_color);'||unistr('\000a')||
'      v_html := REPLACE(v_html, ''%OPACITY%'', v_background_opacitiy);'||unistr('\000a')||
''||unistr('\000a')||
'      apex_css.ADD ('||unistr('\000a')||
'        p_c'||
'ss => v_html,'||unistr('\000a')||
'        p_key => ''ui.clarifitdialog.background'');'||unistr('\000a')||
'    END IF;'||unistr('\000a')||
'    '||unistr('\000a')||
'    -- JAVASCRIPT'||unistr('\000a')||
''||unistr('\000a')||
'    -- Load javascript Libraries'||unistr('\000a')||
'    apex_javascript.add_library (p_name => ''$console_wrapper'', p_directory => p_plugin.file_prefix, p_version=> ''_1.0.3''); -- Load Console Wrapper for debugging'||unistr('\000a')||
'    apex_javascript.add_library (p_name => ''jquery.ui.clarifitDialog'', p_directory => p_plugin.file_prefix'||
', p_version=> ''_1.0.1''); '||unistr('\000a')||
'    '||unistr('\000a')||
'    -- Hide Affected Elements on Load'||unistr('\000a')||
'    IF v_hide_on_load = ''Y'' AND v_action != ''close'' THEN'||unistr('\000a')||
'      v_html := '''';'||unistr('\000a')||
'      '||unistr('\000a')||
'      SELECT affected_elements, lower(affected_elements_type), affected_region_id, aapr.static_id'||unistr('\000a')||
'      INTO v_affected_elements, v_affected_elements_type, v_affected_region_id, v_affected_region_static_id'||unistr('\000a')||
'      FROM apex_application_page_da_acts '||
'aapda, apex_application_page_regions aapr'||unistr('\000a')||
'      WHERE aapda.action_id = p_dynamic_action.ID'||unistr('\000a')||
'        AND aapda.affected_region_id = aapr.region_id(+);'||unistr('\000a')||
'      '||unistr('\000a')||
'      IF v_affected_elements_type = ''jquery selector'' THEN'||unistr('\000a')||
'        v_html := ''apex.jQuery("'' || v_affected_elements || ''").hide();'';'||unistr('\000a')||
'      ELSIF v_affected_elements_type = ''dom object'' THEN      '||unistr('\000a')||
'        v_html := ''apex.jQuery("#'' || v_affecte'||
'd_elements || ''").hide();'';'||unistr('\000a')||
'      ELSIF v_affected_elements_type = ''region'' THEN      '||unistr('\000a')||
'        v_html := ''apex.jQuery("#'' || nvl(v_affected_region_static_id, ''R'' || v_affected_region_id) || ''").hide();'';'||unistr('\000a')||
'      ELSE'||unistr('\000a')||
'        -- unknown/unhandled (nothing to hide)'||unistr('\000a')||
'        raise_application_error(-20001, ''Unknown Affected Element Type'');'||unistr('\000a')||
'      END IF; -- v_affected_elements_type'||unistr('\000a')||
'     '||unistr('\000a')||
'      apex_javas'||
'cript.add_onload_code ('||unistr('\000a')||
'        p_code => v_html,'||unistr('\000a')||
'        p_key  => NULL); -- Leave null so always run'||unistr('\000a')||
'    END IF; -- v_hide_on_load'||unistr('\000a')||
'    '||unistr('\000a')||
'    -- RETURN'||unistr('\000a')||
'    if v_action = ''open'' then'||unistr('\000a')||
'      v_result.javascript_function := ''$.ui.clarifitDialog.daDialog'';'||unistr('\000a')||
'      v_result.attribute_01 := v_modal;'||unistr('\000a')||
'      v_result.attribute_02 := v_close_on_esc;'||unistr('\000a')||
'      v_result.attribute_03 := v_title;'||unistr('\000a')||
'      v_result.attrib'||
'ute_04 := v_on_close_visible_state;'||unistr('\000a')||
'    elsif v_action = ''close'' THEN'||unistr('\000a')||
'      v_result.javascript_function := ''$.ui.clarifitDialog.daClose'';'||unistr('\000a')||
'    ELSE'||unistr('\000a')||
'      raise_application_error(-20001, ''Unknown Action Type'');'||unistr('\000a')||
'    END IF;'||unistr('\000a')||
'    '||unistr('\000a')||
'    RETURN v_result;'||unistr('\000a')||
''||unistr('\000a')||
'  END f_render_dialog;'
 ,p_render_function => 'f_render_dialog'
 ,p_standard_attributes => 'REGION:DOM_OBJECT:JQUERY_SELECTOR:REQUIRED'
 ,p_substitute_attributes => true
 ,p_attribute_02 => '0.3'
 ,p_help_text => '<p>'||unistr('\000a')||
'	<strong>ClariFit Dialog</strong></p>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	Plug-in Type: Dynamic Action</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	Summary: Creates dialog and modal windows.</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	&nbsp;</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	<em><strong>Depends:</strong></em></div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	&nbsp;$.console.js &nbsp;- http://code.google.com/p/js-console-wrapper/</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	&nbsp;</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	<em><strong>Contact information</strong></em></div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	Developed by ClariFit Inc.</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	http://www.clarifit.com</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	apex@clarifit.com</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	&nbsp;</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	<em><strong>License</strong></em></div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	Licensed Under: GNU General Public License, version 3 (GPL-3.0) - http://www.opensource.org/licenses/gpl-3.0.html</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	&nbsp;</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	<strong><em>About</em></strong></div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	This plugin was highlighted in the book: Expert Oracle Application Express Plugins&nbsp;<a href="http://goo.gl/089zi">http://goo.gl/089zi</a></div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	&nbsp;</div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	<em><strong>Info</strong></em></div>'||unistr('\000a')||
'<div>'||unistr('\000a')||
'	To use this plugin, create a dynamic action and select the ClariFit Dialog plugin. The main attribute is the Action attribute. Setting this will determine to open or close the dialog/modal window. All the attributes contain help text explaining how they&#39;re used.</div>'||unistr('\000a')||
''
 ,p_version_identifier => '1.0'
 ,p_about_url => 'http://www.clarifit.com'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 5421671363193412122 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'Background Color'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_display_length => 10
 ,p_is_translatable => false
 ,p_help_text => 'Default background color for modal windows. Enter a CSS qualified color (i.e. either color name or #<span style="font-style:italic;">hex</span> value. If no color is specified then the jQuery UI theme default will be used.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Background Opacity'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => false
 ,p_default_value => '0.3'
 ,p_is_translatable => false
 ,p_help_text => 'Select the opacity of background color for modal windows.'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423111274930462824 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => '10%'
 ,p_return_value => '0.1'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423167057745467374 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => '20%'
 ,p_return_value => '0.2'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423206361901468556 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 30
 ,p_display_value => '30%'
 ,p_return_value => '0.3'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423218464672469337 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 40
 ,p_display_value => '40%'
 ,p_return_value => '0.4'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423263068827470558 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 50
 ,p_display_value => '50%'
 ,p_return_value => '0.5'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423319374368472126 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 60
 ,p_display_value => '60%'
 ,p_return_value => '0.6'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423340577139472927 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 70
 ,p_display_value => '70%'
 ,p_return_value => '0.7'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423352646795473610 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 80
 ,p_display_value => '80%'
 ,p_return_value => '0.8'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423371749565474459 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 90
 ,p_display_value => '90%'
 ,p_return_value => '0.9'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5423395852682475366 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5422725148479445773 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 100
 ,p_display_value => '100%'
 ,p_return_value => '1'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 5423812769782489806 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'Modal'
 ,p_attribute_type => 'CHECKBOX'
 ,p_is_required => false
 ,p_default_value => 'Y'
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 13337211051472055 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => 'open'
 ,p_help_text => 'Modal window or dialog window.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 5424375650782512641 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Close on Escape'
 ,p_attribute_type => 'CHECKBOX'
 ,p_is_required => false
 ,p_default_value => 'Y'
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 13337211051472055 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => 'open'
 ,p_help_text => 'If set to yes, user can hit the <span style="font-style:italic;">esc</span> key to close the window.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 5425107561910544207 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'Dialog Title'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_is_translatable => true
 ,p_depending_on_attribute_id => 13337211051472055 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => 'open'
 ,p_help_text => 'Title to appear at the top of the dialog/modal window. If the region already contains a title may want to leave this empty.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 5427019471055632019 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 4
 ,p_display_sequence => 40
 ,p_prompt => 'Hide Affected Elements on Page Load'
 ,p_attribute_type => 'CHECKBOX'
 ,p_is_required => false
 ,p_default_value => 'Y'
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 13337211051472055 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => 'open'
 ,p_help_text => 'If set to yes, the contents for the modal/dialog window will be hidden once the page is loaded. For example suppose you have "License Agreement" region which you only want to be displayed when the user clicks on a button. If you set this option to Yes then when the page is loaded the plug-in will automatically hide the "License Agreement" region for you. This saves you the hassle of having to worry about using different region templates to show/hide the region by default.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 5449737375209683424 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 5
 ,p_display_sequence => 50
 ,p_prompt => 'On Close Visible State'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'prev'
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 13337211051472055 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => 'open'
 ,p_help_text => 'Define what visibility status to set once the modal window closes. In most cases you will probably want to leave it to the default value (Previous state). '
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5449766655254687087 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5449737375209683424 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Previous (default)'
 ,p_return_value => 'prev'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5449792266336690329 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5449737375209683424 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'Show'
 ,p_return_value => 'show'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 5449832648459694571 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 5449737375209683424 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 30
 ,p_display_value => 'Hide'
 ,p_return_value => 'hide'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 13337211051472055 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 6
 ,p_display_sequence => 1
 ,p_prompt => 'Action'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'open'
 ,p_is_translatable => false
 ,p_help_text => 'Open or Close the dialog window.'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 13341813129472660 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 13337211051472055 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Open'
 ,p_return_value => 'open'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 13346114860473171 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 13337211051472055 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'Close'
 ,p_return_value => 'close'
  );
wwv_flow_api.create_plugin_event (
  p_id => 15255108085922419 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_name => 'cfpluginapexdialogbeforeclose'
 ,p_display_name => 'Before Close'
  );
wwv_flow_api.create_plugin_event (
  p_id => 15263532327929433 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_name => 'cfpluginapexdialogclose'
 ,p_display_name => 'After Close'
  );
wwv_flow_api.create_plugin_event (
  p_id => 15259312241923573 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_name => 'cfpluginapexdialogcreate'
 ,p_display_name => 'Dialog Open'
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A2A200A202A204A61766153637269707420436F6E736F6C6520577261707065720A202A20286F726967696E616C6C792063616C6C6564206C6F6767657220666F722041504558290A202A2050726F6A65637420536974653A20687474703A2F2F636F';
wwv_flow_api.g_varchar2_table(2) := '64652E676F6F676C652E636F6D2F702F6A732D636F6E736F6C652D777261707065722F0A202A20536F75726365202853564E293A2068747470733A2F2F6A732D636F6E736F6C652D777261707065722E676F6F676C65636F64652E636F6D2F73766E2F74';
wwv_flow_api.g_varchar2_table(3) := '72756E6B2F24636F6E736F6C655F777261707065722E6A730A202A204C6963656E73653A20474E552047656E6572616C205075626C6963204C6963656E73652C2076657273696F6E2033202847504C7633290A202A20202D20687474703A2F2F6F70656E';
wwv_flow_api.g_varchar2_table(4) := '736F757263652E6F72672F6C6963656E7365732F67706C2D332E302E68746D6C0A202A2040617574686F72204D617274696E204769666679204427536F757A6120687474703A2F2F7777772E74616C6B617065782E636F6D0A202A0A202A205573656420';
wwv_flow_api.g_varchar2_table(5) := '746F20777261702063616C6C7320746F20636F6E736F6C6520776869636820616C6C6F777320646576656C6F7065727320746F20696E737472756D656E74207468656972204A5320636F64650A202A205468697320737570706F72747320322077617973';
wwv_flow_api.g_varchar2_table(6) := '206F66206C6F6767696E670A202A20312D2041732061206A51756572792066756E6374696F6E20776869636820737570706F72747320636861696E696E670A202A2020202054686973206F6E6C7920737570706F72747320736F6D6520636F6E736F6C65';
wwv_flow_api.g_varchar2_table(7) := '2066656174757265730A202A20322D2041732061207374616E64616C6F6E652066756E6374696F6E0A202A202020205468697320737570706F72747320616C6C20636F6E736F6C652066656174757265730A202A0A202A204578616D706C657320617265';
wwv_flow_api.g_varchar2_table(8) := '20646F63756D656E7465642061626F766520656163682066756E6374696F6E0A202A0A202A205265666572656E63653A0A202A20202D204669726562756720436F6E736F6C6520436F6D6D616E64733A20687474703A2F2F676574666972656275672E63';
wwv_flow_api.g_varchar2_table(9) := '6F6D2F6C6F6767696E670A202A20202D20436F6E736F6C65204150493A20687474703A2F2F676574666972656275672E636F6D2F77696B692F696E6465782E7068702F436F6E736F6C655F4150490A202A20202D20436F6E736F6C65204578616D706C65';
wwv_flow_api.g_varchar2_table(10) := '3A20687474703A2F2F7777772E747574746F61737465722E636F6D2F6C6561726E696E672D6A6176617363726970742D616E642D646F6D2D776974682D636F6E736F6C652F0A202A0A202A204E6F7465733A0A202A204279207573696E67207468697320';
wwv_flow_api.g_varchar2_table(11) := '6D6574686F64207765277265207361666520746F207573652022242220696E7465726E616C6C79206173207573657273206D6179206368616E676520746865202420616C696173200A202A205061737320696E206A517565727920696E746F2074686973';
wwv_flow_api.g_varchar2_table(12) := '2066756E6374696F6E0A202A205365653A20687474703A2F2F646F63732E6A71756572792E636F6D2F506C7567696E732F417574686F72696E6720666F72206D6F726520696E666F726D6174696F6E0A202A0A202A204368616E6765206C6F673A0A202A';
wwv_flow_api.g_varchar2_table(13) := '20312E302E333A0A202A20202D20496E206C6F67506172616D732C206368616E67656420226C6F672220746F20227761726E2220666F7220756E61737369676E656420706172616D6574657273200A202A20312E302E323A0A202A20202D204669786564';
wwv_flow_api.g_varchar2_table(14) := '20697373756520696620666972737420617267756D656E7420776173206E6F74206120737472696E6720286572726F7220776173206F6363757272696E67206F6E20666972737420617267756D656E7420636865636B290A202A20312E302E313A200A20';
wwv_flow_api.g_varchar2_table(15) := '2A20202D204164646564206C6F67506172616D732066756E6374696F6E0A202A20202D2046697865642063616E4C6F672066756E6374696F6E20286469646E27742064657465637420746865206F6666206C6576656C206265666F7265290A202A20312E';
wwv_flow_api.g_varchar2_table(16) := '302E303A20496E697469616C0A202A2F0A2866756E6374696F6E282429207B0A20202F2A2A0A2020202A20436F6E736F6C65204C6F676765722066756E6374696F6E20666F72204A530A2020202A2057696C6C20646973706C6179206D65737361676520';
wwv_flow_api.g_varchar2_table(17) := '696E20636F6E736F6C652028696620697420657869737473290A2020202A2046756E6374696F6E7320737570706F727465643A206C6F672C2064656275672C20696E666F2C207761726E2C206572726F722C2074726163652C206469722C20646972786D';
wwv_flow_api.g_varchar2_table(18) := '6C0A2020202A2053696D706C6520757365206F6E65206F66207468652061626F76652066756E6374696F6E732061732074686520666972737420706172616D6574657220746F2063616C6C2069740A2020202A202044656661756C74206973206C6F670A';
wwv_flow_api.g_varchar2_table(19) := '2020202A20416C77617973206C6F67732022746869732220616E6420617070656E64206F7468657220706172616D65746572730A2020202A200A2020202A2057696C6C206C6F6F6B20617420242E636F6E736F6C652E63616E4C6F67282920746F207365';
wwv_flow_api.g_varchar2_table(20) := '652069662069742077696C6C2061637475616C6C79206C6F670A2020202A202053656520242E636F6E736F6C652E7365744C6576656C20666F72206C6576656C20696E666F726D6174696F6E0A2020202A0A2020202A202D20486F7720746F2075736520';
wwv_flow_api.g_varchar2_table(21) := '2D200A2020202A200A2020202A202428277027292E6C6F6728293B202F2F57696C6C206C6F6720616C6C203C703E20746167730A2020202A202428277027292E6C6F6728277465737427292E746F67676C652829202F2F4C6F6720616C6C203C703E206F';
wwv_flow_api.g_varchar2_table(22) := '626A6563747320616E6420746F67676C6573207468656D0A2020202A202428277027292E6C6F6728277761726E272C277465737427293B202F2F5761726E696E67206C6F6720666F7220616C6C203C703E206F626A6563747320616E6420616464732027';
wwv_flow_api.g_varchar2_table(23) := '746573742720696E206465627567206D6573736167650A2020202A2F0A2020242E666E2E6C6F67203D2066756E6374696F6E202829207B0A202020202F2F4E6F746520746861742064697220616E6420646972786D6C2077696C6C206F6E6C7920757365';
wwv_flow_api.g_varchar2_table(24) := '202274686973220A20202020766172206C6F67466E73203D205B276C6F67272C20276465627567272C2027696E666F272C20277761726E272C20276572726F72272C20277472616365272C2027646972272C2027646972786D6C275D3B0A202020207661';
wwv_flow_api.g_varchar2_table(25) := '7220636D64203D20276C6F67273B202F2F2044656661756C7420636F6D6D616E6420746F2072756E0A202020202F2F20436F6E7665727420617267756D656E747320746F2061727261790A202020207661722061726773203D2041727261792E70726F74';
wwv_flow_api.g_varchar2_table(26) := '6F747970652E736C6963652E63616C6C28617267756D656E7473293B0A0A202020202F2F496620666972737420617267756D656E742069732061206C6F6720636F6D6D616E64207468656E207573652069742C206F746865727769736520757365206C6F';
wwv_flow_api.g_varchar2_table(27) := '6720616E642072656D6F76652069740A2020202069662820617267756D656E74732E6C656E677468203E20302026262028747970656F6628617267756D656E74735B305D29292E746F4C6F776572436173652829203D3D3D2027737472696E6727202626';
wwv_flow_api.g_varchar2_table(28) := '20242E696E417272617928617267756D656E74735B305D2E746F4C6F7765724361736528292C6C6F67466E7329203E3D2030297B0A202020202020636D64203D20617267756D656E74735B305D3B0A2020202020202F2F52656D6F766520666972737420';
wwv_flow_api.g_varchar2_table(29) := '656C656D656E742073696E636520646F6E27742077616E7420697420746F2061707065617220616E796D6F72650A202020202020617267732E736869667428293B0A202020207D0A0A202020202F2F4966206F662074686520636F6D6D616E6420616374';
wwv_flow_api.g_varchar2_table(30) := '75616C6C79206578697374730A202020206966202877696E646F772E636F6E736F6C6520262620636F6E736F6C655B636D645D20262620242E636F6E736F6C652E63616E4C6F6728242E636F6E736F6C652E6C6576656C735B636D645D29297B0A202020';
wwv_flow_api.g_varchar2_table(31) := '202020746869732E656163682866756E6374696F6E2829207B0A2020202020202020636F6E736F6C655B636D645D2E6170706C7928636F6E736F6C652C20242E6D65726765285B746869735D2C206172677329293B0A2020202020207D293B0A20202020';
wwv_flow_api.g_varchar2_table(32) := '7D0A2020202072657475726E20746869733B0A20207D3B202F2F242E666E2E6C6F670A0A20202F2A2A0A2020202A205772617070657220666F7220636F6E736F6C652066756E6374696F6E2E0A2020202A205468697320616C6C6F777320796F7520746F';
wwv_flow_api.g_varchar2_table(33) := '206164642022636F6E736F6C65222063616C6C7320746F20242E636F6E736F6C6520616E6420646F206E6F74206E65656420746F20776F7272792061626F75742062726F7773657220636F6D7061746962696C6974790A2020202A2044656661756C7420';
wwv_flow_api.g_varchar2_table(34) := '6C6576656C20697320226F66662220736F206D75737420656E61626C6520666F72206F75747075740A2020202A20202D20415045583A2049662072756E20696E204150455820616E642073657373696F6E20697320696E206465627567206D6F64652C20';
wwv_flow_api.g_varchar2_table(35) := '6C6576656C206973206175746F6D61746963616C6C792073657420746F20226C6F67220A2020202A0A2020202A202D20486F7720746F20757365202D0A2020202A200A2020202A202D20436865636B204C6576656C3A0A2020202A20242E636F6E736F6C';
wwv_flow_api.g_varchar2_table(36) := '652E6765744C6576656C28293B0A2020202A0A2020202A202D20536574204C6576656C3A0A2020202A20242E636F6E736F6C652E7365744C6576656C28277761726E27293B202F2F4F6E6C7920656E61626C6573207761726E696E67206D657373616765';
wwv_flow_api.g_varchar2_table(37) := '7320616E64206C6F7765720A2020202A0A2020202A202D204C6F673A0A2020202A20242E636F6E736F6C652E6C6F672827746869732069732061206C6F67206D65737361676527293B0A2020202A20242E636F6E736F6C652E6572726F72282774686973';
wwv_flow_api.g_varchar2_table(38) := '20697320616E206572726F72206D65737361676527293B0A2020202A2F0A2020242E636F6E736F6C65203D202866756E6374696F6E28297B0A202020202F2F2A2A2A2050726976617465202A2A2A0A202020202F2F4C6576656C730A2020202076617220';
wwv_flow_api.g_varchar2_table(39) := '6C6576656C73203D207B0A2020202020206F6666203A20302C0A202020202020657863657074696F6E3A20312C0A2020202020206572726F72203A20322C0A2020202020207761726E3A20342C0A202020202020696E666F3A20382C0A2020202020206C';
wwv_flow_api.g_varchar2_table(40) := '6F67203A2031362C0A2020202020206465627567203A20313620202020200A202020207D3B0A202020200A202020202F2F43757272656E74206C6576656C0A20202020766172206C6576656C203D206C6576656C732E6F66663B202F2F44656661756C74';
wwv_flow_api.g_varchar2_table(41) := '20746F206F66660A202020200A202020202F2F4C697374206F6620636F6E736F6C652066756E6374696F6E730A2020202076617220636F6E736F6C65466E73203D205B0A2020202020207B666E3A20276C6F67272C206C6576656C3A206C6576656C732E';
wwv_flow_api.g_varchar2_table(42) := '6C6F677D2C0A2020202020207B666E3A20276465627567272C206C6576656C3A206C6576656C732E6C6F677D2C0A2020202020207B666E3A2027696E666F272C206C6576656C3A206C6576656C732E696E666F7D2C0A2020202020207B666E3A20277761';
wwv_flow_api.g_varchar2_table(43) := '726E272C206C6576656C3A206C6576656C732E7761726E7D2C0A2020202020207B666E3A20276572726F72272C206C6576656C3A206C6576656C732E6572726F727D2C0A2020202020207B666E3A202774696D65272C206C6576656C3A206C6576656C73';
wwv_flow_api.g_varchar2_table(44) := '2E6C6F677D2C0A2020202020207B666E3A202774696D65456E64272C206C6576656C3A206C6576656C732E6C6F677D2C0A2020202020207B666E3A202770726F66696C65272C206C6576656C3A206C6576656C732E6C6F677D2C0A2020202020207B666E';
wwv_flow_api.g_varchar2_table(45) := '3A202770726F66696C65456E64272C206C6576656C3A206C6576656C732E6C6F677D2C0A2020202020207B666E3A2027636F756E74272C206C6576656C3A206C6576656C732E6C6F677D2C0A2020202020207B666E3A20277472616365272C206C657665';
wwv_flow_api.g_varchar2_table(46) := '6C3A206C6576656C732E6C6F677D2C0A2020202020207B666E3A202767726F7570272C206C6576656C3A206C6576656C732E6572726F727D2C0A2020202020207B666E3A202767726F7570436F6C6C6170736564272C206C6576656C3A206C6576656C73';
wwv_flow_api.g_varchar2_table(47) := '2E6572726F727D2C0A2020202020207B666E3A202767726F7570456E64272C206C6576656C3A206C6576656C732E6572726F727D2C0A2020202020207B666E3A2027646972272C206C6576656C3A206C6576656C732E6C6F677D2C0A2020202020207B66';
wwv_flow_api.g_varchar2_table(48) := '6E3A2027646972786D6C272C206C6576656C3A206C6576656C732E6C6F677D2C0A2020202020207B666E3A2027617373657274272C206C6576656C3A206C6576656C732E6C6F677D2C0A2020202020207B666E3A2027657863657074696F6E272C206C65';
wwv_flow_api.g_varchar2_table(49) := '76656C3A206C6576656C732E657863657074696F6E7D2C0A2020202020207B666E3A20277461626C65272C206C6576656C3A206C6576656C732E6C6F677D0A202020205D3B0A0A202020202F2F2A2A2A205075626C6963202A2A2A0A202020202F2F5265';
wwv_flow_api.g_varchar2_table(50) := '7475726E205075626C6963206F626A656374730A2020202074686174203D207B7D3B0A202020200A202020202F2F416C6C6F77206F746865722066756E6374696F6E7320746F2061636365737320746865206C6576656C206E756D626572730A20202020';
wwv_flow_api.g_varchar2_table(51) := '746861742E6C6576656C73203D206C6576656C733B0A0A202020202F2A2A0A20202020202A2044657465726D696E65732069662066756E6374696F6E2063616E206265206C6F676765640A20202020202A2040706172616D20704C6576656C204C657665';
wwv_flow_api.g_varchar2_table(52) := '6C206F662066756E6374696F6E206265696E672063616C6C65640A20202020202A204072657475726E20547275652069662063616E2072756E20636F6D6D616E642C2066616C7365206966206E6F740A20202020202A2F0A20202020746861742E63616E';
wwv_flow_api.g_varchar2_table(53) := '4C6F67203D2066756E6374696F6E28704C6576656C297B0A20202020202072657475726E206C6576656C203E3D20704C6576656C202626206C6576656C20213D206C6576656C732E6F6666203B0A202020207D3B2F2F63616E4C6F670A0A202020202F2A';
wwv_flow_api.g_varchar2_table(54) := '2A0A20202020202A20536574206C6F67676572206465627567206C6576656C0A20202020202A20696620704C6576656C206973206E6F742076616C696420616E20616C657274206D6573736167652077696C6C20626520646973706C617965640A202020';
wwv_flow_api.g_varchar2_table(55) := '20202A2040706172616D20704C6576656C204C6576656C202873656520746869732E6C6576656C7320666F722066756C6C206C697374206F66206C6576656C73290A20202020202A2F0A20202020746861742E7365744C6576656C203D2066756E637469';
wwv_flow_api.g_varchar2_table(56) := '6F6E28704C6576656C297B0A2020202020207661722074656D704C6576656C203D206C6576656C735B704C6576656C2E746F4C6F7765724361736528295D3B0A2020202020202F2F436865636B20746F2073656520696620746865206C6576656C206973';
wwv_flow_api.g_varchar2_table(57) := '2061637475616C6C7920612076616C6964206C6576656C0A2020202020206966202874656D704C6576656C203D3D20756E646566696E6564290A2020202020202020616C6572742827496E76616C6964204C6576656C3A2027202B20704C6576656C293B';
wwv_flow_api.g_varchar2_table(58) := '0A202020202020656C73650A20202020202020206C6576656C203D2074656D704C6576656C3B0A202020207D3B2F2F7365744C6576656C0A202020200A202020202F2A2A0A20202020202A204072657475726E204C6576656C20696E2074657874202869';
wwv_flow_api.g_varchar2_table(59) := '2E652E206E6F7420746865206E756D657269632076616C7565290A20202020202A2F0A20202020746861742E6765744C6576656C203D2066756E6374696F6E28297B0A202020202020666F722028766172206B657920696E206C6576656C7329207B0A20';
wwv_flow_api.g_varchar2_table(60) := '20202020202020696620286C6576656C732E6861734F776E50726F7065727479286B657929202626206C6576656C735B6B65795D203D3D206C6576656C297B0A2020202020202020202072657475726E206B65793B0A2020202020202020202062726561';
wwv_flow_api.g_varchar2_table(61) := '6B3B0A20202020202020207D2F2F2069660A2020202020207D2F2F666F720A2020202020200A2020202020202F2F4469646E27742066696E642069740A20202020202072657475726E2027556E6B6E6F776E3A2027202B206C6576656C3B0A202020207D';
wwv_flow_api.g_varchar2_table(62) := '3B2F2F6765744C6576656C0A202020200A202020202F2A2A0A20202020202A204072657475726E207472756520696620696E20415045582073657373696F6E20616E64206465627567206D6F6465206973207365740A20202020202A2F0A202020207468';
wwv_flow_api.g_varchar2_table(63) := '61742E6973417065784465627567203D2066756E6374696F6E28297B0A20202020202076617220636865636B203D20646F63756D656E742E676574456C656D656E7442794964282770646562756727293B0A20202020202072657475726E20636865636B';
wwv_flow_api.g_varchar2_table(64) := '20213D20756E646566696E6564202626202428272370646562756727292E76616C28292E746F4C6F776572436173652829203D3D2027796573273B0A202020207D3B202F2F69734170657844656275670A202020200A202020202F2A2A0A20202020202A';
wwv_flow_api.g_varchar2_table(65) := '2057696C6C206C6F6720706172616D657465727320616E6420646973706C6179206261736564206F6E206F7074696F6E730A20202020202A204561736965737420746F2063616C6C206A75737420627920242E636F6E736F6C652E6C6F67506172616D73';
wwv_flow_api.g_varchar2_table(66) := '28293B20546869732077696C6C207573652064656661756C7420706172616D657465727320287265636F6D6D656E646564290A20202020202A200A20202020202A2040706172616D20704F7074696F6E73204A534F4E206F626A65637420776974682074';
wwv_flow_api.g_varchar2_table(67) := '686520666F6C6C6F77696E672076616C7565730A20202020202A20202D2063726561746547726F757020626F6F6C65616E204966207472756520612067726F75702077696C6C20626520637265617465642028616E6420636C6F73656420617070726F70';
wwv_flow_api.g_varchar2_table(68) := '72696174656C79290A20202020202A20202D2067726F7570436F6C6C617073656420626F6F6C65616E2049662063726561746547726F757020697320747275652C20746869732064657465726D696E6573206966207468652067726F757020697320636F';
wwv_flow_api.g_varchar2_table(69) := '6C6C617061736564206F72206E6F740A20202020202A20202D2067726F75705465787420737472696E67204966206372656174652067726F757020697320747275652C20746869732077696C6C20626520746865206E616D65206F66207468652067726F';
wwv_flow_api.g_varchar2_table(70) := '75700A20202020202A2F0A20202020746861742E6C6F67506172616D73203D2066756E6374696F6E28704F7074696F6E73297B0A202020202020696620282128746869732E63616E4C6F67286C6576656C732E6C6F672929297B0A202020202020202072';
wwv_flow_api.g_varchar2_table(71) := '657475726E3B202F2F446F6E27742072756E20636F64652069662077652063616E2774206C6F670A2020202020207D0A2020202020200A2020202020202F2F5365742044656661756C74206F7074696F6E730A2020202020207661722064656661756C74';
wwv_flow_api.g_varchar2_table(72) := '73203D207B0A202020202020202063726561746547726F7570203A20747275652C202F2F5772617020616C6C2074686520706172616D657465727320696E20612067726F75700A202020202020202067726F7570436F6C6C6170736564203A2074727565';
wwv_flow_api.g_varchar2_table(73) := '2C0A202020202020202067726F757054657874203A2027506172616D6574657273270A2020202020207D3B0A202020202020704F7074696F6E73203D206A51756572792E657874656E6428747275652C64656661756C74732C704F7074696F6E73293B0A';
wwv_flow_api.g_varchar2_table(74) := '2020202020200A2020202020207661722063616C6C696E67466E203D20617267756D656E74732E63616C6C65652E63616C6C65723B202F2F54686973206973207468652066756E6374696F6E20746861742063616C6C656420746869732066756E637469';
wwv_flow_api.g_varchar2_table(75) := '6F6E0A2020202020202F2F20476F7420666F6C6C6F77696E67206C696E652066726F6D3A20687474703A2F2F737461636B6F766572666C6F772E636F6D2F7175657374696F6E732F3931343936382F696E73706563742D7468652D6E616D65732D76616C';
wwv_flow_api.g_varchar2_table(76) := '7565732D6F662D617267756D656E74732D696E2D7468652D646566696E6974696F6E2D657865637574696F6E2D6F662D612D6A6176617363726970740A202020202020766172206172674C697374203D202F5C28285B5E295D2A292F2E65786563286361';
wwv_flow_api.g_varchar2_table(77) := '6C6C696E67466E295B315D2E73706C697428272C27293B202F2F2047657420746865206E616D65206F6620616C6C2074686520617267756D656E747320696E207468652066756E6374696F6E2E200A2020202020207661722061726773203D2041727261';
wwv_flow_api.g_varchar2_table(78) := '792E70726F746F747970652E736C6963652E63616C6C2863616C6C696E67466E2E617267756D656E7473293B202F2F5468697320697320616E206172726179206F6620617267756D656E74732070617373656420696E746F207468652063616C6C696E67';
wwv_flow_api.g_varchar2_table(79) := '2066756E6374696F6E20286E6F7420746869732066756E6374696F6E290A2020202020200A20202020202069662028704F7074696F6E732E63726561746547726F7570297B0A202020202020202069662028704F7074696F6E732E67726F7570436F6C6C';
wwv_flow_api.g_varchar2_table(80) := '6170736564290A20202020202020202020746869732E67726F7570436F6C6C617073656428704F7074696F6E732E67726F757054657874293B0A2020202020202020656C73650A20202020202020202020746869732E67726F757028704F7074696F6E73';
wwv_flow_api.g_varchar2_table(81) := '2E67726F757054657874293B0A2020202020207D2F2F6966204372656174652047726F75700A2020202020200A2020202020202F2F446973706C6179206561636820617267756D656E740A202020202020666F72287661722069203D20302C20694D6178';
wwv_flow_api.g_varchar2_table(82) := '203D20617267732E6C656E6774683B2069203C20694D61783B20692B2B29207B0A20202020202020206966202869203C206172674C6973742E6C656E677468297B0A20202020202020202020746869732E6C6F67286172674C6973745B695D2E7472696D';
wwv_flow_api.g_varchar2_table(83) := '2829202B20273A272C20617267735B695D293B0A20202020202020207D0A2020202020202020656C7365207B0A202020202020202020202F2F556E61737369676E65640A20202020202020202020746869732E7761726E2827756E61737369676E65643A';
wwv_flow_api.g_varchar2_table(84) := '272C20617267735B695D293B0A20202020202020207D0A2020202020207D2F2F666F720A2020202020200A2020202020202F2F436C6F73652067726F7570206966206E6573736172790A20202020202069662028704F7074696F6E732E63726561746547';
wwv_flow_api.g_varchar2_table(85) := '726F7570297B0A2020202020202020242E636F6E736F6C652E67726F7570456E6428293B0A2020202020207D0A202020207D2F2F6C6F67506172616D730A0A202020202F2F4170706C7920636F6E736F6C652066756E6374696F6E7320746F2022746861';
wwv_flow_api.g_varchar2_table(86) := '74220A20202020666F722028693D303B2069203C20636F6E736F6C65466E732E6C656E6774683B20692B2B297B0A202020202020766172206D79466E203D20636F6E736F6C65466E735B695D3B0A2020202020202F2F436F6E736F6C6520657869737473';
wwv_flow_api.g_varchar2_table(87) := '0A2020202020202866756E6374696F6E2870462C20704C297B0A2020202020202020746861745B70465D203D2066756E6374696F6E28297B0A202020202020202020202F2F4F6E6C792072756E20636F6E736F6C6520696620796F752063616E206C6F67';
wwv_flow_api.g_varchar2_table(88) := '2C20616E6420636F6E736F6C65206578697374732E0A202020202020202020202F2F436865636B696E6720636F6E736F6C652061742072756E2074696D6520666F7220656E67696E6573206C696B652046697265627567204C6974650A20202020202020';
wwv_flow_api.g_varchar2_table(89) := '202020696628746869732E63616E4C6F6728704C292026262077696E646F772E636F6E736F6C6520262620636F6E736F6C655B70465D290A202020202020202020202020636F6E736F6C655B70465D2E6170706C792820636F6E736F6C652C2061726775';
wwv_flow_api.g_varchar2_table(90) := '6D656E747320293B0A20202020202020207D3B0A2020202020207D29286D79466E2E666E2C206D79466E2E6C6576656C293B0A202020207D2F2F666F720A0A2020202072657475726E20746861743B0A20207D2928293B2F2F24636F6E736F6C650A0A20';
wwv_flow_api.g_varchar2_table(91) := '202F2F4175746F6D61746963616C6C7920736574206C6F6767696E67206C6576656C20666F72206170657820696E206465627567206D6F64650A20202428646F63756D656E74292E72656164792866756E6374696F6E28297B0A2020202069662028242E';
wwv_flow_api.g_varchar2_table(92) := '636F6E736F6C652E69734170657844656275672829290A202020202020242E636F6E736F6C652E7365744C6576656C28276C6F6727293B0A20207D293B0A20200A20202F2F41646420737472696E672E7472696D28292066756E6374696F6E2073696E63';
wwv_flow_api.g_varchar2_table(93) := '6520494520646F65736E277420737570706F727420746869730A20202F2F5472696D2066756E6374696F6E206973207573656420696E206C6F67506172616D732066756E6374696F6E0A20202F2F436F64652066726F6D3A20687474703A2F2F73746163';
wwv_flow_api.g_varchar2_table(94) := '6B6F766572666C6F772E636F6D2F7175657374696F6E732F323330383133342F7472696D2D696E2D6A6176617363726970742D6E6F742D776F726B696E672D696E2D69650A2020696628747970656F6620537472696E672E70726F746F747970652E7472';
wwv_flow_api.g_varchar2_table(95) := '696D20213D3D202766756E6374696F6E2729207B0A20202020537472696E672E70726F746F747970652E7472696D203D2066756E6374696F6E2829207B0A20202020202072657475726E20746869732E7265706C616365282F5E5C732B7C5C732B242F67';
wwv_flow_api.g_varchar2_table(96) := '2C202727293B200A202020207D0A20207D0A0A7D29286A5175657279293B';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 15156524308848640 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_file_name => '$console_wrapper_1.0.3.js'
 ,p_mime_type => 'application/x-javascript'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A2A200A202A20436C617269466974206A5175657279205549204469616C6F670A202A20506C75672D696E20547970653A204479616E6D696320416374696F6E0A202A2053756D6D6172793A20446973706C6179732061206A51756572692055492044';
wwv_flow_api.g_varchar2_table(2) := '69616C6F672077696E646F7720666F7220616666656374656420656C656D656E74730A202A0A202A20446570656E64733A0A202A20206A71756572792E75692E6469616C6F672E6A730A202A2020242E636F6E736F6C652E6A7320202D20687474703A2F';
wwv_flow_api.g_varchar2_table(3) := '2F636F64652E676F6F676C652E636F6D2F702F6A732D636F6E736F6C652D777261707065722F0A202A0A202A204E6F7465733A0A202A204F626A65637420746F2062652073686F776E20696E204469616C6F672077696E646F77206E6565647320746F20';
wwv_flow_api.g_varchar2_table(4) := '6265207772617070656420696E206F7264657220746F2070726573657276652069747320706F736974696F6E20696E20444F4D0A202A205365653A20687474703A2F2F666F72756D732E6F7261636C652E636F6D2F666F72756D732F7468726561642E6A';
wwv_flow_api.g_varchar2_table(5) := '7370613F6D65737361676549443D3331383035333220666F72206D6F726520696E666F726D6174696F6E2E0A202A0A202A204368616E6765733A0A202A20312E302E310A202A20202D204164646564206164646974696F6E616C20646562756720696E66';
wwv_flow_api.g_varchar2_table(6) := '6F726D6174696F6E20696E2074686520636C6F73652066756E6374696F6E0A202A20202D20416464656420737570706F727420666F72206578706C69637420636C6F73652066756E6374696F6E0A202A0A202A205E5E5E20436F6E7461637420696E666F';
wwv_flow_api.g_varchar2_table(7) := '726D6174696F6E205E5E5E0A202A20446576656C6F70656420627920436C61726946697420496E632E0A202A20687474703A2F2F7777772E636C6172696669742E636F6D0A202A206170657840636C6172696669742E636F6D0A202A0A202A205E5E5E20';
wwv_flow_api.g_varchar2_table(8) := '4C6963656E7365205E5E5E0A202A204C6963656E73656420556E6465723A20474E552047656E6572616C205075626C6963204C6963656E73652C2076657273696F6E2033202847504C2D332E3029202D20687474703A2F2F7777772E6F70656E736F7572';
wwv_flow_api.g_varchar2_table(9) := '63652E6F72672F6C6963656E7365732F67706C2D332E302E68746D6C0A202A0A202A2040617574686F72204D617274696E204769666679204427536F757A61202D20687474703A2F2F7777772E74616C6B617065782E636F6D0A202A2F0A2866756E6374';
wwv_flow_api.g_varchar2_table(10) := '696F6E2824297B0A20242E776964676574282775692E636C6172696669744469616C6F67272C207B0A20202F2F2064656661756C74206F7074696F6E730A20206F7074696F6E733A207B0A202020202F2F436F6E666967757261626C65206F7074696F6E';
wwv_flow_api.g_varchar2_table(11) := '7320696E204150455820706C7567696E0A202020206D6F64616C3A20747275652C0A20202020636C6F73654F6E4573636170653A20747275652C0A202020207469746C653A2027272C0A20202020706572736973743A20747275652C202F2F4675747572';
wwv_flow_api.g_varchar2_table(12) := '65206F7074696F6E2C206E6F20616666656374207269676874206E6F770A202020206F6E436C6F736556697369626C6553746174653A20277072657627202F2F526573746F7265206F626A656374732076697369626C65207374617465206F6E63652063';
wwv_flow_api.g_varchar2_table(13) := '6C6F7365640A20207D2C0A0A20202F2A2A0A2020202A20496E69742066756E6374696F6E2E20546869732066756E6374696F6E2077696C6C2062652063616C6C656420656163682074696D652074686520776964676574206973207265666572656E6365';
wwv_flow_api.g_varchar2_table(14) := '642077697468206E6F20706172616D65746572730A2020202A2F0A20205F696E69743A2066756E6374696F6E28297B0A2020202076617220756977203D20746869733B0A2020202076617220636F6E736F6C6547726F75704E616D65203D207569772E5F';
wwv_flow_api.g_varchar2_table(15) := '73636F7065202B20272E5F696E6974273B0A20202020242E636F6E736F6C652E67726F7570436F6C6C617073656428636F6E736F6C6547726F75704E616D65293B0A0A202020202F2F46696E6420746865206F626A656374732076697369626C65207374';
wwv_flow_api.g_varchar2_table(16) := '617465206265666F7265206D616B696E67206469616C6F672077696E646F7720287573656420746F20726573746F7265206966206E6563657373617279290A202020207569772E5F76616C7565732E6265666F726553686F7756697369626C65203D2075';
wwv_flow_api.g_varchar2_table(17) := '69772E5F656C656D656E74732E24656C656D656E742E697328273A76697369626C6527293B0A20202020242E636F6E736F6C652E6C6F6728276265666F726553686F7756697369626C653A20272C207569772E5F76616C7565732E6265666F726553686F';
wwv_flow_api.g_varchar2_table(18) := '7756697369626C65293B0A202020200A202020202F2F437265617465204469616C6F672077696E646F770A202020202F2F4372656174696E6720656163682074696D6520736F20746861742077652063616E20656173696C7920726573746F7265206974';
wwv_flow_api.g_varchar2_table(19) := '732076697369626C65207374617465206966206E65636573736172790A202020207569772E5F656C656D656E74732E24656C656D656E742E6469616C6F67287B0A2020202020206D6F64616C3A207569772E6F7074696F6E732E6D6F64616C2C0A202020';
wwv_flow_api.g_varchar2_table(20) := '202020636C6F73654F6E4573636170653A207569772E6F7074696F6E732E636C6F73654F6E4573636170652C0A2020202020207469746C653A207569772E6F7074696F6E732E7469746C652C0A2020202020202F2F4F7074696F6E732062656C6F772043';
wwv_flow_api.g_varchar2_table(21) := '616E206265206D61646520636F6E666967757261626C652069662072657175697265640A20202020202077696474683A20276175746F272C0A2020202020202F2F4576656E742042696E64696E670A2020202020206265666F7265436C6F73653A206675';
wwv_flow_api.g_varchar2_table(22) := '6E6374696F6E286576656E742C20756929207B2020242874686973292E7472696767657228276366706C7567696E617065786469616C6F676265666F7265636C6F7365272C207B6576656E743A206576656E742C2075693A2075697D293B207D2C0A2020';
wwv_flow_api.g_varchar2_table(23) := '20202020636C6F73653A2066756E6374696F6E286576656E742C20756929207B207569772E636C6F7365286576656E742C207569293B207D2C0A2020202020206372656174653A2066756E6374696F6E286576656E742C20756929207B20202428746869';
wwv_flow_api.g_varchar2_table(24) := '73292E7472696767657228276366706C7567696E617065786469616C6F67637265617465272C207B6576656E743A206576656E742C2075693A2075697D293B207D0A202020207D293B0A0A202020202F2F4D6F766520696E746F20777261707065720A20';
wwv_flow_api.g_varchar2_table(25) := '2020207569772E5F656C656D656E74732E24777261707065722E617070656E64287569772E5F656C656D656E74732E24656C656D656E742E706172656E7428272E75692D6469616C6F672729293B0A202020200A20202020242E636F6E736F6C652E6772';
wwv_flow_api.g_varchar2_table(26) := '6F7570456E6428636F6E736F6C6547726F75704E616D65293B0A20207D2C202F2F5F696E69740A20200A20202F2A2A0A2020202A205365742070726976617465207769646765742076617261626C6573200A2020202A2F0A20205F736574576964676574';
wwv_flow_api.g_varchar2_table(27) := '566172733A2066756E6374696F6E28297B0A2020202076617220756977203D20746869733B0A202020200A202020207569772E5F73636F7065203D202775692E27202B207569772E7769646765744E616D653B202F2F466F7220646562756767696E670A';
wwv_flow_api.g_varchar2_table(28) := '0A202020207569772E5F76616C756573203D207B0A202020202020777261707065724964203A207569772E7769646765744E616D65202B20275F27202B207061727365496E74284D6174682E72616E646F6D28292A313030303030303030303030303030';
wwv_flow_api.g_varchar2_table(29) := '3030292C202F2F52616E646F6D206E756D62657220746F206964656E7469667920777261707065720A2020202020206265666F726553686F7756697369626C653A2066616C7365202F2F56697369626C65207374617465206265666F72652073686F770A';
wwv_flow_api.g_varchar2_table(30) := '202020207D3B0A202020200A202020207569772E5F656C656D656E7473203D207B0A20202020202024656C656D656E74203A2024287569772E656C656D656E745B305D292C202F2F416666656374656420656C656D656E740A2020202020202477726170';
wwv_flow_api.g_varchar2_table(31) := '706572203A206E756C6C0A202020207D3B0A202020200A20207D2C202F2F5F736574576964676574566172730A20200A20202F2A2A0A2020202A204372656174652066756E6374696F6E3A2043616C6C6564207468652066697273742074696D65207769';
wwv_flow_api.g_varchar2_table(32) := '64676574206973206173736F63696174656420746F20746865206F626A6563740A2020202A20446F657320616C6C207468652072657175697265642073657475702065746320616E642062696E6473206368616E6765206576656E740A2020202A2F0A20';
wwv_flow_api.g_varchar2_table(33) := '205F6372656174653A2066756E6374696F6E28297B0A2020202076617220756977203D20746869733B0A202020200A202020207569772E5F7365745769646765745661727328293B0A202020200A2020202076617220636F6E736F6C6547726F75704E61';
wwv_flow_api.g_varchar2_table(34) := '6D65203D207569772E5F73636F7065202B20272E5F637265617465273B0A20202020242E636F6E736F6C652E67726F7570436F6C6C617073656428636F6E736F6C6547726F75704E616D65293B0A20202020242E636F6E736F6C652E6C6F672827746869';
wwv_flow_api.g_varchar2_table(35) := '733A272C20756977293B0A20202020242E636F6E736F6C652E6C6F672827656C656D656E743A272C207569772E656C656D656E745B305D293B0A0A202020202F2F437265617465207772617070657220736F2074686174207765206B656570206F626A65';
wwv_flow_api.g_varchar2_table(36) := '637420696E206974732063757272656E7420706C616365206F6E2074686520444F4D0A202020207569772E5F656C656D656E74732E24656C656D656E742E7772617028273C6469762069643D2227202B207569772E5F76616C7565732E77726170706572';
wwv_flow_api.g_varchar2_table(37) := '4964202B2027222F3E27293B0A202020207569772E5F656C656D656E74732E2477726170706572203D202428272327202B207569772E5F76616C7565732E777261707065724964293B0A20202020242E636F6E736F6C652E6C6F67282777726170706572';
wwv_flow_api.g_varchar2_table(38) := '49643A20272C207569772E5F76616C7565732E777261707065724964293B0A202020200A20202020242E636F6E736F6C652E67726F7570456E6428636F6E736F6C6547726F75704E616D65293B0A20207D2C2F2F5F6372656174650A20200A20202F2A2A';
wwv_flow_api.g_varchar2_table(39) := '0A2020202A2052656D6F76657320616C6C2066756E6374696F6E616C697479206173736F63696174656420776974682074686520636C6172696669744469616C6F67200A2020202A2057696C6C2072656D6F766520746865206368616E6765206576656E';
wwv_flow_api.g_varchar2_table(40) := '742061732077656C6C0A2020202A204F6464732061726520746869732077696C6C206E6F742062652063616C6C65642066726F6D20415045582E0A2020202A2F0A202064657374726F793A2066756E6374696F6E2829207B0A2020202076617220756977';
wwv_flow_api.g_varchar2_table(41) := '203D20746869733B0A202020200A20202020242E636F6E736F6C652E6C6F67287569772E5F73636F70652C202764657374726F79272C20756977293B0A20202020242E5769646765742E70726F746F747970652E64657374726F792E6170706C79287569';
wwv_flow_api.g_varchar2_table(42) := '772C20617267756D656E7473293B202F2F2064656661756C742064657374726F790A202020202F2F20756E726567697374657220646174657069636B65720A202020207569772E5F656C656D656E74732E24656C656D656E742E6469616C6F6728202264';
wwv_flow_api.g_varchar2_table(43) := '657374726F792220290A20207D2C2F2F64657374726F790A20200A20202F2A2A0A2020202A20436C6F73657320746865206469616C6F672077696E646F770A2020202A2040706172616D206576656E740A2020202A204075690A2020202A2F0A2020636C';
wwv_flow_api.g_varchar2_table(44) := '6F73653A2066756E6374696F6E286576656E742C207569297B0A2020202076617220756977203D20746869733B0A2020202076617220636F6E736F6C6547726F75704E616D65203D207569772E5F73636F7065202B20272E636C6F7365273B0A20202020';
wwv_flow_api.g_varchar2_table(45) := '242E636F6E736F6C652E67726F7570436F6C6C617073656428636F6E736F6C6547726F75704E616D65293B0A20202020242E636F6E736F6C652E6C6F67506172616D7328293B0A20202020242E636F6E736F6C652E6C6F6728277569773A20272C207569';
wwv_flow_api.g_varchar2_table(46) := '77293B0A202020200A202020202F2F44657374726F7920746865206A517565727920554920656C656D656E747320736F207468617420697420646973706C617973206173206966206469616C6F6720686164206E6F74206265656E206170706C6965640A';
wwv_flow_api.g_varchar2_table(47) := '202020207569772E5F656C656D656E74732E24656C656D656E742E6469616C6F6728202264657374726F792220293B0A202020200A202020202F2F4D6F7665206F7574206F66207772617070657220616E64206261636B20696E746F206F726967696E61';
wwv_flow_api.g_varchar2_table(48) := '6C20706F736974696F6E0A202020207569772E5F656C656D656E74732E24777261707065722E6265666F7265287569772E5F656C656D656E74732E24656C656D656E74293B0A202020200A202020202F2F53686F77206F6E6C792069662070726576696F';
wwv_flow_api.g_varchar2_table(49) := '7573207374617465207761732073686F770A2020202069662028287569772E5F76616C7565732E6265666F726553686F7756697369626C65202626207569772E6F7074696F6E732E6F6E436C6F736556697369626C655374617465203D3D202770726576';
wwv_flow_api.g_varchar2_table(50) := '2729207C7C207569772E6F7074696F6E732E6F6E436C6F736556697369626C655374617465203D3D202773686F7727297B0A2020202020207569772E5F656C656D656E74732E24656C656D656E742E73686F7728293B0A202020207D0A20202020656C73';
wwv_flow_api.g_varchar2_table(51) := '65207B0A2020202020207569772E5F656C656D656E74732E24656C656D656E742E6869646528293B0A202020207D20202020202020200A202020200A202020202F2F5472696767657220637573746F6D2041504558204576656E740A202020207569772E';
wwv_flow_api.g_varchar2_table(52) := '5F656C656D656E74732E24656C656D656E742E7472696767657228276366706C7567696E617065786469616C6F67636C6F7365272C207B6576656E743A206576656E742C2075693A2075697D293B200A202020200A20202020242E636F6E736F6C652E67';
wwv_flow_api.g_varchar2_table(53) := '726F7570456E6428636F6E736F6C6547726F75704E616D65293B0A20207D2F2F636C6F73650A20200A7D293B202F2F75692E636C6172696669744469616C6F670A0A242E657874656E6428242E75692E636C6172696669744469616C6F672C207B0A2020';
wwv_flow_api.g_varchar2_table(54) := '2F2A2A0A2020202A2046756E6374696F6E20746F2062652063616C6C65642066726F6D2074686520415045582044796E616D696320416374696F6E2070726F636573730A2020202A204E6F2076616C756573206172652070617373656420696E0A202020';
wwv_flow_api.g_varchar2_table(55) := '2A2022746869732220697320746865204150455820444120227468697322206F626A6563740A2020202A2F0A202064614469616C6F673A2066756E6374696F6E28297B0A202020207661722073636F7065203D2027242E75692E636C6172696669744469';
wwv_flow_api.g_varchar2_table(56) := '616C6F672E64614469616C6F67273B0A2020202076617220646154686973203D20746869733B202F2F4E6F746520746861742022746869732220726570726573656E74732074686520415045582044796E616D696320416374696F6E206F626A6563740A';
wwv_flow_api.g_varchar2_table(57) := '20202020242E636F6E736F6C652E67726F7570436F6C6C61707365642873636F7065293B0A20202020242E636F6E736F6C652E6C6F6728274150455820444120746869733A2027202C20646154686973293B0A202020200A202020202F2F536574206F70';
wwv_flow_api.g_varchar2_table(58) := '74696F6E730A20202020766172206F7074696F6E73203D207B0A2020202020206D6F64616C3A206461546869732E616374696F6E2E6174747269627574653031203D3D3D202766616C736527203F2066616C7365203A20747275652C0A20202020202063';
wwv_flow_api.g_varchar2_table(59) := '6C6F73654F6E4573636170653A206461546869732E616374696F6E2E6174747269627574653032203D3D3D202766616C736527203F2066616C7365203A20747275652C0A2020202020207469746C653A206461546869732E616374696F6E2E6174747269';
wwv_flow_api.g_varchar2_table(60) := '6275746530332C0A2020202020206F6E436C6F736556697369626C6553746174653A206461546869732E616374696F6E2E61747472696275746530340A202020207D3B0A202020200A20202020666F72287661722069203D20302C20656E64203D206461';
wwv_flow_api.g_varchar2_table(61) := '546869732E6166666563746564456C656D656E74732E6C656E6774683B2069203C20656E643B20692B2B297B0A202020202020242E636F6E736F6C652E6C6F6728274469616C6F67696E673A20272C206461546869732E6166666563746564456C656D65';
wwv_flow_api.g_varchar2_table(62) := '6E74735B695D293B0A20202020202024286461546869732E6166666563746564456C656D656E74735B695D292E636C6172696669744469616C6F67286F7074696F6E73293B0A202020207D2F2F666F720A202020200A20202020242E636F6E736F6C652E';
wwv_flow_api.g_varchar2_table(63) := '67726F7570456E642873636F7065293B0A20207D2C2F2F64614469616C6F670A20200A20202F2A2A0A2020202A20436C6F7365206469616C6F672077696E646F772873290A2020202A204E6F2076616C756573206172652070617373656420696E0A2020';
wwv_flow_api.g_varchar2_table(64) := '202A2022746869732220697320746865204150455820444120227468697322206F626A6563740A2020202A2F0A20206461436C6F73653A2066756E6374696F6E28297B0A202020207661722073636F7065203D2027242E75692E636C6172696669744469';
wwv_flow_api.g_varchar2_table(65) := '616C6F672E6461436C6F7365273B0A2020202076617220646154686973203D20746869733B202F2F4E6F746520746861742022746869732220726570726573656E74732074686520415045582044796E616D696320416374696F6E206F626A6563740A20';
wwv_flow_api.g_varchar2_table(66) := '202020242E636F6E736F6C652E67726F7570436F6C6C61707365642873636F7065293B0A20202020242E636F6E736F6C652E6C6F6728274150455820444120746869733A2027202C20646154686973293B0A202020200A20202020666F72287661722069';
wwv_flow_api.g_varchar2_table(67) := '203D20302C20656E64203D206461546869732E6166666563746564456C656D656E74732E6C656E6774683B2069203C20656E643B20692B2B297B0A202020202020242E636F6E736F6C652E6C6F672827436C6F73696E673A20272C206461546869732E61';
wwv_flow_api.g_varchar2_table(68) := '66666563746564456C656D656E74735B695D293B0A20202020202024286461546869732E6166666563746564456C656D656E74735B695D292E636C6172696669744469616C6F672827636C6F736527293B0A202020207D2F2F666F720A202020200A2020';
wwv_flow_api.g_varchar2_table(69) := '2020242E636F6E736F6C652E67726F7570456E642873636F7065293B0A20207D2F2F6461436C6F73650A0A7D293B2F2F457874656E640A0A7D2928617065782E6A5175657279293B0A';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 15275600739935491 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 4969964755490500936 + wwv_flow_api.g_id_offset
 ,p_file_name => 'jquery.ui.clarifitDialog_1.0.1.js'
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
