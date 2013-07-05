/** 
 * ClariFit jQuery UI Dialog
 * Plug-in Type: Dyanmic Action
 * Summary: Displays a jQueri UI Dialog window for affected elements
 *
 * Depends:
 *  jquery.ui.dialog.js
 *  $.console.js  - http://code.google.com/p/js-console-wrapper/
 *
 * Notes:
 * Object to be shown in Dialog window needs to be wrapped in order to preserve its position in DOM
 * See: http://forums.oracle.com/forums/thread.jspa?messageID=3180532 for more information.
 *
 * ^^^ Contact information ^^^
 * Developed by ClariFit Inc.
 * http://www.clarifit.com
 * apex@clarifit.com
 *
 * ^^^ License ^^^
 * Licensed Under: GNU General Public License, version 3 (GPL-3.0) - http://www.opensource.org/licenses/gpl-3.0.html
 *
 * @author Martin Giffy D'Souza - http://www.talkapex.com
 */
(function($){
 $.widget('ui.clarifitDialog', {
  // default options
  options: {
    //Configurable options in APEX plugin
    modal: true,
    closeOnEscape: true,
    title: '',
    persist: true, //Future option, no affect right now
    onCloseVisibleState: 'prev' //Restore objects visible state once closed
  },

  /**
   * Init function. This function will be called each time the widget is referenced with no parameters
   */
  _init: function(){
    var uiw = this;
    var consoleGroupName = uiw._scope + '._init';
    $.console.groupCollapsed(consoleGroupName);

    //Find the objects visible state before making dialog window (used to restore if necessary)
    uiw._values.beforeShowVisible = uiw._elements.$element.is(':visible');
    $.console.log('beforeShowVisible: ', uiw._values.beforeShowVisible);
    
    //Create Dialog window
    //Creating each time so that we can easily restore its visible state if necessary
    uiw._elements.$element.dialog({
      modal: uiw.options.modal,
      closeOnEscape: uiw.options.closeOnEscape,
      title: uiw.options.title,
      //Options below Can be made configurable if required
      width: 'auto',
      //Event Binding
      beforeClose: function(event, ui) {  $(this).trigger('cfpluginapexdialogbeforeclose', {event: event, ui: ui}); },
      close: function(event, ui) {  
        //Destroy the jQuery UI elements so that it displays as if dialog had not been applied
        uiw._elements.$element.dialog( "destroy" );
        
        //Move out of wrapper and back into original position
        uiw._elements.$wrapper.before(uiw._elements.$element);
        
        //Show only if previous state was show
        if ((uiw._values.beforeShowVisible && uiw.options.onCloseVisibleState == 'prev') || uiw.options.onCloseVisibleState == 'show'){
          uiw._elements.$element.show();
        }
        else {
          uiw._elements.$element.hide();
        }        
        
        //Trigger custom APEX Event
        uiw._elements.$element.trigger('cfpluginapexdialogclose', {event: event, ui: ui}); 
      },
      create: function(event, ui) {  $(this).trigger('cfpluginapexdialogcreate', {event: event, ui: ui}); }
    });

    //Move into wrapper
    uiw._elements.$wrapper.append(uiw._elements.$element.parent('.ui-dialog'));
    
    $.console.groupEnd(consoleGroupName);
  }, //_init
  
  /**
   * Set private widget varables 
   */
  _setWidgetVars: function(){
    var uiw = this;
    
    uiw._scope = 'ui.' + uiw.widgetName; //For debugging

    uiw._values = {
      wrapperId : uiw.widgetName + '_' + parseInt(Math.random()*10000000000000000), //Random number to identify wrapper
      beforeShowVisible: false //Visible state before show
    };
    
    uiw._elements = {
      $element : $(uiw.element[0]), //Affected element
      $wrapper : null
    };
    
  }, //_setWidgetVars
  
  /**
   * Create function: Called the first time widget is associated to the object
   * Does all the required setup etc and binds change event
   */
  _create: function(){
    var uiw = this;
    
    uiw._setWidgetVars();
    
    var consoleGroupName = uiw._scope + '._create';
    $.console.groupCollapsed(consoleGroupName);
    $.console.log('this:', uiw);
    $.console.log('element:', uiw.element[0]);

    //Create wrapper so that we keep object in its current place on the DOM
    uiw._elements.$element.wrap('<div id="' + uiw._values.wrapperId + '"/>');
    uiw._elements.$wrapper = $('#' + uiw._values.wrapperId);
    $.console.log('wrapperId: ', uiw._values.wrapperId);
    
    $.console.groupEnd(consoleGroupName);
  },//_create
  
  /**
   * Removes all functionality associated with the clarifitDialog 
   * Will remove the change event as well
   * Odds are this will not be called from APEX.
   */
  destroy: function() {
    var uiw = this;
    
    $.console.log(uiw._scope, 'destroy', uiw);
    $.Widget.prototype.destroy.apply(uiw, arguments); // default destroy
    // unregister datepicker
    uiw._elements.$element.dialog( "destroy" )
  }//destroy
}); //ui.clarifitDialog

$.extend($.ui.clarifitDialog, {
  /**
   * Function to be called from the APEX Dynamic Action process
   * No values are passed in
   * "this" is the APEX DA "this" object
   */
  daDialog: function(){
    var scope = '$.ui.clarifitDialog.daDialog';
    var daThis = this; //Note that "this" represents the APEX Dynamic Action object
    $.console.groupCollapsed(scope);
    $.console.log('APEX DA this: ' , daThis);
    
    //Set options
    var options = {
      modal: daThis.action.attribute01 === 'false' ? false : true,
      closeOnEscape: daThis.action.attribute02 === 'false' ? false : true,
      title: daThis.action.attribute03,
      onCloseVisibleState: daThis.action.attribute04
    };
    
    for(var i = 0, end = daThis.affectedElements.length; i < end; i++){
      $.console.log('Dialoging: ', daThis.affectedElements[i]);
      $(daThis.affectedElements[i]).clarifitDialog(options);
    }//for
    
    $.console.groupEnd(scope);
  }//daDialog

});//Extend

})(apex.jQuery);
