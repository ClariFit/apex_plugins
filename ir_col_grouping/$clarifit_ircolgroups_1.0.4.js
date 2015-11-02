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
 *  1.0.3
 *    - Fixed issue of error when no rows found
 *    - Changed references of $ jQuery namespace to apex.jQuery
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
    return '<th colspan="' + pColSpan + '"><span>' + (pGrpName.length > 0 ? pGrpName : '&nbsp;') + '</span></th>';
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
    //apex.jQuery.console.logParams();
    
    // retrieve the Interactive report table
    var vTbl = apex.jQuery('.a-IRR-table');
    
    if (vTbl.length != 0) {
		// Prevent Duplicate rows
		apex.jQuery('#' + pOptions.irColGroupRowId).remove();

		// Add the Column Group row
		apex.jQuery(vTbl[0].rows[0]).before('<tr id="' + pOptions.irColGroupRowId + '"></tr>');
	
		var vIRColGrpRow = apex.jQuery('#' + pOptions.irColGroupRowId);
		var vPrevColGrp = '';
		var vColGrpExists = false;
		var vColSpan = 1;
	
		// Loop over the row headers and see if we need to add a column group.
		//apex.jQuery.console.groupCollapsed('Column Info');
		//Only loop through each row if there is data. Required for when "No Data Found" issue
		if (vTbl[0].rows.length > 0) {
		  for (var i = 0; i < apex.jQuery(vTbl[0].rows[1].cells).length; i++){
			// For IR, the column headers have divs with id of apexir
			vColId = '';
			// Only set the col ID if it exists (needed for IR row_id icon)
			if (typeof(apex.jQuery('.a-IRR-table tr:eq(1) th:eq(' + i + ')').attr('id')) != "undefined")
			  vColId = apex.jQuery('.a-IRR-table tr:eq(1) th:eq(' + i + ')').attr('id').toUpperCase();
			var vColGrp = ''; // Current Column group
		
			// Find the ID in the IR Groups global variable (genereated in AP)
			for (var j = 0; j < pColGrps.columns.length; j ++ ){
			  if (pColGrps.columns[j].column_alias.toUpperCase() == vColId) {
				vColGrpExists = true;
				vColGrp = pColGrps.columns[j].column_group;
				break;
			  }//if
			}// For IR Col Groups
		
			//apex.jQuery.console.log('Column Id: ' + vColId, ' Group: ' + vColGrp);
			// Only print the col group header for the previous entry. This allows us to set the col span for similar groups
			// Have to do it this way to support IE  (otherwise we could look at the previous entry and update it's col span
		 
			// If the current previous column group is the same as the current group then keep going (don't print yet)
			if (vColGrp == vPrevColGrp){
			  vColSpan = (i ==0 ? 1 : vColSpan + 1); //If it's the first column only set the colspan to 1
			  //apex.jQuery.console.log('Group same as previous. ', 'Colspan: ', vColSpan);
			}
			else if(i > 0) {
			  // Display the previous item
			  //apex.jQuery.console.log('New Group. Print previous group with ColSpan: ', vColSpan);
			  vIRColGrpRow.append(getColGrpThHtml(vColSpan,vPrevColGrp));
			  vColSpan = 1;
			}
		 
			// If this is the last item then display it
			if (i == apex.jQuery(vTbl[0].rows[1].cells).length-1) {
			  //apex.jQuery.console.log('Last column. Print regardless. ColSpan: ', vColSpan);
			  vIRColGrpRow.append(getColGrpThHtml(vColSpan,vColGrp));
			}
		
			vPrevColGrp = vColGrp;
		  }// For each column being displayed
		}// If rows exist
		else {
		  // No Columns
		  //apex.jQuery.console.log('No columns found');
		}
		//apex.jQuery.console.groupEnd();
	
		// Remove the col group heading if no column groups:
		if (!vColGrpExists)
			vIRColGrpRow.remove();
		else {
		  // Set CSS attributes
		  apex.jQuery('#' + pOptions.irColGroupRowId + ' th span').css({
			'text-decoration': 'none',
			'cursor': 'default',
			'padding': '12px',
			'display': 'block',
			'text-align': 'inherit'
		  });
	  
		  if (pOptions.dispBorder){
			// Set column border
			var irColRow = apex.jQuery('.a-IRR-table th:eq(0)');
			apex.jQuery('#' + pOptions.irColGroupRowId + ' th').addClass('a-IRR-header');
/*			apex.jQuery('#' + pOptions.irColGroupRowId + ' th').css({
			  'border-right-width' : irColRow.css('border-bottom-width'),
			  'border-right-color' : irColRow.css('border-bottom-color'),
			  'border-right-style' : irColRow.css('border-bottom-style')
			});
*/
		  }// disp border
		} //else
    } // if tbl
  };//dispColGrp
  
  /** 
   * Wrapper to be called from Plugin
   * @param pThis Dynamic Action "this" object
   *  pThis.action.attribute01: (json) JSON object of column groups
   *  pThis.action.attribute02: (string) ID for column group row in table
   *  pThis.action.attribute03: (string) String representation of true or false to display border on column group
   */
  that.loadColGrp = function(pThis){
    //apex.jQuery.console.groupCollapsed(pThis.action.action);
    //apex.jQuery.console.log('this', pThis);
    
    var vOptions = {
      irColGroupRowId: pThis.action.attribute02,
      dispBorder: (pThis.action.attribute03.toLowerCase() == 'true' ? true : false)
    };
    dispColGrp(eval('(' + pThis.action.attribute01 + ')'), vOptions); //$u_eval: converts JSON text to object
    //apex.jQuery.console.groupEnd();
  }; //loadColGrp
  
  return that; // Return public functions
})();//apex.jQueryclarifitIRColGroup