({
    loadNotes : function(cmp, id) {
        // Load all associated notes
        var action = cmp.get("c.getRelatedNotes");
        action.setParams({ "parentId"  : id });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.notes", response.getReturnValue());
            }

            // Display toast message to indicate load status
            if (state !== 'SUCCESS'){
    	        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                        "title": "Error!",
                        "message": " Something has gone wrong."
                });
	            toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(type, title, component, message) {
        var inConsole = component.get("v.inSvcConsole");
        if (!inConsole) { // if we're in lightning message this way
	        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: type,
                // note - leaving mode field for reference 
                //mode: 'dismissible',
                title: title, 
                message: message,
            });
            toastEvent.fire();
        } else {
            component.set("v.messageType", type);
            component.set("v.message", message);
        }
    }, 
    deleteNote : function(component, helper, index, noteId) {
	    var toastErrorHandler = component.find('toastErrorHandler');
        
        var action = component.get("c.deleteNote");

        action.setParams({ "noteId" : noteId });
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, 
                function(response){ // report success 
                    helper.showToast("success", 'Note Deleted', component,
                                     'The note has been deleted.');
                    // update notes list minus the deleted note
			        var notes = component.get("v.notes");
                    notes.splice(index, 1);
                    component.set("v.notes", notes);
                }, 
                function(response, message){ // report failure
                    helper.showToast("error", 'Delete Note Error', component, message);
                }
            )
        });
        $A.enqueueAction(action);
	}, 
    clearFields : function(component) {
        component.set("v.newTitle", null);
        component.set("v.newNote", null);
        component.set("v.editIndex", null);
        component.set("v.editNoteId", null);     
        component.set("v.noteButtonMsg", component.get("v.noteButtonMsgDefault"));     
        component.set("v.noteFormMsg", component.get("v.noteFormMsgDefault"));     
    },
    clearMsg : function(component) {
        component.set("v.messageType", '');
        component.set("v.message", '');
    },
    htmlEncode : function(value){
        return $('<div/>').text(value).html();
    },
    htmlDecode : function(value){
        return $('<div/>').html(value).text();
    },    
})