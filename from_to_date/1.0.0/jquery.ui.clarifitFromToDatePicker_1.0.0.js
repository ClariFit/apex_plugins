/** 
 * ClariFit FromTo Date Picker for APEX
 * Plug-in Type: Item
 * Summary: Handles automatically changing the min/max dates
 *
 * Depends:
 *  jquery.ui.datepicker.js
 *  $.console.js  - http://code.google.com/p/js-console-wrapper/
 *
 * Special thanks to Dan McGhan (http://www.danielmcghan.us) for his JavaScript help
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
 $.widget('ui.clarifitFromToDatePicker', {
  // default options
  options: {
    //Information about the other date picker
    correspondingDatePicker: {  
      dateFormat: '',  //Need other date format since it may not be the same as current date format
      id: '',
      value: ''
      }, //Value during page load
    //Options for this date picker
    datePickerAttrs: {
      autoSize: true,
      buttonImage: '', //Set by plugin attribute
      buttonImageOnly: true,
      changeMonth: true,
      changeYear: true,
      dateFormat: 'mm/dd/yy', //Default date format. Will be set by plugin
      showAnim: '', //By default disable animation
      showOn: 'button'},
    datePickerType: '', //from or to
  },

  /**
   * Init function. This function will be called each time the widget is referenced with no parameters
   */
  _init: function(){
    var uiw = this;
    
    //For this plug-in there's no code required for this section
    //Left here for demonstration purposes
    $.console.log(uiw._scope, '_init', uiw);
  }, //_init
  
  /**
   * Set private widget varables 
   */
  _setWidgetVars: function(){
    var uiw = this;
    
    uiw._scope = 'ui.clarifitFromToDatePicker'; //For debugging
    
    uiw._values = {
      shortYearCutoff: 30, //roll over year
    };
    
    uiw._elements = {
      $otherDate: null 
    };
    
  }, //_setWidgetVars
  
  /**
   * Create function: Called the first time widget is associated to the object
   * Does all the required setup etc and binds change event
   */
  _create: function(){
    var uiw = this;
    
    uiw._setWidgetVars();
    
    var consoleGroupName = uiw._scope + '_create';
    $.console.groupCollapsed(consoleGroupName);
    $.console.log('this:', uiw);
    $.console.log('element:', uiw.element[0]);
    
    var elementObj = $(uiw.element),
        otherDate,       
        minDate = '',
        maxDate = ''
        ;
    
    //Get the initial min/max dates restrictions
    //If other date is not well formmated an exception will be raise
    try{
      otherDate = uiw.options.correspondingDatePicker.value != '' ? $.datepicker.parseDate(uiw.options.correspondingDatePicker.dateFormat, uiw.options.correspondingDatePicker.value, {shortYearCutoff: uiw._values.shortYearCutoff}) : ''
      minDate = uiw.options.datePickerType  == 'to' ? otherDate : '',
      maxDate = uiw.options.datePickerType == 'from' ? otherDate : ''
      uiw._elements.$otherDate = $('#' + uiw.options.correspondingDatePicker.id);
    }
    catch (err){
      $.console.warn('Invalid Other Date', uiw);
    }
    
    //Register DatePicker
    elementObj.datepicker({
      autoSize: uiw.options.datePickerAttrs.autoSize,
      buttonImage: uiw.options.datePickerAttrs.buttonImage,
      buttonImageOnly: uiw.options.datePickerAttrs.buttonImageOnly,
      changeMonth: uiw.options.datePickerAttrs.changeMonth,
      changeYear: uiw.options.datePickerAttrs.changeYear,
      dateFormat: uiw.options.datePickerAttrs.dateFormat,
      minDate: minDate,
      maxDate: maxDate,
      showAnim: uiw.options.datePickerAttrs.showAnim,
      showOn: uiw.options.datePickerAttrs.showOn,
      //Events
      onSelect: function(dateText, inst){
        var extraParams = { dateText: dateText, inst: inst },
          $this = $(this)
        ;
        $this.trigger('change'); // Need to trigger change event so that other date is updated
        $this.trigger('plugineventonselect', extraParams); // Trigger Plugin Event: pluginEventOnSelect if something is listening to it
      }
    });
    
    elementObj.bind('change.' + uiw.widgetEventPrefix, function(){
      // Sets the min/max date for related date element
      // Since this function is being called as an event "this" refers to the DOM object and not the widget "this" object
      // uiw references the UI Widget "this"
      $.console.log(uiw._scope, 'onchange', this); 

      var $this = $(this),
        optionToChange = uiw.options.datePickerType == 'from' ? 'minDate' : 'maxDate',
        selfDate = $.datepicker.parseDate(uiw.options.datePickerAttrs.dateFormat, $this.val(), {shortYearCutoff: 30})
        ;

      uiw._elements.$otherDate.datepicker('option', optionToChange,selfDate); //Set the min/max date information for related date option
    }); //bind
    
    $.console.groupEnd(consoleGroupName);
  },//_create
  
  /**
   * Removes all functionality associated with the clarifitFromToDatePicker 
   * Will remove the change event as well
   * Odds are this will not be called from APEX.
   */
  destroy: function() {
    var uiw = this;
    
    $.console.log(uiw._scope, 'destroy', uiw);
    $.Widget.prototype.destroy.apply(uiw, arguments); // default destroy
    // unregister datepicker
    $(uiw.element).datepicker('destroy');
  }//destroy
}); //ui.clarifitFromToDatePicker
})(apex.jQuery);
