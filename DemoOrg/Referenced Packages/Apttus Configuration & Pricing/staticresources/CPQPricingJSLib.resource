/**
 *	Apttus Config & Pricing
 *	CPQPricingJS.js
 *	 
 *	@2012-2013 Apttus Inc. All rights reserved.
 * 
 */

/**
 * Calculates price for all pending line items
 */

 j$(function() {
    if(j$.aptActionFunctionQueue) {
        // set global variables for behavior in queue
        j$.aptActionFunctionQueue.setSkipToEndOfQueue(sfdcInvokePageRefresh);
        j$.aptActionFunctionQueue.setPrecedence(doUpdatePriceForCart, -90);      // pricing should be processed last by queue
        j$.aptActionFunctionQueue.setPrecedence(sfdcInvokePageRefresh, -100);    // refresh page after pricing is complete
    }
 });

function doAutomaticPricing() {
    // current configuration id
    var configId = j$.APTTUS.configurationId;
    //console.log('start doAutomaticPricing configId = ' + configId);

    try {
        var pendingLineNumbers = j$.APTTUS.LineNumbersAwaitingPrice;        
        if (j$.APTTUS.enableQueuedPricing) {        
            if (pendingLineNumbers.length > 0) {                
                if(!j$.aptActionFunctionQueue.isQueued(doUpdatePriceForCart)) { // asynch method will queue itself again if needed.
                    j$.aptActionFunctionQueue.execute(doUpdatePriceForCart, [configId], true, j$.APTTUS.updatingPriceLabel);
                }                
            }
        } else {
            if (pendingLineNumbers.length > 1) {
                //j$.APTTUS.showPricingWaitPanel();
                computeBasePriceForItemColl(configId, pendingLineNumbers, 0);

            } else if (pendingLineNumbers.length == 1) {
                //j$.APTTUS.showPricingWaitPanel();
                computeNetPriceForItemColl(configId, pendingLineNumbers[0]);
            
            }             
        }

    } catch(ex) {
        j$.APTTUS.hidePricingWaitPanel();
        // display the error
        cp_erroralert(cp_cERROR_UNKNOWN, ex);
    	// refresh view state
   		invokePageRefresh();
        
    } 
    
}


/**
 * Updates the price for items in the given product configuration
 * Only line items in pending status are updated.
 * Total price is always computed
 * @param configId the product configuration id to update the price for
 */
function doUpdatePriceForCart(configId) {
    //console.log('doUpdatePriceForCart configId = ' + configId);
    try {
          
        Visualforce.remoting.Manager.invokeAction(j$.APTTUS.RemoteController.doUpdatePriceForCart, configId, function(result, event) {
            try {
                // check response status
                if (event.status) {
                    // ok response, check if done
                    //if (result.IsPricePending.toLowerCase() == 'true') {  
                    if (result.IsPricePending == true) {
                        // more to go
                        j$.aptActionFunctionQueue.execute(doUpdatePriceForCart, [configId], true, j$.APTTUS.updatingPriceLabel);                        
                        
                    } else {
                        // reload the page                        
                        invokePageRefresh();                    
                    }
                    
                } else {
                    // throw exception
                    //alert(event.message);
                    // reload the page
                    invokePageRefresh();
                
                }
                
            } catch(ex) {
                // display the error
                cp_erroralert(cp_cERROR_UNKNOWN, ex);
                // reload the page
                invokePageRefresh();
                  
            }

            // Call process next on completion.
            j$.aptActionFunctionQueue.processNext();
            
        }, {buffer:false, escape:true, timeout:120000 });
           
    } catch(ex) {
        // display the error
        cp_erroralert(cp_cERROR_UNKNOWN, ex);
        // reload the page
        invokePageRefresh();
        // Call process next on failure.
        j$.aptActionFunctionQueue.processNext();                        
    } 
}

/**
 * Calculates price for all pending line items
 * @param contextLineNumber is passed only from attribute and options pages
 */
function doPricePendingLineItems(contextLineNumber) {
    // current configuration id
    var configId = j$.APTTUS.configurationId;
    //console.log('start doPricePendingLineItems configId = ' + configId + ', contextLineNumber = ' + contextLineNumber);

    try {
        if (contextLineNumber != undefined && contextLineNumber != 0) {
        	if (j$.APTTUS.LineNumbersAwaitingPrice.length > 0) {
        		j$.APTTUS.LineNumbersAwaitingPrice.push(contextLineNumber);
        	} else {
        		j$.APTTUS.LineNumbersAwaitingPrice = [contextLineNumber];
        	}
        }
    
        var pendingLineNumbers = j$.APTTUS.LineNumbersAwaitingPrice;
        
        //console.log('start doPricePendingLineItems pendingLineNumbers = ' + pendingLineNumbers);
        
		if (pendingLineNumbers.length > 1) {
        	j$.APTTUS.showPricingWaitPanel();
            computeBasePriceForItemColl(configId, pendingLineNumbers, 0);

        } else if (pendingLineNumbers.length == 1) {
        	j$.APTTUS.showPricingWaitPanel();
            computeNetPriceForItemColl(configId, pendingLineNumbers[0]);
        
        } else {
        	if (typeof invokeDoUpdateCart == 'function') {
        		invokeDoUpdateCart();
        	}
        	
        } 

    } catch(ex) {
        j$.APTTUS.hidePricingWaitPanel();
        // display the error
        cp_erroralert(cp_cERROR_UNKNOWN, ex);
    	// refresh view state
   		invokePageRefresh();
        
    } 
    
}

/**
 * compute price for the given line item
 */
function computeBasePriceForItemColl(configId, lineNumbers, currIndex) {
	//console.log('computeBasePriceForItemColl lineNumber = ' + lineNumbers[currIndex]);
    try {
        if (currIndex < lineNumbers.length) {            
            Visualforce.remoting.Manager.invokeAction(j$.APTTUS.RemoteController.doComputeBasePriceForItemColl, configId, lineNumbers[currIndex], function(result, event) {
        	    try {
                    // check response status
                    if (event.status) {
                        // ok response, increment the index
                        currIndex++;

                        // check if done
                        if (currIndex < lineNumbers.length - 1) {
                            // more to go
                            computeBasePriceForItemColl(configId, lineNumbers, currIndex);
                            
                        } else {
                            //compute for last line item and total price
                            computeNetPriceForItemColl(configId, lineNumbers[currIndex]);
                        
                        }
                        
                    } else {
                        // throw exception
                        //alert(event.message);
                        j$.APTTUS.hidePricingWaitPanel();
                        // refresh view state
   						invokePageRefresh();
                    
                    }
                    
                } catch(ex) {
                    // hide modal panel
                    j$.APTTUS.hidePricingWaitPanel();
                    // display the error
                    cp_erroralert(cp_cERROR_UNKNOWN, ex);
                    // refresh view state
   					invokePageRefresh();
                      
                } 
                
            }, {buffer:false, escape:true, timeout:120000 });
          
         }
          
    } catch(ex) {
         // hide modal panel
        j$.APTTUS.hidePricingWaitPanel();
        // display the error
        cp_erroralert(cp_cERROR_UNKNOWN, ex);
        // refresh view state
   		invokePageRefresh();
			            
    } 
    
}

/**
 * compute price for the given line item
 * and compute total price
 */
function computeNetPriceForItemColl(configId, lineNumber) {
	//console.log('computeNetPriceForItemColl lineNumber = ' + lineNumber);
    try {
    	Visualforce.remoting.Manager.invokeAction(j$.APTTUS.RemoteController.doComputeNetPriceForItemColl, configId, lineNumber, function(result, event) {
	    	try {
	            // check response status
	            if (event.status) {
	                //j$.APTTUS.hidePricingWaitPanel();
	                // refresh view state
					invokePageRefresh();
	                
				} else {
	                // throw exception
	                //alert(event.message);
	                j$.APTTUS.hidePricingWaitPanel();
	                // refresh view state
					invokePageRefresh();
	            
	           	}
	            
	        } catch(ex) {
	            // hide modal panel
	            j$.APTTUS.hidePricingWaitPanel();
	            // display the error
	            cp_erroralert(cp_cERROR_UNKNOWN, ex);
	            // refresh view state
				invokePageRefresh();
	              
	        } 
	            
	        }, {buffer:false, escape:true, timeout:120000 });
          
    } catch(ex) {
         // hide modal panel
        j$.APTTUS.hidePricingWaitPanel();
        // display the error
        cp_erroralert(cp_cERROR_UNKNOWN, ex);
        // refresh view state
   		invokePageRefresh();
			            
    } 
    
}

/**
 * compute total price
 */
function doComputeTotalPrice() {
	var configId = j$.APTTUS.configurationId;
	//console.log('computeTotalPriceForCart');
    try {
    	Visualforce.remoting.Manager.invokeAction(j$.APTTUS.RemoteController.doComputeTotalPriceForCart, configId, function(result, event) {
	    	try {
	            // check response status
	            if (event.status) {
	                j$.APTTUS.hidePricingWaitPanel();
	                // refresh view state
					invokeRefreshMiniCart();
	                
				} else {
	                // throw exception
	                //alert(event.message);
	                j$.APTTUS.hidePricingWaitPanel();
	                // refresh view state
					invokePageRefresh();
	            
	           	}
	            
	        } catch(ex) {
	            // hide modal panel
	            j$.APTTUS.hidePricingWaitPanel();
	            // display the error
	            cp_erroralert(cp_cERROR_UNKNOWN, ex);
	            // refresh view state
				invokePageRefresh();
	              
	        } 
	            
	        }, {buffer:false, escape:true, timeout:120000 });
          
    } catch(ex) {
         // hide modal panel
        j$.APTTUS.hidePricingWaitPanel();
        // display the error
        cp_erroralert(cp_cERROR_UNKNOWN, ex);
        // refresh view state
   		invokePageRefresh();
			            
    } 
    
}

/**
 * Show pricing wait dialog
 */
j$.APTTUS.showPricingWaitPanel = function() { 	
  	// Create and open dialog window
  	j$.APTTUS.pricingWaitPanel = 
	 	j$("#pricingWaitPanel").dialog({
	 		dialogClass: "no-close pricingWaitPanel",
	 		autoOpen: true,	 			 		
	 		resizable: false,
	 		modal: true,
	 		position: 'center',
	 		draggable: true,
	 		height:110,
	 		title : j$.APTTUS.updatingPriceLabel,
	 		create:function(){
				j$('.pricingWaitPanel .ui-dialog-titlebar').remove();
			}
	 	});

  	return false;
  	
}

/**
 * Hide the pricing wait dialog
 */
j$.APTTUS.hidePricingWaitPanel = function () {
	if(typeof j$.APTTUS.pricingWaitPanel !== 'undefined') {
		j$.APTTUS.pricingWaitPanel.dialog("close");
	}

}

/**
 * Invoke page refresh after automatic pricing
 */
function invokePageRefresh() {
	if(!j$.aptActionFunctionQueue.getIsQueuePaused()) {
		j$.APTTUS.hidePricingWaitPanel();//bypass shopping cart displays price wait panel
		//invoke to page refresh
		j$.aptActionFunctionQueue.execute(sfdcInvokePageRefresh, null, true, j$.APTTUS.refreshingDataLabel);
	}
}

function invokeRefreshMiniCart() {
    //invoke refresh mini cart
    if (sfdcInvokeRefreshMiniCart) {
        j$.aptActionFunctionQueue.execute(sfdcInvokeRefreshMiniCart, null, true, j$.APTTUS.refreshingDataLabel);
    }
}
