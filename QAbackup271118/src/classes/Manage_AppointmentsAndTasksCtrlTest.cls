/* *******************************************************************************************************************
* Class Name   : Manage_AppointmentsAndTasksCtrlTest
* Description  : Test class for Manage_AppointmentsAndTasksController.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/13/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
public class Manage_AppointmentsAndTasksCtrlTest {
    
    public  List<Manage_AppointmentsAndTasksWrapper> wrapperLst;   
    @isTest
    public static void getTodaysTasksTest()
    {
        createTask();
        Manage_AppointmentsAndTasksController ctrl=Manage_AppointmentsAndTasksController.getTodaysTasks();
        if(!ctrl.wrapperLst.isEmpty())
        {
            system.assert(ctrl.wrapperLst[0].taskObj != null);
        }
        
    }
    @isTest
    public static void updateTaskTest()
    {
        Task task=createTask();
        Manage_AppointmentsAndTasksController.updateTask(task.Id, 'updated sub', '2017-12-13', 'Phone');
        task=[Select Id,Subject,type from Task where Id =:task.Id];
        system.assertEquals('updated sub', task.Subject);
    }
    
    @isTest
    public static void getAllTasksTest()
    {
        createCompleteTask();
        Manage_AppointmentsAndTasksController ctrl=Manage_AppointmentsAndTasksController.getAllCompletedTasks();
        if(!ctrl.wrapperLst.isEmpty())
        {
            system.assert(ctrl.wrapperLst[0].taskObj != null);
        }
        createTask();
        Manage_AppointmentsAndTasksController ctr=Manage_AppointmentsAndTasksController.getAllOpenTasks();
        if(!ctr.wrapperLst.isEmpty())
        {
            system.assert(ctr.wrapperLst[0].taskObj != null);
        }
    }
    @isTest
    public static void deleteTaskTest()
    {
        Task tsk=createTask();
        Manage_AppointmentsAndTasksController.deleteTask(tsk.Id);
   		List<Task> tskLst=[select Id from Task where Id=:tsk.Id];
        
            system.assert(tskLst.isEmpty());
    }
    @isTest
    public static void statusCompleteTest()
    {
        Task tsk=createTask();
        Manage_AppointmentsAndTasksController.statusComplete(tsk.Id);
   		List<Task> tskLst=[select Id,status from Task where Id=:tsk.Id];
        if(!tskLst.isEmpty()){
             system.assert(tskLst[0].Status == 'Complete');
        }
           
    }
    public static task createTask(){
        Task tsk=new Task();
        tsk.Subject='test';
        tsk.Priority='Normal';
        tsk.Status='Open';
        tsk.OwnerId=userInfo.getUserId();
        tsk.ActivityDate=system.today();
        insert tsk;
        return tsk;
    }
    
     public static task createCompleteTask(){
        Task tsk=new Task();
        tsk.Subject='test';
        tsk.Priority='Normal';
        tsk.Status='Complete';
        tsk.OwnerId=userInfo.getUserId();
        tsk.ActivityDate=system.today();
        insert tsk;
        return tsk;
    }
    public static Event createEvent(){
        Event evt=new Event();
        evt.Subject='test';
        evt.StartDateTime=DateTime.now();
        evt.EndDateTime=DateTime.now();
        evt.OwnerId=userInfo.getUserId();
        insert evt;
        return evt;
    }
    
    @isTest
    public static void getTodaysEventsTest()
    {
        createEvent();
        Manage_AppointmentsAndTasksController ctrl=Manage_AppointmentsAndTasksController.getTodaysEvents();
        Manage_AppointmentsAndTasksCtrlTest test=new Manage_AppointmentsAndTasksCtrlTest();
        test.wrapperLst = new List<Manage_AppointmentsAndTasksWrapper>();
        
        if(!ctrl.wrapperLst.isEmpty())
        {
            
            test.wrapperLst=ctrl.wrapperLst;
            system.assert(ctrl.wrapperLst[0].eventId != null);
        }
        
    }
    @isTest
    public static void updateEventTest()
    {
        Event evt=createEvent();
        Manage_AppointmentsAndTasksController ctrl=Manage_AppointmentsAndTasksController.getTodaysEvents();
        if(!ctrl.wrapperLst.isEmpty()){
            ctrl.wrapperLst[0].eventSub='Updated Sub';
        }
        
        String wrapper=JSON.serialize(ctrl.wrapperLst);
        Manage_AppointmentsAndTasksController.updateEvent(wrapper,0);
        Event ev=[Select id,Subject from Event where id=:evt.Id];
        system.assertEquals('Updated Sub', ev.Subject);
    }
    
    @isTest
    public static void getAllEventsTest()
    {
        createEvent();
        Manage_AppointmentsAndTasksController ctrl=Manage_AppointmentsAndTasksController.getAllPastEvents();
        if(!ctrl.wrapperLst.isEmpty())
        {
            system.assert(ctrl.wrapperLst[0].eventId != null);
        }
        Manage_AppointmentsAndTasksController ctr=Manage_AppointmentsAndTasksController.getAllUpcomingEvents();
        if(!ctr.wrapperLst.isEmpty())
        {
            system.assert(ctr.wrapperLst[0].eventId != null);
        }
    }
    
     @isTest
    public static void filterTest()
    {
        createEvent();
        DateTime dt=datetime.now();
        Manage_AppointmentsAndTasksController ctrl=Manage_AppointmentsAndTasksController.filter(dt);
        if(!ctrl.wrapperLst.isEmpty())
        {
            system.assert(ctrl.wrapperLst[0].eventId != null);
        }
    }
     @isTest
    public static void PastDatefilterTest()
    {
		Event evt=createEvent();
        evt.StartDateTime=datetime.now()-1;
        update evt;
        DateTime dt=datetime.now()-1;
        Manage_AppointmentsAndTasksController ctrl=Manage_AppointmentsAndTasksController.PastDatefilter(dt);
        if(!ctrl.wrapperLst.isEmpty())
        {
            system.assert(ctrl.wrapperLst[0].eventId != null);
        }       
    }
    @isTest
    public static void formWrapperTest()
    {
        Task tsk=createTask();
        List<Task> tskLst=new List<Task>();
        tskLst.add(tsk);
        Manage_AppointmentsAndTasksController ctrl=Manage_AppointmentsAndTasksController.formWrapper(tskLst);
         if(!ctrl.wrapperLst.isEmpty())
        {
            system.assert(ctrl.wrapperLst[0].taskObj != null);
        } 
    }
    
}