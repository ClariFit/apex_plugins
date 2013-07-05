CREATE OR REPLACE PACKAGE pkg_apex_plugin
AS
  FUNCTION render_syntax_highlighter (p_item                  IN apex_plugin.t_page_item,
                                      p_plugin                IN apex_plugin.t_plugin,
                                      p_value                 IN VARCHAR2,
                                      p_is_readonly           IN BOOLEAN,
                                      p_is_printer_friendly   IN BOOLEAN)
    RETURN apex_plugin.t_page_item_render_result;
END pkg_apex_plugin;