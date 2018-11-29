/* *******************************************************************************************************************
* Class Name   : Manage_AppointmentsAndTasksWrapper
* Description  : Wrapper class for Manage_AppointmentsAndTasksController Apex Class.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/05/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class Manage_AppointmentsAndTasksWrapper {
    @AuraEnabled
    public Event eventObj;
    @AuraEnabled
    public Task taskObj;
    @AuraEnabled
    public Boolean notesAvailable =false;
    @AuraEnabled
    public Boolean isEdit =false;
    @AuraEnabled
    public DateTime eventstartDate;
    @AuraEnabled
    public DateTime eventendDate;
    @AuraEnabled
    public String eventSub;
    @AuraEnabled
    public String eventWhatName;
    @AuraEnabled
    Public String eventWhatId;
    @AuraEnabled
    Public String eventId;
    
    @AuraEnabled
    Public Boolean allDayEvent;
    
    public Manage_AppointmentsAndTasksWrapper(Event e,Task t,Boolean notebool,Boolean editBool)
    {
        //this.eventObj=e;
        this.taskObj=t;
        this.notesAvailable=notebool;
        this.isEdit=editBool;
        if(e != null){
            this.eventId=e.Id;
            this.eventSub=e.Subject;
            this.eventWhatName=e.what.Name;
            this.eventstartDate=e.StartDateTime;
            this.eventendDate=e.EndDateTime;
            this.eventWhatId=e.WhatId;
            this.allDayEvent=e.IsAllDayEvent;
        }
    }
    
}