({
    // populate any default valules
    defaultValues : function(component){
        component.set("v.uiIsReminderSet", true);
    },

    // formats, validates and create task
    addTask : function(component) {
        var taskJson = component.get("v.newTask");
        this.formatRecord(component.get("v.newTask"));
        this.setDateFields(component);
        this.populateRecurrenceFields(component);

        if(this.validateTask(component, taskJson)){
            var action = component.get("c.createTask");
            action.setParams({
                taskRecord : component.get("v.newTask")
            });

            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    console.log(a.getReturnValue());
                    if(a.getReturnValue().resultCode == '200'){
                        /*var evt  = $A.get("e.force:navigateToURL");
                        evt.setParams({
                            "url": '/one/one.app#/n/TaskDetailView?recordId=' + a.getReturnValue().recordId
                            //'url' : '/lightning/r/Task/' + a.getReturnValue().recordId + '/view'
                        })
                        evt.fire();*/
                        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                        appEvent.setParams({
                            "targetCmpName" : 'TaskDetailViewWrapperCmp',
                            "targetCmpParameters" : {"recordId": a.getReturnValue().recordId}
                                           });
                        appEvent.fire();
                    }
                    if(a.getReturnValue().resultCode == '400'){
                        this.throwErrorMsg(component, "Review the errors on this page.", a.getReturnValue().resultMsg);
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
    validateTask : function(component, taskJson) {
        console.log("validating: ");
        var taskJson = component.get("v.newTask");
        var errorMsg = 'These required fields must be completed: ';
        var isError = false;
        if(taskJson.Subject == null || taskJson.Subject == ''){
            errorMsg += (isError ? ', Subject' : 'Subject');
            isError = true;
        }
        /*
        if(taskJson.OwnerId == null || taskJson.OwnerId == ''){
            errorMsg += (isError ? ', Assign To' : 'Assign To');
            isError = true;
        }
        */
        
        if(taskJson.Type == null || taskJson.Type == ''){
            errorMsg += (isError ? ', Type' : 'Type');
            isError = true;
        }
        
        if(taskJson.Priority == null || taskJson.Priority == ''){
            errorMsg += (isError ? ', Priority' : 'Priority');
            isError = true;
        }
        if(taskJson.Status == null || taskJson.Status == ''){
            errorMsg += (isError ? ', Status' : 'Status');
            isError = true;
        }

        if(taskJson.IsRecurrence && (taskJson.RecurrenceStartDateOnly == null || taskJson.RecurrenceStartDateOnly == '')){
            errorMsg += (isError ? ', Recurrence Start Date' : 'Recurrence Start Date');
            isError = true;
        }

        if(taskJson.IsRecurrence && (taskJson.RecurrenceEndDateOnly == null || taskJson.RecurrenceEndDateOnly == '')){
            errorMsg += (isError ? ', Recurrence End Date' : 'Recurrence End Date');
            isError = true;
        }

        if(isError){
            this.throwErrorMsg(component, "Review the errors on this page.", errorMsg);
            if(component.get("v.newTask.RecurrenceType") == 'RecursMonthlyNth')
                component.set("v.newTask.RecurrenceType", "RecursMonthly");
            if(component.get("v.newTask.RecurrenceType") == 'RecursYearlyNth')
                component.set("v.newTask.RecurrenceType", "RecursYearly");
            return false;
        }
        else {
            this.removeError(component);
            return true;
        }
    },

    // set Reminder Date/DateTime 
    setDateFields : function(component) {
        var taskJson = component.get("v.newTask");
        if(component.get("v.uiIsReminderSet")){
            taskJson.ReminderDateTime = component.get("v.uiReminderDateTime");
            taskJson.IsReminderSet = true;
        }
        else {
            taskJson.ReminderDateTime = null;
            taskJson.IsReminderSet = false;
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
    },

    // loads few Recurrence Date related fields
    loadInterval: function (component, event, helper) {
        var opts = [];
        for(var i=1; i<=30; i++){
            opts.push({value: i.toString(), label: i.toString()});
        }
        component.set("v.uiRecurrenceIntervalOptions", opts);

        var optsWeek =[];
        optsWeek.push({label: "Su", value : 1});
        optsWeek.push({label: "M", value : 2});
        optsWeek.push({label: "Tu", value : 4});
        optsWeek.push({label: "W", value : 8});
        optsWeek.push({label: "Th", value : 16});
        optsWeek.push({label: "F", value : 32});
        optsWeek.push({label: "Sa", value : 64});
        component.set("v.uiRecurrenceIntervalOptionsWeek", optsWeek);
    },

    // populates the Recurrence related fields as per SFDC out of the box logic
    populateRecurrenceFields : function(component){
        var months = [
                        'January', 'February', 'March', 'April', 'May',
                        'June', 'July', 'August', 'September',
                        'October', 'November', 'December'
                        ];

        if(component.get("v.newTask.IsRecurrence")){
            if(component.get("v.newTask.RecurrenceType") == 'RecursDaily'){
                if(component.get("v.uiRecurrenceInterval") == 'Every Day'){
                    component.set("v.newTask.RecurrenceInterval", 1);
                }
                else if(component.get("v.uiRecurrenceInterval") == 'Every Other Day'){
                    component.set("v.newTask.RecurrenceInterval", 2);
                }
            }

            else if(component.get("v.newTask.RecurrenceType") == 'RecursWeekly'){
                var selectedVals = component.get("v.uiRecurrenceIntervalWeekValues");
                var totalVal = 0;
                for(var i=0; i<selectedVals.length; i++){
                    totalVal += parseInt(selectedVals[i]);
                }
                console.log(totalVal);
                component.set("v.newTask.RecurrenceDayOfWeekMask", totalVal);

                if(component.get("v.uiRecurrenceIntervalWeek") == 'Every Week'){
                    component.set("v.newTask.RecurrenceInterval", 1);
                }
                else if(component.get("v.uiRecurrenceIntervalWeek") == 'Every Other Week'){
                    component.set("v.newTask.RecurrenceInterval", 2);
                }
            }

            else if(component.get("v.newTask.RecurrenceType") == 'RecursMonthly'){
                if(component.get("v.uiRecurrenceIntervalMonth") == 'Every Month'){
                    component.set("v.newTask.RecurrenceInterval", 1);
                }
                else if(component.get("v.uiRecurrenceIntervalMonth") == 'Every Other Month'){
                    component.set("v.newTask.RecurrenceInterval", 2);
                }

                if(component.get("v.uiRecurrenceWhenMonth") == 'Relative Days'){
                    component.set("v.newTask.RecurrenceType", "RecursMonthlyNth");
                    component.set("v.newTask.RecurrenceDayOfMonth", "");
                }
                else{
                    component.set("v.newTask.RecurrenceDayOfWeekMask", "");
                }
            }

            else if(component.get("v.newTask.RecurrenceType") == 'RecursYearly'){
                if(component.get("v.uiRecurrenceWhenYear") == 'Relative Date'){
                    component.set("v.newTask.RecurrenceType", "RecursYearlyNth");
                    component.set("v.newTask.RecurrenceDayOfMonth", "");
                }
                else{
                    component.set("v.newTask.RecurrenceInstance", "");
                    component.set("v.newTask.RecurrenceDayOfWeekMask", "");
                    var sDate = component.get("v.newTask.RecurrenceStartDateOnly");
                    if(sDate != null){
                        var sDateStr = sDate.split("-");
                        component.set("v.newTask.RecurrenceMonthOfYear", months[parseInt(sDateStr[1]) - 1]);
                        component.set("v.newTask.RecurrenceDayOfMonth", sDateStr[2]);
                    }
                }
            }
            component.set("v.newTask.ActivityDate", "");
        }
    }
})