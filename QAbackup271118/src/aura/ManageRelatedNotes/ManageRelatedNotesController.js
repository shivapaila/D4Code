({    
    doInit: function(component, event, helper) {
        var recId = component.get("v.parentId");
        if (recId) {
            helper.loadNotes(component, recId);
        }
    }, 
    createNote : function(component, event, helper) {
		helper.clearMsg(component);
        var title = component.get("v.newTitle");
        var body = helper.htmlEncode(component.get("v.newNote"));
        var recId = component.get("v.parentId");
        if ($A.util.isUndefined(title) || $A.util.isUndefined(body) ||
           	$A.util.isEmpty(title) || $A.util.isEmpty(body)) 
        {
            helper.showToast("error", 'Note Error', component,
                             'Please complete the note fields.');
        	return;
        }
        
        var toastErrorHandler = component.find('toastErrorHandler');
        
        var action = component.get("c.addNote");
        
        var editNoteId = component.get("v.editNoteId");
        var noteIndex = component.get("v.editIndex");
        
        var noteObj = {id: editNoteId, title: title, body: body};
        var noteStr = JSON.stringify(noteObj); 
        action.setParams({ "parentId" : recId,"noteObjStr" : noteStr });

        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, 
                function(response){ // report success and update notes list
                    helper.showToast("success", 'Note Added', component,
                                     'New note has been saved.');
			        var notes = component.get("v.notes");
                    if (editNoteId) {
                        notes[noteIndex] = noteObj;
                    } else {
                        noteObj.id = response.getReturnValue()
                        notes.push(noteObj);
                    }
                    helper.clearFields(component);
                    component.set("v.notes", notes);
                }, 
                function(response, message){ // report failure
                    helper.showToast("error", 'Add Note Error', component, message);
                }
            )
        });
        $A.enqueueAction(action);
	}, 
    removeDeletedNote : function(component, event, helper) {
        var index = event.getParam("indexVar");
        var noteId = event.getParam("noteId");

        helper.deleteNote(component, helper, index, noteId);
    }, 
    showEditNote : function(component, event, helper) {
        component.set("v.editIndex", event.getParam("indexVar"));
        component.set("v.editNoteId", event.getParam("noteId"));
        component.set("v.newTitle", event.getParam("title"));
        component.set("v.newNote", helper.htmlDecode(event.getParam("body")));
        component.set("v.noteButtonMsg", 'Update Note');
        component.set("v.noteFormMsg", 'Edit note');
    }, 
    clearFields : function(component, event, helper) {
        helper.clearFields(component);
    }
})