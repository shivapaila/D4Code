({
    handleEditNote : function(component, event, helper) {
        var edEvt = component.getEvent("editNoteEvent");
        edEvt.setParams({ 
            "indexVar" : component.get("v.rowIndex"),
            "noteId" : component.get("v.note.id"), 
            "title" : component.get("v.note.title"), 
            "body" : component.get("v.note.body"),
        });
        edEvt.fire();
    },
    handleRemoveNote : function(component, event, helper) {
        var delEvt = component.getEvent("deleteNoteEvent");
        delEvt.setParams({ "indexVar" : component.get("v.rowIndex"), 
                           "noteId" : component.get("v.note.id")});
        delEvt.fire();
    }
})