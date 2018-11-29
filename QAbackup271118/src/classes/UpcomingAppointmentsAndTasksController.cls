/* *******************************************************************************************************************
* Class Name   : UpcomingAppointmentsAndTasksController
* Description  : Controller class for UpcomingTasks and UpcomingManageAppointments component.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/27/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class UpcomingAppointmentsAndTasksController {

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
    
    //Getting the Picklist Values
    public static void getPickList(UpcomingAppointmentsAndTasksController ctrl)
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
     //Loading All Upcoming Events(Appointments) related to the current customer
    @AuraEnabled
    public static UpcomingAppointmentsAndTasksController upcomingCustomersEvents(String customerId){
     
        List<Event> evt=new List<Event>();
        Set<Id> todaysEventIds = new Set<Id>();
        UpcomingAppointmentsAndTasksController ctrl =new UpcomingAppointmentsAndTasksController();
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        String UserId=UserInfo.getUserId();
        
        DateTime today=DateTime.now();
        
        Date myDate = Date.newInstance(today.year(),today.month(),today.day());
        Time myTime = Time.newInstance(0, 0, 0, 0);
        DateTime startTime = DateTime.newInstance(myDate, myTime);
        DateTime startTimeGMT = DateTime.newInstanceGMT(myDate, myTime);
        System.debug('startTime-->'+startTime);
        String query='Select Id,subject,what.name,StartDateTime,EndDateTime,IsAllDayEvent,whatId '+
                     'from Event '+
                     'where whatId= :customerId And ((StartDateTime >= :startTime and IsAllDayEvent != true ) or(StartDateTime >= :startTimeGMT and IsAllDayEvent = true)) Order By StartDateTime ASC';
        
        system.debug('query-->'+query);
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
    public static void updateEvent(String wrapper, Integer index){
        Manage_AppointmentsAndTasksController.updateEvent(wrapper, index);
    }
    
     //Loading All Upcoming Tasks of the current customer
    @AuraEnabled
    public static UpcomingAppointmentsAndTasksController getAllUpcomingTasks(String customerId){
        UpcomingAppointmentsAndTasksController ctrl =new UpcomingAppointmentsAndTasksController();
        getPickList(ctrl);
        ctrl.wrapperLst =new List<Manage_AppointmentsAndTasksWrapper>();
        List<Task> allTaskLst=[Select Id,subject,status,type,ActivityDate,whatId
                               From task 
                               Where whatId =:customerId And ActivityDate>= :System.today() and status='Open' ORDER BY status, ActivityDate ASC ];
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
    
    @AuraEnabled
    public static void updateTask(String Id,String sub,String duedate,String type){
        Manage_AppointmentsAndTasksController.updateTask(Id, sub, duedate, type);
    }
    
    @AuraEnabled
    public static void deleteTask(String Id){
        Manage_AppointmentsAndTasksController.deleteTask(Id);
    }
    @AuraEnabled
    public static void statusComplete(String Id){
        Manage_AppointmentsAndTasksController.statusComplete(Id);
    }
}