/**
 *	Apttus Config & Pricing
 *	pricing.js
 *	 
 *	@2012-2013 Apttus Inc. All rights reserved.
 * 
 */

// reprice wait panel
	
/**
 * Builds the reprice wait panel.
 */
YAHOO.force.com.buildRepriceWaitPanel = function() {
    document.body.className = document.body.className + " yui-skin-sam";
    YAHOO.force.com.repriceWaitPanel = new YAHOO.widget.Panel(
        "repriceWaitPanel",  // The id of our dialog container
        { 
                width           :   "300px", // You can play with this until it's right
                visible         :   false,   // Should be invisible when rendered
                draggable       :   false,   // Make the dialog draggable
                close           :   false,   // Don't include a close title button
                modal           :   true,    // Make it modal
                fixedCenter     :   true,    // Keep centered if window is scrolled
                zindex          :   40,      // Make sure it's on top of everything
                constraintoviewport: true,
                
                // This line adds the appear/disapper fade effect
                effect			:   {effect:YAHOO.widget.ContainerEffect.FADE,duration:0.25}
							
        }
    );
    
    // header
    YAHOO.force.com.repriceWaitPanel.setHeader(aptRepricingHeader);//"{!$Label.Repricing}");
	// set image
	YAHOO.force.com.repriceWaitPanel.setBody(aptLoadingPageBody);//'<center><img src="{!URLFOR($Resource.Image_LoadingPage)}" /></center>');
    // Render the dialog to the document.body level of the DOM
    YAHOO.force.com.repriceWaitPanel.render(document.body);
    
}

/**
 * Initializes the call to webservices api
 */
function initCall() {
	try {
    	sforce.connection.sessionId = aptSessionId;//"{!$Api.Session_ID}"; //to avoid session timeout
                
    } catch(ex) {
    	cp_erroralert(cp_cERROR_UNKNOWN,ex);
                
	}
}

/**
 * Reprices the given line item
 */
function doCheckAndRepriceLineItems() {
    
    // get parameters
    // current configuration id
    var configId = aptConfigId;//"{!configurationId}";
    
    try {
					
		// STEP I - initialize the call
		initCall();
	
		// STEP II - compute price
		computePriceForCart(configId);
		
	} catch(ex) {
		// hide modal panel
        YAHOO.force.com.repriceWaitPanel.hide();
		// display the error
		cp_erroralert(cp_cERROR_UNKNOWN, ex);
		
	} finally {
		// go to finish page
        goToFinishPage();
		
	}

}

/**
 * Reprices the given line item
 */
function doRepriceLineItem(configId, numItems, currIndex) {
    
    try {
        
        if (currIndex < numItems) {
        
            // STEP I - initialize the call
        	aptClassName.doComputeBasePriceForNextItemColl(configId, function(result, event) {
            
                try {
                    // check response status
                    if (event.status) {
                        // ok response, increment the index
                        currIndex++;
                        // check if done
                        if (currIndex < numItems) {
                            // more to go
                            doRepriceLineItem(configId, numItems, currIndex);
                            
                        } else {
                            // compute total price
                            doComputeTotalPrice(configId);
                        
                        }
                        
                    } else {
                        // throw exception
                        alert(event.message);
                        // hide modal panel
        				YAHOO.force.com.repriceWaitPanel.hide();
                        // go to finish page
			            goToFinishPage();
                    
                    }
                    
                } catch(ex) {
                    // hide modal panel
                    YAHOO.force.com.repriceWaitPanel.hide();
                    // display the error
                    cp_erroralert(cp_cERROR_UNKNOWN, ex);
                    // go to finish page
			        goToFinishPage();
                      
                } 
                
            }, {buffer:false, escape:true, timeout:120000 });
          
         }
          
    } catch(ex) {
         // hide modal panel
        YAHOO.force.com.repriceWaitPanel.hide();
        // display the error
        cp_erroralert(cp_cERROR_UNKNOWN, ex);
        // go to finish page
		goToFinishPage();
			            
    } 
    
}

/**
 * Computes the total price for the cart
 */
function doComputeTotalPrice(configId) {
	
	// register to invoke the function after the page load
    var useMultiStepTotaling = aptUseMultiStepTotaling;//"{!UseMultiStepTotaling}";

    try {
    
      	// check if multi-step totaling should be used
        if (useMultiStepTotaling.toLowerCase() == 'true') {
			// use multi-step totaling
        	// show the modal panel
    		//YAHOO.force.com.repriceWaitPanel.show();
        	// use multi-step totaling
        	doExecuteTotalPriceStepForCart(configId, cp_cTOTALING_STEP1);
	
        } else {
        	// show the modal panel
    		//YAHOO.force.com.repriceWaitPanel.show();
        	// use single step totaling
        	doExecuteTotalPriceStepForCart(configId, cp_cTOTALING_ALLSTEPS);
        
        }
      
    } catch(ex) {
     	// hide modal panel
     	YAHOO.force.com.repriceWaitPanel.hide();
     	// display the error
     	cp_erroralert(cp_cERROR_UNKNOWN, ex);
     	// go to finish page
   		goToFinishPage();
   
    } 
          
 }
        
/**
 * Executes the totaling step for the cart
 */
function doExecuteTotalPriceStepForCart(configId, stepName) {

    // STEP I - initialize the call
	aptClassName.doExecuteTotalPriceStepForCart(configId, stepName, function(result, event) {
     
        try {
            // check response status
            if (event.status) {
                // ok response , check if done
                if (cp_cTOTALING_STEP3 == stepName || 
                	cp_cTOTALING_ALLSTEPS == stepName) {
                    // we are done, go to finish page
		   			goToFinishPage();
                    
                } else {
                    // get the next step
                    var nextStepName = ((cp_cTOTALING_STEP1 == stepName) ? cp_cTOTALING_STEP2 : cp_cTOTALING_STEP3);
                    // execute the next step
                    doExecuteTotalPriceStepForCart(configId, nextStepName);
                
                }
            } else {
                // throw exception
                alert(event.message);
                // hide modal panel
     			YAHOO.force.com.repriceWaitPanel.hide();
                // go to finish page
            	goToFinishPage();
            	
            } 
        } catch(ex) {
          	// hide modal panel
            YAHOO.force.com.repriceWaitPanel.hide();
            // display the error
            cp_erroralert(cp_cERROR_UNKNOWN, ex);
            // go to finish page
			goToFinishPage();
               
        } 
        
    }, {buffer:false, escape:true, timeout:120000 });
           
}

// Function called when the DOM is ready to create the dialog,
// render the dialog into the document body, add our dialog skin
// css to the body tag, and wire up the buttons on our dialog   
YAHOO.force.com.onDOMReady = function() {
	
	// build the reprice wait panel
    YAHOO.force.com.buildRepriceWaitPanel();
	// show modal panel
	//YAHOO.force.com.repriceWaitPanel.show();
	// check and reprice pending line items
    doCheckAndRepriceLineItems();
	
}  	
