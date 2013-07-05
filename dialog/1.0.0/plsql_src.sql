 -- *** Dialog ***  
  FUNCTION f_render_dialog (
    p_dynamic_action IN apex_plugin.t_dynamic_action,
    p_plugin         IN apex_plugin.t_plugin )
    RETURN apex_plugin.t_dynamic_action_render_result
  AS
    -- Application Plugin Attributes
    v_background_color apex_appl_plugins.attribute_01%TYPE := p_plugin.attribute_01; 
    v_background_opacitiy apex_appl_plugins.attribute_01%TYPE := p_plugin.attribute_02; 
 
    -- DA Plugin Attributes
    v_modal apex_application_page_items.attribute_01%TYPE := p_dynamic_action.attribute_01; -- y/n
    v_close_on_esc apex_application_page_items.attribute_01%TYPE := p_dynamic_action.attribute_02; -- y/n
    v_title apex_application_page_items.attribute_01%TYPE := p_dynamic_action.attribute_03; -- text
    v_hide_on_load apex_application_page_items.attribute_01%TYPE := upper(p_dynamic_action.attribute_04); -- y/n
    v_on_close_visible_state apex_application_page_items.attribute_01%TYPE := lower(p_dynamic_action.attribute_05); -- prev, show, hide
    v_action apex_application_page_items.attribute_01%type := lower(p_dynamic_action.attribute_06); -- open,close
        
    -- Return 
    v_result apex_plugin.t_dynamic_action_render_result;
    
    -- Other variables
    v_html varchar2(4000);
    v_affected_elements apex_application_page_da_acts.affected_elements%type;
    v_affected_elements_type apex_application_page_da_acts.affected_elements_type%type;
    v_affected_region_id apex_application_page_da_acts.affected_region_id%type;
    v_affected_region_static_id apex_application_page_regions.static_id%type;
    
    -- Convert Y/N to True/False (text)
    -- Default to true
    FUNCTION f_yn_to_true_false_str(p_val IN VARCHAR2)
    RETURN VARCHAR2
    AS
    BEGIN
      RETURN
        CASE 
          WHEN p_val IS NULL OR lower(p_val) != 'n' THEN 'true'
          ELSE 'false'
        END;
    END f_yn_to_true_false_str;

  BEGIN
    -- Debug information (if app is being run in debug mode)
    IF apex_application.g_debug THEN
      apex_plugin_util.debug_dynamic_action (
        p_plugin => p_plugin,
        p_dynamic_action => p_dynamic_action);
    END IF;
    
    -- Cleaup values
    v_modal := f_yn_to_true_false_str(p_val => v_modal);
    v_close_on_esc := f_yn_to_true_false_str(p_val => v_close_on_esc);

    -- If Background color is not null set the CSS
    -- This will only be done once per page
    IF v_background_color IS NOT NULL AND v_action != 'close' THEN
      v_html := q'!
        .ui-widget-overlay{
          background-image: none ;
          background-color: %BG_COLOR%;
          opacity: %OPACITY%;
        }!';
      
      v_html := REPLACE(v_html, '%BG_COLOR%', v_background_color);
      v_html := REPLACE(v_html, '%OPACITY%', v_background_opacitiy);

      apex_css.ADD (
        p_css => v_html,
        p_key => 'ui.clarifitdialog.background');
    END IF;
    
    -- JAVASCRIPT

    -- Load javascript Libraries
    apex_javascript.add_library (p_name => '$console_wrapper', p_directory => p_plugin.file_prefix, p_version=> '_1.0.3'); -- Load Console Wrapper for debugging
    apex_javascript.add_library (p_name => 'jquery.ui.clarifitDialog', p_directory => p_plugin.file_prefix, p_version=> '_1.0.1'); 
    
    -- Hide Affected Elements on Load
    IF v_hide_on_load = 'Y' AND v_action != 'close' THEN
      v_html := '';
      
      SELECT affected_elements, lower(affected_elements_type), affected_region_id, aapr.static_id
      INTO v_affected_elements, v_affected_elements_type, v_affected_region_id, v_affected_region_static_id
      FROM apex_application_page_da_acts aapda, apex_application_page_regions aapr
      WHERE aapda.action_id = p_dynamic_action.ID
        AND aapda.affected_region_id = aapr.region_id(+);
      
      IF v_affected_elements_type = 'jquery selector' THEN
        v_html := 'apex.jQuery("' || v_affected_elements || '").hide();';
      ELSIF v_affected_elements_type = 'dom object' THEN      
        v_html := 'apex.jQuery("#' || v_affected_elements || '").hide();';
      ELSIF v_affected_elements_type = 'region' THEN      
        v_html := 'apex.jQuery("#' || nvl(v_affected_region_static_id, 'R' || v_affected_region_id) || '").hide();';
      ELSE
        -- unknown/unhandled (nothing to hide)
        raise_application_error(-20001, 'Unknown Affected Element Type');
      END IF; -- v_affected_elements_type
     
      apex_javascript.add_onload_code (
        p_code => v_html,
        p_key  => NULL); -- Leave null so always run
    END IF; -- v_hide_on_load
    
    -- RETURN
    if v_action = 'open' then
      v_result.javascript_function := '$.ui.clarifitDialog.daDialog';
      v_result.attribute_01 := v_modal;
      v_result.attribute_02 := v_close_on_esc;
      v_result.attribute_03 := v_title;
      v_result.attribute_04 := v_on_close_visible_state;
    elsif v_action = 'close' THEN
      v_result.javascript_function := '$.ui.clarifitDialog.daClose';
    ELSE
      raise_application_error(-20001, 'Unknown Action Type');
    END IF;
    
    RETURN v_result;

  END f_render_dialog;