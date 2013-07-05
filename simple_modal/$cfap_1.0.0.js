/**
 * ClariFit JS APEX Plugin code
 * http://www.clarifit.com
 * apex@clarifit.com
 *
 * Wrapper for ClariFit APEX Plugins
 *  CFAP = ClariFit Apex Plugin
 *
 * Requires:
 *  -$logger_1.0.0.js
 *  -$clarifit_1.0.0.js
 */
$cfap = {};

//*** SimpleModal ***
$cfap.simpleModal = {};

/**
 * Simple Modal: Show
 */
$cfap.simpleModal.show = function (){
  $.console.group('ClariFit: simpleModal.show');
  $.console.log('Apex plugin "this": ', this);
  
  //Variables
  var params = {
    hideOnClose : this.action.attribute01.toLowerCase() == 'true',
    opacity : this.action.attribute02,
    escClose : this.action.attribute03.toLowerCase() == 'true',
    modal : this.action.attribute04.toLowerCase() == 'true',
    backgroundColor : this.action.attribute05
  };
  
  var affectedElements = this.affectedElements;
  
  var vOptions ={
    opacity : params.opacity,
    escClose : params.escClose,
    modal : params.modal,
    onClose : function(dialog){
      $.modal.close();      
      if (params.hideOnClose){
        $.console.log('Automatically closing affected elements');
        affectedElements.hide();
      }
    }//onClose
  };
  
  if (params.backgroundColor != null)
    vOptions.overlayCss = {backgroundColor: params.backgroundColor};
   
  //If no Affected Elements were selected (defaults to document) or invalud affected elements then do nothing
  if(this.affectedElements.length == 0 || (this.affectedElements.length == 1 && this.affectedElements[0] == document)){
      //No elements were provided
    $.console.warn('No affected elements, nothing to do.');
  }
  else{
    //Show objects
    //Recommended to show only 1 object, but can handle more
    if (this.affectedElements.length > 1)
      $.console.info('More than 1 affected elements. Not recommended');
    $clarifit.modalShow(this.affectedElements, vOptions);
  }
  $.console.groupEnd();
}// $cfap.modalShow

/**
 * Close Simple Modal 
 */
$cfap.simpleModal.close = function (){
  $.console.group('ClariFit: simpleModal.close');
  $clarifit.modalClose();
  $.console.groupEnd();
}//$cfap.simpleModalShow