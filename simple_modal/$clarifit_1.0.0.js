/**
 * ClariFit JS code
 * http://www.clarifit.com
 * apex@clarifit.com
 *
 * Requires
 *  - SimpleModal 1.3.5
 */
$clarifit = {};

/**
 * Displays Object(s) as modal
 * Only allows for one modal window open at a time
 * To close modal window, call $clarifit.modalClose();
 *
 * Requires:
 * - http://www.ericmmartin.com/projects/simplemodal/
 *
 * Please note you can't call the simple modal by itself. It will work but you will run into issues with APEX items.
 * See: http://forums.oracle.com/forums/thread.jspa?messageID=3180532 for more information.
 *
 * Used in:
 *  - COM.CLARIFIT.APEXPLUGIN.SIMPLE_MODAL_SHOW
 *
 * @param pObj object(s) (preferably this references a region) to make modal
 * @param pOptions Options for modal Screen. See: http://www.ericmmartin.com/projects/simplemodal/#options for more info
 */
$clarifit.modalShow = function(pObj, pOptions){
  var vDefaults = {
    persist: true, //If true, the data will be maintained across modal calls, if false, the data will be reverted to its original state. (i.e. it will be deleted
    overlayCss: {backgroundColor: '#606060'} //Dark Grey
  }; 
  
  //Extend default options
  pOptions = jQuery.extend(true,vDefaults, pOptions);
  
  // Maintain order of APEX items (see forum posting above)
  $(pObj).wrap('<div></div>'); 
  
  // Make sure the region is visible
  $(pObj).show();
  
  // Open Modal Screen
  $(pObj).modal(pOptions);  
}//$clarifit.modalShow 

/**
 * Closes the modal screen
 *
 * Used in:
 *  - COM.CLARIFIT.APEXPLUGIN.SIMPLE_MODAL_CLOSE
 */
$clarifit.modalClose = function(){
  $.modal.close();
}// $clarifit.modalClose


