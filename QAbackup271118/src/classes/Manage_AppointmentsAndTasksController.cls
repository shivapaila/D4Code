/* *******************************************************************************************************************
* Class Name   : Manage_AppointmentsAndTasksController
* Description  : Controller class for ManageTasks and ManageAppointments component.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/05/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class Manage_AppointmentsAndTasksController {
    
    @AuraEnabled
    public List<Manage_AppointmentsAndTasksWrapper> wrapperLst ;
    @AuraEnabled
    public List<String> statusLst ;
    @AuraEnabled
    public List<String> typeLst ;
    @AuraEnabled
    public List<Task> taskLst ;
    @AuraEnabled
    public List<Event> eventLst;
    
    //Loading all todays Tasks
    @AuraEnabled
    public static Manage_AppointmentsAndTasksController getTodaysTasks(){
        Set<Id> todaysTaskIds = new Set<Id>();
        List<Task> taskLst=new List<Task>();
        Manage_AppointmentsAndTasksController ctrl =new Manage_AppointmentsAndTasksController();
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        for(Task todaysTask :[Select Id,subject,status,type,owner.name,ActivityDate 
                              From task 
                              Where ownerId =:UserInfo.getUserId() ANd status='Open' And ActivityDate =:System.today()])
        {
            taskLst.add(todaysTask);
            todaysTaskIds.add(todaysTask.Id);
            
        }
        
        //Loading Picklist Values
        getPickList(ctrl);
        
        Map<String,ContentDocumentLink> notesMap= new Map<String,ContentDocumentLink>();
        if (todaysTaskIds.size() > 0) {
            for(ContentDocumentLink t: [SELECT ContentDocumentId,LinkedEntityId 
                                        FROM ContentDocumentLink 
                                        WHERE LinkedEntityId IN: todaysTaskIds ])
            {
                notesMap.put(t.LinkedEntityId, t);
                
            }
        }
        
        //dispaying the notes icon
        for(Task tsk : taskLst)
        {
            if(notesMap.get(tsk.Id) != null)
            {
                Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(null,tsk,true,false);
                ctrl.wrapperLst.add(wrapper); 
            }
            else
            {
                Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(null,tsk,false,false);
                ctrl.wrapperLst.add(wrapper);
            }
        }
        
        return ctrl;
    } 
    
    //Getting the Picklist Values
    public static void getPickList(Manage_AppointmentsAndTasksController ctrl)
    {
        Schema.DescribeFieldResult statusFieldResult = Task.status.getdescribe();
        List<Schema.PicklistEntry> statusPicklistVal = statusFieldResult.getPicklistValues();
        ctrl.statusLst=new List<String>();
        for(Schema.PicklistEntry p : statusPicklistVal)
        {
            if(p.isActive() == true)
            {
                ctrl.statusLst.add(p.getLabel());
            }
            
        }
        Schema.DescribeFieldResult typeFieldResult = Task.type.getdescribe();
        List<Schema.PicklistEntry> typePicklistVal = typeFieldResult.getPicklistValues();
        ctrl.typeLst=new List<String>();
        for(Schema.PicklistEntry p : typePicklistVal)
        {
            if(p.isActive() == true)
            {
                ctrl.typeLst.add(p.getLabel());
            }
            
        }
    }
    
    //Updating the Tasks
    @AuraEnabled
    public static void updateTask(String Id,String sub,String duedate,String type)
    {


        List<Task> tskLst=[Select Id,Subject,Status,Type 
                           From Task 
                           Where Id =:Id];
        if(!tskLst.isEmpty()){
            Task tsk=tskLst[0];
            tsk.Subject=sub;
            if(!String.isEmpty(dueDate)) {
            	tsk.ActivityDate = Date.valueOf(duedate);    
            }

            tsk.Type=type;
            try{
                update tsk;
            }
            catch(Exception ex){     
                System.debug('Failed to save:'+ex.getMessage());                

            }
        }


    }
    
    //Loading All Open Task Owned By LoggedIn User
    @AuraEnabled
    public static Manage_AppointmentsAndTasksController getAllOpenTasks(){
        Manage_AppointmentsAndTasksController ctrl =new Manage_AppointmentsAndTasksController();
        getPickList(ctrl);
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        List<Task> allTaskLst=[Select Id,subject,status,type,ActivityDate 
                               From task 
                               Where ownerId =:UserInfo.getUserId() and status= 'Open' ORDER BY ActivityDate ASC ];
        if(!allTaskLst.isEmpty()){
            for(Task tsk : allTaskLst)
            {
                Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(null,tsk,false,false);
                ctrl.wrapperLst.add(wrapper); 
            }
            return ctrl;  
        }
        else{
            return null;  
        }
        
    }
    
    //Loading All completed Task Owned By LoggedIn User
    @AuraEnabled
    public static Manage_AppointmentsAndTasksController getAllCompletedTasks(){
        Manage_AppointmentsAndTasksController ctrl =new Manage_AppointmentsAndTasksController();
        getPickList(ctrl);
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        List<Task> allTaskLst=[Select Id,subject,status,type,ActivityDate 
                               From task 
                               Where ownerId =:UserInfo.getUserId() and (status = 'Complete' OR status = 'Completed') ORDER BY ActivityDate ASC ];
        if(!allTaskLst.isEmpty()){
            for(Task tsk : allTaskLst)
            {
                Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(null,tsk,false,false);
                ctrl.wrapperLst.add(wrapper); 
            }
            return ctrl;  
        }
        else{
            return null;  
        }
        
    }
    
    //Loading Today's Events(Appointments)
    @AuraEnabled
    public static Manage_AppointmentsAndTasksController getTodaysEvents(){
        List<Event> evt=new List<Event>();
        Set<Id> todaysEventIds = new Set<Id>();
        Manage_AppointmentsAndTasksController ctrl =new Manage_AppointmentsAndTasksController();
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        
        DateTime today=DateTime.now();
        
        Date myDate = Date.newInstance(today.year(),today.month(),today.day());
        Time myTime = Time.newInstance(0, 0, 0, 0);
        DateTime startTimeGMT = DateTime.newInstanceGmt(myDate, myTime);
        DateTime startTime = DateTime.newInstance(myDate, myTime);
        Time myEndTime = Time.newInstance(23, 30, 0, 0);
        DateTime endTimeGMT = DateTime.newInstanceGmt(myDate, myEndTime);
        DateTime endTime = DateTime.newInstance(myDate, myEndTime);
        
        String UserId=UserInfo.getUserId();
        String query='Select Id,subject,what.name,StartDateTime,EndDateTime,IsAllDayEvent ' + 
            		 'from Event where ((EndDateTime >= :startTime and EndDateTime <= :endTime and IsAllDayEvent != true) or (EndDateTime >= :startTimeGMT and EndDateTime <= :endTimeGMT and IsAllDayEvent = true)) and OwnerId= :UserId '+ 
            		 'Order by StartDateTime';
        
        
        for(Event todaysEvent : Database.query(query)){
            
            evt.add(todaysEvent);
            todaysEventIds.add(todaysEvent.Id);
        }
        
        Map<String,ContentDocumentLink> notesMap= new Map<String,ContentDocumentLink>();
        if (todaysEventIds.size() > 0) {
            for(ContentDocumentLink t: [SELECT ContentDocumentId,LinkedEntityId 
                                        FROM ContentDocumentLink 
                                        WHERE LinkedEntityId IN: todaysEventIds ])
            {
                notesMap.put(t.LinkedEntityId, t);
                
            }
        }
        
        //dispaying the notes icon
        for(Event ev : evt)
        {
            Task t=new Task();
            if(notesMap.get(ev.Id) != null)
            {
                Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(ev,t,true,false);
                ctrl.wrapperLst.add(wrapper); 
            }
            else
            {
                Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(ev,t,false,false);
                ctrl.wrapperLst.add(wrapper);
            }
        }
        String str = JSON.serialize(ctrl.wrapperLst);
        List<Manage_AppointmentsAndTasksWrapper> wrp = (List<Manage_AppointmentsAndTasksWrapper>) JSON.deserialize(str, List<Manage_AppointmentsAndTasksWrapper>.class);
        
        return ctrl;
        
    }
    
    //Updating Events(Appointments)
    @AuraEnabled
    public static void updateEvent(String wrapper, Integer index)
    {
        
        List<Manage_AppointmentsAndTasksWrapper> wrp = (List<Manage_AppointmentsAndTasksWrapper>) JSON.deserialize(wrapper, List<Manage_AppointmentsAndTasksWrapper>.class);
        
        if((wrp != null) && (wrp[index] != null)){
            Manage_AppointmentsAndTasksWrapper obj=wrp[index];
            
            List<Event> evtLst=[Select Id,subject,what.name,StartDateTime,EndDateTime 
                                from Event 
                                where Id =:obj.eventId];
            if(!evtLst.isEmpty()){
                Event evt=evtLst[0];
                evt.Subject=obj.eventSub;
                evt.StartDateTime=obj.eventstartDate;
                evt.EndDateTime=obj.eventendDate;
                try{
                    update evt;  
                }
                catch(Exception ex){     
                    System.debug('Failed to save:'+ex.getMessage());         
                    
                }
                
            }
        }
        
        
    }
    
    //Loading All Events(Appointments) Owned by LoggedIn User
    @AuraEnabled
    public static Manage_AppointmentsAndTasksController getAllUpcomingEvents(){
        List<Event> evt=new List<Event>();
        Set<Id> todaysEventIds = new Set<Id>();
        Manage_AppointmentsAndTasksController ctrl =new Manage_AppointmentsAndTasksController();
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        String UserId=UserInfo.getUserId();
        
        DateTime today=DateTime.now();
        
        Date myDate = Date.newInstance(today.year(),today.month(),today.day());
        Time myTime = Time.newInstance(0, 0, 0, 0);
        DateTime startTime = DateTime.newInstance(myDate, myTime);
        DateTime startTimeGMT = DateTime.newInstanceGMT(myDate, myTime);
        
        String query='Select Id,subject,what.name,StartDateTime,EndDateTime,IsAllDayEvent '+
            		 'from Event '+
            		 'where OwnerId= :UserId And ((StartDateTime >= :startTime and IsAllDayEvent != true) or (StartDateTime >= :startTimeGMT and IsAllDayEvent = true))  Order By StartDateTime ASC';
        
        
        for(Event allEvent : Database.query(query))
        {
            
            evt.add(allEvent);
        }
        for(Event ev : evt)
        {
            Task t=new Task();
            
            Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(ev,t,false,false);
            ctrl.wrapperLst.add(wrapper);
            
        }
        return ctrl;
        
    }
    
    @AuraEnabled
    public static Manage_AppointmentsAndTasksController getAllPastEvents(){
        List<Event> evt=new List<Event>();
        Set<Id> todaysEventIds = new Set<Id>();
        Manage_AppointmentsAndTasksController ctrl =new Manage_AppointmentsAndTasksController();
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        String UserId=UserInfo.getUserId();
        
        DateTime today=DateTime.now();
        
        Date myDate = Date.newInstance(today.year(),today.month(),today.day());
        Time myTime = Time.newInstance(0, 0, 0, 0);
        DateTime startTime = DateTime.newInstance(myDate, myTime);
        DateTime startTimeGMT = DateTime.newInstanceGMT(myDate, myTime);
        
        String query='Select Id,subject,what.name,StartDateTime,EndDateTime,IsAllDayEvent '+
            		 'from Event '+
            		 'where OwnerId= :UserId And ((StartDateTime < :startTime and IsAllDayEvent != true) or (StartDateTime < :startTimeGMT and IsAllDayEvent = true))  Order By StartDateTime ASC';
        
        
        for(Event allEvent : Database.query(query))
        {
            
            evt.add(allEvent);
        }
        for(Event ev : evt)
        {
            Task t=new Task();
            
            Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(ev,t,false,false);
            ctrl.wrapperLst.add(wrapper);
            
        }
        return ctrl;
        
    }
    
    @AuraEnabled
    public static void deleteTask(String Id){
        
        List<Task> taskToBeDeleted =[Select id,subject 
                                    From Task
                                    Where id=:Id];
        if(!taskToBeDeleted.isEmpty()){
            delete taskToBeDeleted;
        }
    }
    
    @AuraEnabled
    public static void statusComplete(String Id){
        
        List<Task> taskToBeUpdated =[Select id,subject,status
                                    From Task
                                    Where id=:Id];
        if(!taskToBeUpdated.isEmpty()){
            taskToBeUpdated[0].Status='Complete';
            update taskToBeUpdated;
            system.debug('taskToBeUpdated-->'+taskToBeUpdated);
        }
    }
    
    @AuraEnabled
    public static Manage_AppointmentsAndTasksController filter(DateTime filterDate){
        List<Event> evt=new List<Event>();
        Set<Id> todaysEventIds = new Set<Id>();
        Manage_AppointmentsAndTasksController ctrl =new Manage_AppointmentsAndTasksController();
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        String UserId=UserInfo.getUserId();
        if(filterDate >= System.today()){
            
        
        Date myDate = Date.newInstance(filterDate.year(),filterDate.month(),filterDate.day());
        Time myTime = Time.newInstance(0, 0, 0, 0);
        DateTime startTime = DateTime.newInstance(myDate+1, myTime);
        DateTime startTimeGMT = DateTime.newInstanceGMT(myDate+1, myTime);
        
        Time myEndTime = Time.newInstance(23, 30, 0, 0);
        DateTime endTime = DateTime.newInstance(myDate+1, myEndTime);
         DateTime endTimeGMT = DateTime.newInstanceGMT(myDate+1, myEndTime);
        
        String query='Select Id,subject,what.name,StartDateTime,EndDateTime,IsAllDayEvent ' + 
            		 'from Event where ((StartDateTime >= :startTime and StartDateTime <= :endTime and IsAllDayEvent != true)or(StartDateTime >= :startTimeGMT and StartDateTime <= :endTimeGMT and IsAllDayEvent = true)) and OwnerId= :UserId '+ 
            		 'Order by StartDateTime ASC';
        
        
        for(Event allEvent : Database.query(query))
        {
            
            evt.add(allEvent);
        }
       
        for(Event ev : evt)
        {
            Task t=new Task();
            
            Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(ev,t,false,false);
            ctrl.wrapperLst.add(wrapper);
            
        }
            }
        return ctrl;
      
    }
    
    @AuraEnabled
    public static Manage_AppointmentsAndTasksController PastDatefilter(DateTime filterDate){
        List<Event> evt=new List<Event>();
        Set<Id> todaysEventIds = new Set<Id>();
        Manage_AppointmentsAndTasksController ctrl =new Manage_AppointmentsAndTasksController();
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        String UserId=UserInfo.getUserId();
        if(filterDate < System.today()){
            
        
        Date myDate = Date.newInstance(filterDate.year(),filterDate.month(),filterDate.day());
        Time myTime = Time.newInstance(0, 0, 0, 0);
        DateTime startTime = DateTime.newInstance(myDate+1, myTime);
        DateTime startTimeGMT = DateTime.newInstanceGMT(myDate+1, myTime);
        
        Time myEndTime = Time.newInstance(23, 30, 0, 0);
        DateTime endTime = DateTime.newInstance(myDate+1, myEndTime);
         DateTime endTimeGMT = DateTime.newInstanceGMT(myDate+1, myEndTime);
        
        String query='Select Id,subject,what.name,StartDateTime,EndDateTime,IsAllDayEvent ' + 
            		 'from Event where ((StartDateTime >= :startTime and StartDateTime <= :endTime and IsAllDayEvent != true)or(StartDateTime >= :startTimeGMT and StartDateTime <= :endTimeGMT and IsAllDayEvent = true)) and OwnerId= :UserId '+ 
            		 'Order by StartDateTime ASC';
        
        
        for(Event allEvent : Database.query(query))
        {
            
            evt.add(allEvent);
        }
       
        for(Event ev : evt)
        {
            Task t=new Task();
            
            Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(ev,t,false,false);
            ctrl.wrapperLst.add(wrapper);
            
        }
            }
        return ctrl;
      
    }
    
    @AuraEnabled
    public static Manage_AppointmentsAndTasksController formWrapper(List<task> tskLst){
       Manage_AppointmentsAndTasksController ctrl =new Manage_AppointmentsAndTasksController();
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        if(!tskLst.isEmpty()){
            for(Task tsk : tskLst)
            {
				String dtStr; 
                if(tsk.ActivityDate != null) {
                	dtStr= string.valueof(tsk.ActivityDate);
                	tsk.ActivityDate=date.valueof(dtStr);    
                }
                Manage_AppointmentsAndTasksWrapper  wrapper=new Manage_AppointmentsAndTasksWrapper(null,tsk,false,false);
                ctrl.wrapperLst.add(wrapper); 
            }
            return ctrl;  
        }
        else{
            return null;  
        }
    }
}