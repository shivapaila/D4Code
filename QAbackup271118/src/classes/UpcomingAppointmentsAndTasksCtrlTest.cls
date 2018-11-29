/* *******************************************************************************************************************
* Class Name   : UpcomingAppointmentsAndTasksCtrlTest
* Description  : Test class for UpcomingAppointmentsAndTasksCtrl.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/28/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
public class UpcomingAppointmentsAndTasksCtrlTest 
{
    public  List<Manage_AppointmentsAndTasksWrapper> wrapperLst; 
    @isTest
    public static Account createAccount(){
        Account acc =new Account();
        acc.LastName='Test Acc1';
        String rtypeId=[Select id From RecordType Where DeveloperName = 'Customer' and SobjectType='Account'].id;
        acc.Phone='9090909090';
        acc.RecordTypeId=rtypeId;
        insert acc;
        
        /*Contact con=new Contact();
con.FirstName='Test';
con.LastName='Test1';
con.AccountId=acc.Id;
con.Phone='9090909090';
//String rectypeId=[Select id From RecordType Where name='Customer'].id;
//con.RecordTypeId=rectypeId;
con.OwnerId=UserInfo.getUserId();
insert con;*/
        return acc;
        
    }
    @isTest
    public static task createTask(){
        Task tsk=new Task();
        Account acc=UpcomingAppointmentsAndTasksCtrlTest.createAccount();
        List<Account> accLst=[Select id from Account where id=:acc.id];
        if(!accLst.isEmpty())
        {
            System.debug(accLst[0].id);
            tsk.Subject='test';
            tsk.Priority='Normal';
            tsk.Status='Open';
            tsk.WhatId=accLst[0].id;
            tsk.ActivityDate=system.today();
            insert tsk;
        }
        return tsk;
    }
    
    @isTest
    public static Event createEvent(){
        Event evt=new Event();
        Account acc=UpcomingAppointmentsAndTasksCtrlTest.createAccount();
        List<Account> accLst=[Select id from Account where id=:acc.id];
        if(!accLst.isEmpty())
        {
            evt.Subject='test';
            evt.StartDateTime=DateTime.now();
            evt.EndDateTime=DateTime.now();
            evt.WhatId=accLst[0].Id;
            insert evt;
        }
        return evt;
    }
    @isTest
    public static void upcomingCustomersEventsTest()
    {
        UpcomingAppointmentsAndTasksCtrlTest.createEvent();
        List<Account> accLst=[Select id from Account];
        if(!accLst.isEmpty())
        {
            UpcomingAppointmentsAndTasksController ctrl=UpcomingAppointmentsAndTasksController.upcomingCustomersEvents(accLst[0].id);
            if(ctrl != null)
            {
                if(!ctrl.wrapperLst.isEmpty())
                {
                    system.assert(ctrl.wrapperLst[0].eventId != null);
                }
            }
        }
    }
    @isTest
    public static void getAllUpcomingTasksTest()
    {
        
        Task tsk=UpcomingAppointmentsAndTasksCtrlTest.createTask();
        List<Account> accLst=[Select id from Account];
        
        if(!accLst.isEmpty())
        {
            UpcomingAppointmentsAndTasksController ctrl=UpcomingAppointmentsAndTasksController.getAllUpcomingTasks(accLst[0].id);
            
            if(ctrl != null)
            {
                if(!ctrl.wrapperLst.isEmpty())
                {
                    system.assert(ctrl.wrapperLst[0].taskObj != null);
                }
            }
        }
    }
    @isTest
    public static void statusCompleteTest()
    {
        Task tsk=createTask();
        UpcomingAppointmentsAndTasksController.statusComplete(tsk.Id);
        List<Task> tskLst=[select Id,status from Task where Id=:tsk.Id];
        if(!tskLst.isEmpty()){
            system.assert(tskLst[0].Status == 'Complete');
        }
        
    }
    @isTest
    public static void deleteTaskTest()
    {
        Task tsk=createTask();
        UpcomingAppointmentsAndTasksController.deleteTask(tsk.Id);
        List<Task> tskLst=[select Id from Task where Id=:tsk.Id];
        
        system.assert(tskLst.isEmpty());
    }
    @isTest
    public static void updateTaskTest()
    {
        Task task=createTask();
        UpcomingAppointmentsAndTasksController.updateTask(task.Id, 'updated sub', '2017-12-13', 'Phone');
        task=[Select Id,Subject,type from Task where Id =:task.Id];
        system.assertEquals('updated sub', task.Subject);
    }
}