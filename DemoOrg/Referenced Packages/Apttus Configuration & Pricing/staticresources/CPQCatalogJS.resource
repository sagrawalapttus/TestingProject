/**************************************************************************************************************************************************************
 * Apttus CPQ Catalog JS file
 * @2010-2013 Apttus Inc. All rights reserved.
 * SelectConfigProductsFilterView ----------------------------------------------------------------------------------------------------------------------------
 *************************************************************************************************************************************************************/

var clsNodes;
var selectedNodeId;
var selectedNodeType;
var numberOfRoots;
var theTree;
var isSelectedNodeLeaf;
var data;

j$(document).ready(function(){

	// j$('.jslider').resize();

	j$('#relocateChatter').html(j$('#cartHeaderDiv').html());
	j$('#cartHeaderDiv').html('');	
	
	j$('input[type="button"]').removeClass('btn');
		
	
	// bind enter key to search input
	j$('.apt-search-query').keydown(searchInputKeyPress);
	// bind reset search to its' toggle
	j$('#clearSearch').click(resetSearch);
	
	// setup the remove confirmation dialog
	j$("#productDetailPanel").dialog({
		autoOpen: false,
		draggable: false,
		modal: true,
		resizable: false,
		position: 'center'
		
	});	

	// only process calls to these functions once, i.e. process only the last call to it	
	j$.aptActionFunctionQueue.setSkipToEndOfQueue([
		sfdcInvokeDoGetClassificationProducts,
		sfdcInvokeDoProcessMoreRules,
		sfdcInvokeDoClearSearchResults
	]);	

	// Set queue precedence 
	// ******* ANYTHING WITH NO PRECEDENCE WILL BE PROCESSED FIRST *******

	j$.aptActionFunctionQueue.setPrecedence({
		sfdcInvokeDoGetClassificationProducts: 99, //high preedence will be processed first
		sfdcInvokeDoAddProductToCart: 2,
		sfdcInvokeDoDeleteLineItem: 2,
		sfdcInvokeDoProcessMoreRules: 1,
		sfdcInvokeDoConfigure: 0,
		sfdcInvokeDoConfigureProduct: 0
	});

});

/**
 * Pause queueing
 */
function pauseQueue() {
	// set queue paused param
	j$.aptActionFunctionQueue.updateSetting('isQueuePaused', true);
}

/**
 * Resume queueing
 */
function resumeQueue() {
	// un-pause queue and push along	
	if(j$.aptActionFunctionQueue.updateSetting('isQueuePaused', false)) { 		
		j$.aptActionFunctionQueue.processNext(); // only process next if queue was paused
	}
}

/**
 * Invoke add product to cart -- from constraint
 * choice dialog panel
 *
 * @param 	selectProductId
 *			Id of product to add to cart 
 * @param 	ruleActionId
 *			Rule action id
 * @param 	ruleId
 *			rule id
 * @param 	rulePrimaryNumber
 *			rule primary line #
 * @param 	button
 *			ctx button
 */
function invokeDoSelectProduct(selectProductId, ruleActionId, ruleId, rulePrimaryNumber, button) {
	// show button status spinner
	showConstraintRuleButtonSpinner(button);
	// hide rule prompt
	j$.APTTUS.hideRulePrompt();

	var params = {
		selectProductId: selectProductId,
		quantity: 1,
		ruleActionId: ruleActionId,
		ruleId: ruleId,
		rulePrimaryNumber: parseInt(rulePrimaryNumber)

	};

	//invoke select product
	j$.aptActionFunctionQueue.execute(sfdcInvokeDoAddProductToCart, params, false, j$.APTTUS.addingProductLabel).then(sfdcInvokeRefreshAfterAdd);
	// resume queue
	resumeQueue();
}


/**
 * Invoke replace product -- from constraint
 * choice dialog panel
 *
 * @param 	selectProductId
 *			Id of product to add to cart 
 * @param 	ruleActionId
 *			Rule action id
 * @param 	ruleId
 *			rule id
 * @param 	rulePrimaryNumber
 *			rule primary line #
 * @param 	button
 *			ctx button
 */
function invokeDoReplaceProduct(selectProductId, ruleActionId, ruleId, rulePrimaryNumber, button) {
	// show button status spinner
	showConstraintRuleButtonSpinner(button);
	// hide rule prompt
	j$.APTTUS.hideRulePrompt();
	//invoke select product
	j$.aptActionFunctionQueue.execute(sfdcInvokeDoReplaceProduct, [selectProductId, ruleActionId, ruleId, rulePrimaryNumber], true, j$.APTTUS.replaceingProductLabel)
							 .then(sfdcInvokeRefreshAfterAdd);
	// resume queue
	resumeQueue();
}

/**
 * Invoke remove product -- from constraint
 * choice dialog panel
 * 
 *
 * @param 	selectProductId
 *			Id of product to add to cart 
 * @param 	ruleActionId
 *			Rule action id
 * @param 	rulePrimaryNumber
 *			rule primary line #  
 * @param 	button
 *			ctx button
 */
function invokeDoRemoveProduct(selectProductId, ruleActionId, rulePrimaryNumber, button) {
	// show button status spinner
	showConstraintRuleButtonSpinner(button);	
	// hide rule prompt
	j$.APTTUS.hideRulePrompt();
	//invoke select product
	j$.aptActionFunctionQueue.execute(sfdcInvokeDoRemoveProduct, [selectProductId, ruleActionId, rulePrimaryNumber], true, j$.APTTUS.removingProductLabel);
	// resume queue
	resumeQueue();
}


/**
 * Add product to cart
 *
 * @param 	productId
 *			Id of product to add to cart
 *
 * @param 	spinnerId
 *			Id of ctx product spinner
 */
function invokeDoAddProductToCart(productId, quantityId) {
	var quantity = parseFloat(j$(document.getElementById(quantityId)).val());
	
	//invoke add to cart 
	j$.aptActionFunctionQueue.execute(sfdcInvokeDoAddProductToCart, {'selectProductId': productId, 'quantity':quantity },false, j$.APTTUS.addingProductLabel)
							 .then(sfdcInvokeRefreshAfterAdd);
}

/**
 * Remove line item from cart
 *
 * @param 	lineNumber
 *			the line number of the line item to be 
 *			removed
 */
function invokeDoDeleteLineItem(lineNumber) {	
	
	//set line number
	if(lineNumber == undefined || lineNumber == null) {
		lineNumber = j$.APTTUS.LineNumber;
	}	
	
	//invoke delete line item
	j$.aptActionFunctionQueue.execute(sfdcInvokeDoDeleteLineItem, [j$.APTTUS.LineNumber], true, j$.APTTUS.deletingLineItemLabel)
							 .then(
							 	function() {		
							 		// Compute total price
						 			doComputeTotalPrice();
						 			// refresh major panels (pricing will cause refresh also)							 			
						 			sfdcInvokeRefreshAfterDelete();		 		
								});

	//hide confirmation dialog							 
	j$.APTTUS.hideRemoveConfirmation();
}

/**
 * Add product to cart and configure it
 *
 * @param 	productId
 *			Id of product to add to cart
 *
 * @param 	spinnerId
 *			Id of ctx product spinner
 */
function invokeDoConfigureProduct(productId, quantityId) {
	//get quantity
	var quantity = parseFloat(j$(document.getElementById(quantityId)).val());
	
	//invoke add to cart
	j$.aptActionFunctionQueue.execute(sfdcInvokeDoConfigureProduct, 
									 {'selectProductId': productId, 'quantity':quantity}, 
									 false, 
									 j$.APTTUS.configuringProductLabel);
}

/**
 * Configure line item
 * 
 * @param 	proceedLineItemId
 *			Id of LineItem to configure
 */
function invokeDoConfigure(proceedLineItemId) {
	// disable inputs
	disableInputsOnConfigure(true);
	//invoke add to cart
	j$.aptActionFunctionQueue.execute(sfdcInvokeDoConfigure, [proceedLineItemId], true, j$.APTTUS.configuringProductLabel)
							 .then(
							 	function() {							 		
							 		 if(!j$.aptActionFunctionQueue.isQueued(sfdcInvokeDoConfigure)) {
							 		 
								 	 }
								}, null, 
								function() {
								
								});
}

/**
 * Save selected product so for compare.
 * 
 * @param 	prodSOId
 *			Id of product sObject to compare 
 *
 * @param 	isChecked
 *			Is selected to compare indicator
 */
function invokeSaveSelectedComparision(prodSOId, isChecked) {
	// add to action function queue
	j$.aptActionFunctionQueue.execute(sfdcSaveSelectedComparision, {'selectedId': prodSOId, 'isChecked': isChecked }, false, j$.APTTUS.savingForCompareLabel);
}

/**
 * Process pending constraint rules
 */
function invokeDoProcessMoreRules() {
	// queue up processing
	j$.aptActionFunctionQueue.execute(sfdcInvokeDoProcessMoreRules, null, true, j$.APTTUS.processingConstraintRulesLabel);

}

/**
 * Show/Hide select (list) products spinner
 * 
 * @param 	onOff
 *			flag indicating whether to turn 
 *			the spinner on or off
 */
function toggleSelectProductsSpinner(onOff) {	
	if(onOff) {
		j$('[Id*="selectProductStatus.start"]').show();
	} else {
		j$('[Id*="selectProductStatus.start"]').hide();
	}

}

/**
 * Show select product spinner image
 * and position it on top of button
 * 
 * @param 	button
 *			reference button
 */
function showConstraintRuleButtonSpinner(button, isCancelButton) {
    posLeft = j$(button).position().left + (isCancelButton ? 13 : 5);
    posTop = j$(button).position().top + (isCancelButton ? 8: 5);
    j$('.' + (isCancelButton ? 'constraintRuleCancelStatus' : 'constraintRuleButtonStatus')).css({
                    'position':'absolute',
                    'top' : posTop + 'px',
                    'left': posLeft + 'px'});

    // disable button
    j$(button).attr('disabled','disable').addClass('aptButtonDisabled'); 
}

 /**
 * Disable/Enable buttons on configure action
 * 
 * @param 	disable
 *			flag indicating whether to disable
 *			related fields or not
 */
function disableInputsOnConfigure(disable) {	
	// Disable all inputs
	j$('.aptListButton').removeAttr("onClick");
	j$('.aptListButton').attr("disabled",disable); 
	j$(':text').attr("disabled",disable); 
	j$('select').attr("disabled",disable); 
	j$('.aptListButton').removeClass("aptButtonDisabled");
	if(disable) {
		j$('.aptListButton').addClass("aptButtonDisabled");
	}

}

//Implements the view cart function
function invokeDoViewCart (){
	sfdcInvokeDoViewCart();

}

/**
 * Reset search 
 */
function resetSearch() {
	// if(j$('.search-query').val() == '') {
	// 	return;
	// }
		
	// wipe search text
	j$('.apt-search-query').val(''); 
	// hide clear search text
	j$('#idClearSearchText').hide();	
	// Reset display categories
	j$.APTTUS.nav.aptBreadCrumb('option', 'treeOptions.displayIds', j$.APTTUS.nav.aptBreadCrumb('option', 'displayIds'));
	// Clear search results
	j$.aptActionFunctionQueue.execute(sfdcInvokeDoClearSearchResults, null, true, j$.APTTUS.loadingProductsLabel);
}

/**
 * Handle keypress event for search input
 */
function searchInputKeyPress(event) {
	if(event.keyCode==13) {
    	//doSearch();
    	j$('.idDoSearchButton').trigger('click');
    	j$('.idDoSearchButton').focus();
		event.preventDefault();  
		return false;  	
    }

    return true;
}

/**
 * Callback which will move the search bar
 * into position on load of navigation	 
 */
function breadCrumbOnLoad( event, data ) {		
	j$.APTTUS.navInit = false;
	
}	

/**
 * Callback update the products upon 
 * selection 
 */
function breadCrumbOnSelect( event, data ) {	
	if(!j$.APTTUS.searchButtonClicked && !j$.APTTUS.navInit) {
		// If browsing through carousel or through root menu		
		if(data.userSelect && !data.selectedFromTree) {
			resetSearch();

		}
		// Get classification products. If search text filter within search results.
		j$.aptActionFunctionQueue.execute(sfdcInvokeDoGetClassificationProducts, data.selectedId, true, j$.APTTUS.loadingProductsLabel);		
	}	

	
}	

/**
 * Callback to clear search and move search bar
 * out of the way to prevent destuction, during
 * navigation "selection"	 
 */
function breadCrumbBeforeSelect( event, data) {
	
}

/**
 * Refresh/Load Navigation
 */
function refreshNav() {	
	if(!j$.APTTUS.nav) {
		j$.APTTUS.navInit = true;	// stop double loading of nav
		loadNav();			
	} else {		
		j$.APTTUS.nav.aptBreadCrumb('option', 'treeOptions.displayIds', JSON.parse(j$.APTTUS.filteredProductClassificationIds));
		j$.APTTUS.nav.aptBreadCrumb('select', j$.APTTUS.contextCategoryId);
	}
}

/**
 * Load Navigation
 */
function loadNav() {	
	j$.APTTUS.nav = 
		j$('#breadCrumbContainer').aptBreadCrumb({
				breadCrumbs: JSON.parse(j$.APTTUS.jsonTree),
				selected: (typeof j$.APTTUS.contextCategoryId !== "undefined" && j$.APTTUS.contextCategoryId.length > 0) 
						? j$.APTTUS.contextCategoryId 
						: j$.APTTUS.defaultLandingCategoryId,
				maxIconHeightAndWidthStyle: j$.APTTUS.MaxIconHeightAndWidthStyle,				
				onLoad: breadCrumbOnLoad,
				onSelection: breadCrumbOnSelect,
				beforeSelect: breadCrumbBeforeSelect,		
				browseMenuContainer:j$.APTTUS.isFixedButtonBar ? '' : '.apt-browseCatalogDropDown',
				treeContainer: '#treeContainer',
				disableRootMenu:true,
				disableTabView: true,
				carouselContainer: '#carouselContainer',
				rootMenuContainer: '', //#rootMenuContainer
				treeOptions: {	
								displayInTree: j$.APTTUS.filteredProductClassifications, 
								displayIds:JSON.parse(j$.APTTUS.filteredProductClassificationIds), // displayed in tree	
								hideRootCategory: j$.APTTUS.isHideRootCategory											
				},
				carouselOptions: { 
									maxDepth: j$.APTTUS.maximumCarouselDepth, 
									noImagePlaceHolder: j$.APTTUS.NoCategoryImageFoundURL 
				},
				rootMenuOptions: { 
									placeHolder:j$.APTTUS.rootMenuPlaceHolder, 
									maxDepth:999 
				},
				disableBreadcrumb: j$.APTTUS.isHideBreadcrumb,
				disableCarouselView: (j$.APTTUS.maximumCarouselDepth && j$.APTTUS.maximumCarouselDepth < 0),
				expandAllLabel: j$.APTTUS.expandAllLabel,
				collapseAllLabel: j$.APTTUS.collapseAllLabel,
				displayIds: JSON.parse(j$.APTTUS.filteredProductClassificationIds) //global display ids's
		});
}

/**
 *
 */	
function toggleDescription(className,element) {
  var origHeight = j$('.'+className).data('origHeight');
    var button = j$('.'+element);
    ////console.log(button);
    if (origHeight) {
       j$('.'+className).removeData('origHeight');
       j$('.'+className).animate({height: origHeight});
       button.html('Show Less');
       ////console.log('Show Less');
    } else {
        origHeight = j$('.'+className).height();
        j$('.'+className).data('origHeight', origHeight);
        j$('.'+className).animate({height: '100px'});
        button.html('Show More');
        ////console.log('Show More');
    }
    
    //$(".arrow").addClass("minimized");
}
	
/**
 * process elements after section of the page is rerendered
 * remove disabled=false elements
 */
function processRenderedElements(){
	j$(document).ready(function(){
		j$("*[disabled=\"false\"]").removeAttr("disabled");
	
	});	
	
}
	
function showShoppingCart(elem) {
	////console.log(j$('.idSelectedProductsBlock'));
	if(j$('.idSelectedProductsBlock').is(':hidden'))
	{
		j$('.idSelectedProductsBlock').show();
	    var linkOffset = j$(elem).offset();
	    var xPos = linkOffset.left;
	    var yPos = linkOffset.top+15;
    	xPos = xPos - j$('.idSelectedProductsBlock').width()/2;
	    j$('.idSelectedProductsBlock').css('position', 'absolute');
	    j$('.idSelectedProductsBlock').css('min-width', '350px');
		j$('.idSelectedProductsBlock').offset({top:yPos,left:xPos});
	}
	else if(j$('.idSelectedProductsBlock').is(':visible'))
	{
		j$('.idSelectedProductsBlock').hide();	
	}
	else
	{
		j$('.idSelectedProductsBlock').hide();		
	}
}
	
function tapClick(element) {
	if(j$.APTTUS.mobileUser=='true') {
		selected = j$(element).parent().find('input[type="checkbox"]');
		selected.trigger('click');
	}

}

function buildHierarchy(data) {
	var arry = new Array(), roots = [], children = {};

	j$.each(data, function buildClsNodes (index) {
        if (this.label) {        	            

            var clsNode = new Object();
            clsNode.type = this.nodeType;
		  	clsNode.name = this.name;
		  	clsNode.label = this.label;
		  	clsNode.parentId = this.parentId;
  			clsNode.rootId = this.rootId;
		  	clsNode.Id = this.nodeId;
		  	clsNode.lvl = this.nodeLvl;
		  	clsNode.leaf = this.leaf;
		  	clsNode.expanded = this.expanded;
		  	clsNode.focus = this.focus;
  			clsNode.productCount = this.productCount;
  			clsNode.imageUrl = this.imageUrl;
		  	arry.push(clsNode);

            // if there are sub items, call the buildClsNodes function.
            if (this.childList && this.childList.length > 0) {                
                buildClsNodes(this.childList);
            }
        }
    });

	// find the top level nodes and hash the children based on parent
	for (var i = 0, len = arry.length; i < len; ++i) {
	    var item = arry[i];
	    var p = item.parentId;
	    var target = !p ? roots : (children[p] || (children[p] = []));

	    target.push({ value: item });
	}

	// function to recursively build the tree
	var findChildren = function(parent) {
	    //if (children[parent.value.Id]) {
	        parent.children = children[parent.value.Id];
	        parent.data = {};
	        parent.data.title = parent.value.label;
	        parent.data.icon = parent.value.imageUrl;
	        hasImage = false;
        	if(parent.value.imageUrl != ""){
        		hasImage = true;
        	}
	        parent.attr = {"Id" : parent.value.Id,
	        			 	"hasImage" : hasImage,
	        			 	"Type" : parent.value.type, 
	        			 	"Leaf" : parent.value.leaf, 
	        			 	"rootId" : parent.value.rootId, 
	        			 	"nodeLvl" : parent.value.lvl,
	        			 	"objId" : parent.value.Id};
	        if (children[parent.value.Id]) {
		        for (var i = 0, len = parent.children.length; i < len; ++i) {
		        	parent.children[i].data = {};
		        	if(i < parent.children.length - 1){
		        		//parent.children[i].data += "<img class='move-down' src='/img/arrow_dwn.gif' alt='"+parent.children[i].value.Id+"' />";
		        	}
		        	if(i > 0){
		        		//parent.children[i].data += "<img class='move-up' src='/img/arrow_up.gif' alt='"+parent.children[i].value.Id+"' />";
		        	}
		        	parent.children[i].data.title = parent.children[i].value.label;
		        	hasImage = false
		        	if(parent.children[i].value.imageUrl != ""){
		        		hasImage = true;
		        	}
		        	parent.children[i].data.icon = parent.children[i].value.imageUrl;
		        	parent.children[i].attr = {"Id" : parent.children[i].value.Id, 
		        								"Leaf" : parent.children[i].value.leaf, 
		        								"hasImage" : hasImage, 
		        								"Type" : parent.children[i].value.type,
		        								"rootId" : parent.value.rootId,
		        								"nodeLvl" : parent.value.lvl,
		        								"objId" : parent.value.Id};
		            findChildren(parent.children[i]);
		        }
	        }
	    //}
	};

	// enumerate through to handle the case where there are multiple roots
	for (var i = 0, len = roots.length; i < len; ++i) {
	    findChildren(roots[i]);
	}

	//console.log(roots);
	return roots;
}	
		


var YAHOO = { force :{ com :{ choicePanel:{ hide:function(){}, show:function(){} } } }};
var aptLoadingPageHeader = j$.APTTUS.loadingPageLabel;
var aptRuleAlertHeader = j$.APTTUS.constraintRuleAlertLabel;
var aptDialogBody = '<center><img src="'+j$.APTTUS.ImageLoadingPageURL+'" /></center>';

/**
 * override lib functions pointing to yahoo lib
 */ 	
function onActionClick2(){
	
}
	
/**
 * override lib functions pointing to yahoo lib
 */ 	
function onActionComplete2(){
	
}
	
// array contains function
Array.prototype.contains = function (element) {
	for (var i = 0; i < this.length; i++) {
		if (this[i] == element) {
			return true;
			
		}
		
	}
	
	return false;
	
}

// array of line numbers already priced by the previous pricing call
var alreadyPriced = new Array();

/**
 * Initializes the call to webservices api
 */
function initCall() {
	try {
    	sforce.connection.sessionId = j$.APTTUS.sessionID; //to avoid session timeout
                
    } catch(ex) {
    	cp_erroralert(cp_cERROR_UNKNOWN,ex);
                
	}
}

/**
 * Reprices the given line item
 */
function doCheckAndRepriceLineItems() {
    
    // hide the wait dialog
    onActionComplete2();
    
    // check if deferred pricing is off
    var deferPricing = j$.APTTUS.deferPricingUntilCart;
	
    if (deferPricing.toLowerCase() == 'true') {
        // defer pricing to cart. abort
        return;
        
    }
	
    // get parameters
    // current configuration id
    var configId = j$.APTTUS.configurationId;
	
	// STEP I - get line numbers to pricel
    Visualforce.remoting.Manager.invokeAction(j$.APTTUS.RemoteController.getLineNumbersAwaitingPrice, configId, function(result, event) {
    
        try {
        	//alert('getLineNumbersAwaitingPrice result = ' + result);
            // check response status
            if (event.status) {
                // ok response, reprice
                var numItems = (result.length ? result.length : 0);
				//alert('getLineNumbersAwaitingPrice result = ' + result + '/' + numItems);
				
				// STEP II - Reprice each summary line item
				if (numItems > 0) {
					// initialize the call
					initCall();
					// compute base price
					for (var i = 0; i < numItems; i++) {
						var lineNbr = result[i];
						//var lineNbr = (numItems > 0 ? result[i] : result);
						// skip if already priced
						if (alreadyPriced.contains(lineNbr)) {
							//alert('alreadyPriced=' + lineNbr);
							continue;
							
						}
						
						//alert('computeBasePriceForItemColl=' + lineNbr);
						computeBasePriceForItemColl(configId, lineNbr);
						// add to already priced
						alreadyPriced.push(lineNbr);
						
					}
					
				}
				
            } 
        } catch(ex) {
            // display the error
            cp_erroralert(cp_cERROR_UNKNOWN, ex);
            // reload the page
            //doReload();
              
        } 
        
    }, {buffer:false, escape:true});
                
}

/**
 * Reprices the pending line items
 */
function doRepricePendingLineItems() {
  	
  	// get parameters
	// current configuration id
	var configId = j$.APTTUS.configurationId;

	try {
		
		// STEP I - initialize the call
		initCall();
	
		// STEP II - compute price
		computePriceForCart(configId);
		
	} catch(ex) {
		// display the error
		cp_erroralert(cp_cERROR_UNKNOWN, ex);
		
	} 
	
}

/**
 * Get product information and display in popup panel
 * using JavaScript remoting
 */
function getRemoteProductDetail(productId){
	getProductDetail(productId);
}

/**
 * Get product information and display in popup panel
 * using JavaScript remoting
 * @param removeFunction name of the remote function with complete namespace
 * @param productId id of the product 
 */
function getProductDetail2(remoteFunction, productId){
	document.getElementById('ctxProductName').innerHTML = aptLoadingPageHeader;
    document.getElementById('ctxProductDescription').innerHTML = '';
        
	Visualforce.remoting.Manager.invokeAction(remoteFunction, productId, function(result, event){
		    if (event.status) {
		        document.getElementById('ctxProductName').innerHTML = result.Name;
		        if(result.Description != undefined){
		        	document.getElementById('ctxProductDescription').innerHTML = result.Description;
				}
			} else {
		    	document.getElementById('ctxProductDescription').innerHTML = event.message;
			}
       	}, {buffer:false, escape:true});
	
	showProductDetailPanel();
}

/**
 * Get mouseover product information
 */
function getProductDetail(productId) {
    document.getElementById('ctxProductDescription').innerHTML = '';        
	Visualforce.remoting.Manager.invokeAction(j$.APTTUS.RemoteController.getProductDescription, productId, function(result, event){
		    if (event.status) {
		    	j$('.productDetailPanel .ui-dialog-title').html(result.Name);
		        if(result.Description != undefined){
		        	document.getElementById('ctxProductDescription').innerHTML = result.Description;
				} else {
					document.getElementById('ctxProductDescription').innerHTML = '';
				}
			} else {
		    	document.getElementById('ctxProductDescription').innerHTML = event.message;
			}
       	}, {buffer:false, escape:true});
	
	showProductDetailPanel();
    
}
/**
 * Callback when mouseover product information icon
 */
function showProductDetailPanel() {
	j$.APTTUS.productDetailDialog =  j$( "#productDetailPanel" ).dialog({
    	modal:true,
    	title:j$.APTTUS.LoadingPageLabel,
    	maxWidth:1000,
    	minWidth:500,
    	minHeight:110,
    	autoOpen:true,
    	dialogClass:'productDetailPanel',
    	height:"auto",
    	open : function(){
 			j$('.productDetailPanel .ui-widget-header').css({border:"none",background:"none",borderBottom:"1px solid #aaaaaa"});
 			j$('.productDetailPanel .ui-widget-header').removeClass("ui-corner-all");
 			
 		}
    });
    
}  

var classificationId;// = "{!classificationId}";
	        				 