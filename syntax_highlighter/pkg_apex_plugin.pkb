CREATE OR REPLACE PACKAGE BODY pkg_apex_plugin
AS
  FUNCTION render_syntax_highlighter (p_item                  IN apex_plugin.t_page_item,
                                      p_plugin                IN apex_plugin.t_plugin,
                                      p_value                 IN VARCHAR2,
                                      p_is_readonly           IN BOOLEAN,
                                      p_is_printer_friendly   IN BOOLEAN)
    RETURN apex_plugin.t_page_item_render_result
  AS
    v_result       apex_plugin.t_page_item_render_result;
    v_brush_js     VARCHAR2 (30); -- Brush JS name
    -- Custom Item Attributes
    v_brush        p_item.attribute_01%TYPE := LOWER (p_item.attribute_01);
    v_auto_links   p_item.attribute_02%TYPE := LOWER (p_item.attribute_02);
    v_collapse     p_item.attribute_03%TYPE := LOWER (p_item.attribute_03);
    v_gutter       p_item.attribute_04%TYPE := LOWER (p_item.attribute_04);
    v_smart_tabs   p_item.attribute_05%TYPE := LOWER (p_item.attribute_05);
    v_tab_size     p_item.attribute_06%TYPE := p_item.attribute_06;
    -- Custom Plugin Attributes
    v_theme        p_plugin.attribute_01%TYPE := p_plugin.attribute_01;
    -- TODO: Globals
    -- When updating makesure the filenames all are suffixed with this version number
    c_version      VARCHAR2 (10) := '_3.0.83';
  BEGIN
    -- Syntax Highlighter based on: http://alexgorbatchev.com/SyntaxHighlighter
    -- Debug
    IF apex_application.g_debug THEN
      apex_plugin_util.debug_page_item (p_plugin                => p_plugin,
                                        p_page_item             => p_item,
                                        p_value                 => p_value,
                                        p_is_readonly           => p_is_readonly,
                                        p_is_printer_friendly   => p_is_printer_friendly);
    END IF;

    -- Does not handle printer friendly or read only as this is readonly by nature and we want
    -- Syntax highlighter formatting for printer

    -- Load JS Libraries
    apex_javascript.add_library (p_name => 'shCore', p_directory => p_plugin.file_prefix, p_version => c_version);

    -- Load custom JS Libary for selected brush type
    IF v_brush = 'js' THEN
      v_brush_js := 'JScript';
    ELSIF v_brush = 'sql' THEN
      v_brush_js := 'Sql';
    ELSIF v_brush = 'bash' THEN
      v_brush_js := 'Bash';
    ELSIF v_brush = 'css' THEN
      v_brush_js := 'Css';
    ELSIF v_brush = 'diff' THEN
      v_brush_js := 'Diff';
    ELSIF v_brush = 'java' THEN
      v_brush_js := 'Java';
    ELSIF v_brush = 'plain' THEN
      v_brush_js := 'Plain';
    ELSIF v_brush = 'xml' THEN
      v_brush_js := 'Xml';
    END IF;

    apex_javascript.add_library (p_name => 'shBrush' || v_brush_js, p_directory => p_plugin.file_prefix, p_version => c_version);

    -- Load CSS Library
    apex_css.add_file (p_name => 'shCore' || v_theme, p_directory => p_plugin.file_prefix, p_version => c_version);

    -- Print Syntax
    sys.htp.p ('<pre class="brush: ' || v_brush || '; auto-links: ' || v_auto_links || '; collapse: ' || v_collapse || '; gutter: ' || v_gutter || '; smart-tabs: ' || v_smart_tabs || '; tab-size: ' || v_tab_size || '; toolbar: false;">');
    apex_plugin_util.print_escaped_value (p_value => p_value);
    sys.htp.p ('</pre>');

    -- Run onLoad code
    apex_javascript.add_onload_code (p_code => 'SyntaxHighlighter.all();', p_key => 'SYNTAX_HIGHLIGHTER');

    RETURN v_result;
  END render_syntax_highlighter;
END pkg_apex_plugin;