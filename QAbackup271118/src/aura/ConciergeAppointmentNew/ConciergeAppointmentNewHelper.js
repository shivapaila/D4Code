({
    // formats, validates and creates event record
    addEvent : function(component) {
        var eventJson = component.get("v.newEvent");
        this.formatRecord(component.get("v.newEvent"));
        this.setDateFields(component);

        if(this.validateEvent(component, eventJson)){
            var action = component.get("c.createEvent");
            action.setParams({
                eventRecord : component.get("v.newEvent")
            });

            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    if(a.getReturnValue().resultCode == '200'){
                        // navigation fix
                        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                        appEvent.setParams({
                            "targetCmpName" : 'AppointmentDetailViewWrapperCmp',
                            "targetCmpParameters" : {"recordId": a.getReturnValue().recordId}
                        });
                        appEvent.fire();
 						/*
                        var evt  = $A.get("e.force:navigateToURL");
                        evt.setParams({
                            //"url": '/one/one.app#/n/AppointmentDetailView?recordId=' + a.getReturnValue().recordId
                            'url' : '/lightning/n/AppointmentDetailView?recordId=' + a.getReturnValue().recordId
                        })
                        evt.fire();
                        */
                    }
                    if(a.getReturnValue().resultCode == '400'){
                        alert(a.getReturnValue().resultMsg);
                    }
                } else if (a.getState() === "ERROR") {
                    $A.log("Errors", a.getError());
                }
            });
            $A.enqueueAction(action);
        }
    },

    // have to remove the lookup record node as it's causing error while saving
    // and whoId has to be retrieved from a lengthy string - both are side effects of using force:inputField
    formatRecord : function(j){
        delete j.Owner;
        delete j.Account__r;
        delete j.What;
        delete j.Who;
        
        var str = j.WhoId;
        var subStr = "id\":\"";
        var startPosition;
        if(str != null && str.indexOf(subStr) != -1){
            startPosition = str.indexOf(subStr) + subStr.length;
            j.WhoId = str.substring(startPosition, startPosition + 18);
        }
    },
    // do required Validation
    validateEvent : function(component, eventJson) {
        var eventJson = component.get("v.newEvent");
        var errorMsg = 'These required fields must be completed: ';
        var isError = false;
        if(eventJson.Subject == null || eventJson.Subject == ''){
            errorMsg += (isError ? ', Subject' : 'Subject');
            //$A.util.toggleClass(component.find("eventSubject"), "slds-has-error");
            isError = true;
        }
        /*
        if(eventJson.OwnerId == null || eventJson.OwnerId == ''){
            errorMsg += (isError ? ', Assign To' : 'Assign To');
            isError = true;
        }*/
        if(eventJson.StartDateTime == null || eventJson.StartDateTime == ''){
            errorMsg += (isError ? ', Start' : 'Start');
            isError = true;
        }
        if(eventJson.EndDateTime == null || eventJson.EndDateTime == ''){
            errorMsg += (isError ? ', End' : 'End');
            isError = true;
        }
        /*
        if(eventJson.Type == null || eventJson.Type == ''){
            errorMsg += (isError ? ', Type' : 'Type');
            isError = true;
        }
        */
        if(eventJson.Appointment_Status__c == null || eventJson.Appointment_Status__c == ''){
            errorMsg += (isError ? ', Appointment Status' : 'Appointment Status');
            isError = true;
        }

        if(isError){
            this.throwErrorMsg(component, "Review the errors on this page.", errorMsg);
            return false;
        }
        else {
            this.removeError(component);
            return true;
        }
    },
    // set Reminder Date/DateTime 
    setDateFields : function(component) {
        var eventJson = component.get("v.newEvent");
        if(component.get("v.uiAllDayEvent")){
            eventJson.StartDateTime = component.get("v.uiStartDate");
            eventJson.EndDateTime = component.get("v.uiEndDate");
            eventJson.IsAllDayEvent = true;
        }
        else {
            eventJson.StartDateTime = component.get("v.uiStartDateTime");
            eventJson.EndDateTime = component.get("v.uiEndDateTime");
            eventJson.IsAllDayEvent = false;
        }
    },
    // adds error message
    throwErrorMsg : function(component, errorTitle, errorMsg){
        
        component.set("v.errorTitle", errorTitle);
        component.set("v.errorMsg", errorMsg);
        component.set("v.showError", true);
        //component.find("uiErrorMsg").getElement().focus();

    },
    // removes error if errors are corrected
    removeError : function(component){
        component.set("v.errorTitle", "");
        component.set("v.errorMsg", "");
        component.set("v.showError", false);
    }
})