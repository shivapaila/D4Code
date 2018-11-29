({
    Init : function(component, event, helper) {
        helper.getRecordId(component, event, helper);
      	var accRec = component.get("v.recordId");

        var action = component.get("c.createSignatureRecord");
        action.setParams({ personAccId : accRec,
                          oppId : component.get("v.oppId")});
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var obj = response.getReturnValue();     
                component.set('v.guestObj',obj.guestRecord);
                //component.set('v.guestName',obj.guestRecord.Name);
             	component.set('v.SigObjId',obj.signId);
            }else{
                
                console.log('i am in error');
            }
        });
        $A.enqueueAction(action);
		
	},
	onCheck: function(cmp, evt) {
		var promotionalEmailsCmp = cmp.find("promotionalEmails").get('v.value');
        var textMessagesCmp = cmp.find("textMessages").get('v.value');
        cmp.set('v.istextMsg',textMessagesCmp);
        var type;
        if(promotionalEmailsCmp == true || textMessagesCmp == true )
        {
            //cmp.set("v.body",[]);
            
            cmp.set('v.showSignature',true);
            //create signature component here
            /*$A.createComponent(
                "BGSIGCAP:SignatureCapture",
                {
                    "recordId": cmp.get('v.SigObjId'),
                    "startMsg":'Click the button to get started',
                    "enterMsg":'',
                    "completeMsg":'Here is the signature you entered',
                    "saveAttachment":false,
                    
                },
                function(newcomponent){
                    if (cmp.isValid()) {
                        var body = cmp.get("v.body");
                        body.push(newcomponent);
                        cmp.set("v.body", body);             
                    }
                }            
            );*/
            
        }
        else
        {
            cmp.set('v.showSignature',false);
        }
        var action = cmp.get("c.updateSignatureRecord");
        	action.setParams({ "signId" : cmp.get('v.SigObjId'),
                               "promotionalEmails":promotionalEmailsCmp,
                               "textMessages":textMessagesCmp,
                              	"personAccId" : cmp.get("v.recordId")
                             	});
        	action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var obj = response.getReturnValue();                 
                
             	cmp.set('v.SigObjId',obj);
            }else{
                
                console.log('i am in error');
            }
        });
        $A.enqueueAction(action);
		
	},
	finalizeOrder : function(cmp, event, helper) {
        var recId = cmp.get("v.recordId");
        var action = cmp.get("c.checkForSignature");
        var oppId = cmp.get("v.oppId");
        var recId = cmp.get("v.SigObjId");
        var toastErrorHandler = cmp.find('toastErrorHandler');
        if ($A.util.isEmpty(recId) || $A.util.isUndefined(recId) )
            return;
        
        action.setParams({ "sigId"  : recId });
        
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // report success and navigate to contact record
                    var attachmentFound = response.getReturnValue();
                    if (attachmentFound == true) {
                        var evt  = $A.get("e.force:navigateToURL");
                        evt.setParams({
                            "url": '/one/one.app#/n/SaleCompleted?recordId='+ recId+ '&oppId='+oppId
                        })
                        evt.fire();
                    }
                    else{
                        alert('Kindly sign to continue');
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Cart Load Error', cmp, message);
                }
            )
        });
        $A.enqueueAction(action);
        
	},
    
    decline : function(cmp, event, helper) {
        var recId = cmp.get("v.recordId");
        var oppId = cmp.get("v.oppId");
        var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": '/one/one.app#/n/SaleCompleted?recordId='+ recId+ '&oppId='+oppId
        })
        evt.fire();
    }
})