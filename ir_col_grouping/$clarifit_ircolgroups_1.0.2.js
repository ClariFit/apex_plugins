/**
 * Displays Column Groups in Interactive Reports (IR)
 *
 * Based off of: http://www.talkapex.com/2009/03/column-groups-in-apex-interactive.html
 *
 * Uses Console Logger: http://www.talkapex.com/2010/08/javascript-console-logger.html
 * 
 * Developed by Clarifit
 * http://www.clarifit.com
 * apex@clarifit.com
 *
 * Change Log
 *  1.0.1
 *    - Fixed issue with shifting
 *  1.0.2
 *    - Fixed issue when you uncheck all options available to column in "Allow Users To:"
 */
$clarifitIRColGroup = (function(){
  that = {}; //Public objects
  
  /**
   * Returns the TH for the column groups
   * Requred in a function since referenced twice (once in loop and once at end)
   *
   * @param pColSpan TH Column span
   * @param pGrpName Name of group to appear in TH to user
   * @return HTML text for TH (including TH)
   */
  this.getColGrpThHtml = function(pColSpan, pGrpName){
    return '<th colspan="' + pColSpan + '"><div>' + (pGrpName.length > 0 ? pGrpName : '&nbsp;') + '</div></th>';
  }; //getColGrpThHtml
  
  /**
   * Injects the column group header above the column rows
   * Will use the same styles used for the column headers
   *
   * @param pColGrps JSON object of column groups. Each entry contains a "column_alias" and "column_group"
   * @param pOptions
   *  - irColGroupRowId (string): ID to use for Column Group row. If null then "irColGrpRow" will be used
   *  - dispBorder (boolean): Display border for column groups. Default to true
   */
  this.dispColGrp = function(pColGrps,pOptions){
    //Set Default Options
    var vDefaults = {
      irColGroupRowId: 'irColGrpRow',
      dispBorder: true
    };
    pOptions = jQuery.extend(true,vDefaults, pOptions);
    
    if (pOptions.irColGroupRowId.length == 0)
      pOptions.irColGroupRowId = 'irColGrpRow';
  
    //Log Parameters
    $.console.logParams();
    
    // retrieve the Interactive report table
    var vTbl = $('.apexir_WORKSHEET_DATA');
    
    // Prevent Duplicate rows
    $('#' + pOptions.irColGroupRowId).remove();

    // Add the Column Group row
    $(vTbl[0].rows[0]).before('<tr id="' + pOptions.irColGroupRowId + '"></tr>');
    
    var vIRColGrpRow = $('#' + pOptions.irColGroupRowId);
    var vPrevColGrp = '';
    var vColGrpExists = false;
    var vColSpan = 1;
    
    // Loop over the row headers and see if we need to add a column group.
    $.console.groupCollapsed('Column Info');
    for (var i = 0; i < $(vTbl[0].rows[1].cells).length; i++){
      // For IR, the column headers have divs with id of apexir
      vColId = '';
      // Only set the col ID if it exists (needed for IR row_id icon)
      if (typeof($('.apexir_WORKSHEET_DATA tr:eq(1) th:eq(' + i + ')').attr('id')) != "undefined")
        vColId = $('.apexir_WORKSHEET_DATA tr:eq(1) th:eq(' + i + ')').attr('id').toUpperCase();
      var vColGrp = ''; // Current Column group
      
      // Find the ID in the IR Groups global variable (genereated in AP)
      for (var j = 0; j < pColGrps.columns.length; j ++ ){
        if (pColGrps.columns[j].column_alias.toUpperCase() == vColId) {
          vColGrpExists = true;
          vColGrp = pColGrps.columns[j].column_group;
          break;
        }//if
      }// For IR Col Groups
      
      $.console.log('Column Id: ' + vColId, ' Group: ' + vColGrp);
      // Only print the col group header for the previous entry. This allows us to set the col span for similar groups
      // Have to do it this way to support IE  (otherwise we could look at the previous entry and update it's col span
       
      // If the current previous column group is the same as the current group then keep going (don't print yet)
      if (vColGrp == vPrevColGrp){
        vColSpan = (i ==0 ? 1 : vColSpan + 1); //If it's the first column only set the colspan to 1
        $.console.log('Group same as previous. ', 'Colspan: ', vColSpan);
      }
      else if(i > 0) {
        // Display the previous item
        $.console.log('New Group. Print previous group with ColSpan: ', vColSpan);
        vIRColGrpRow.append(getColGrpThHtml(vColSpan,vPrevColGrp));
        vColSpan = 1;
      }
       
      // If this is the last item then display it
      if (i == $(vTbl[0].rows[1].cells).length-1) {
        $.console.log('Last column. Print regardless. ColSpan: ', vColSpan);
        vIRColGrpRow.append(getColGrpThHtml(vColSpan,vColGrp));
      }
      
      vPrevColGrp = vColGrp;
    }// For each column being displayed
    $.console.groupEnd();
    
    // Remove the col group heading if no column groups:
    if (!vColGrpExists)
        vIRColGrpRow.remove();
    else {
      // Set CSS attributes
      $('#' + pOptions.irColGroupRowId + ' th div').css({
        'text-decoration': 'none',
        'cursor' : 'default'
      });
      
      if (pOptions.dispBorder){
        // Set column border
        var irColRow = $('.apexir_WORKSHEET_DATA th:eq(0)');
        $('#' + pOptions.irColGroupRowId + ' th').css({
          'border-right-width' : irColRow.css('border-bottom-width'),
          'border-right-color' : irColRow.css('border-bottom-color'),
          'border-right-style' : irColRow.css('border-bottom-style')
        });
      }// disp border
    } //else

  };//dispColGrp
  
  /** 
   * Wrapper to be called from Plugin
   * @param pThis Dynamic Action "this" object
   *  pThis.action.attribute01: (json) JSON object of column groups
   *  pThis.action.attribute02: (string) ID for column group row in table
   *  pThis.action.attribute03: (string) String representation of true or false to display border on column group
   */
  that.loadColGrp = function(pThis){
    $.console.groupCollapsed(pThis.action.action);
    $.console.log('this', pThis);
    
    var vOptions = {
      irColGroupRowId: pThis.action.attribute02,
      dispBorder: (pThis.action.attribute03.toLowerCase() == 'true' ? true : false)
    };
    dispColGrp($u_eval('(' + pThis.action.attribute01 + ')'), vOptions); //$u_eval: converts JSON text to object

    $.console.groupEnd();
  }; //loadColGrp
  
  return that; // Return public functions
})();//$clarifitIRColGroup