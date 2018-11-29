/* *******************************************************************************************************************
* Class Name   : ManageObjectsTest
* Description  : Test class for ManageObjects Controller.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 01/05/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
public class ManageObjectsTest {

    @isTest
    public static void deleteTaskRecordTest()
    {
        Task tsk=createTask();
        if(tsk != null)
        {
            ManageObjects.deleteCurrentRecord(tsk.id);
            List<Task> tskList=[Select id 
                                from Task 
                                where id =:tsk.id];
            system.assert(tskList.isEmpty());
        }
    }
    
    @isTest
    public static void deleteEventRecordTest()
    {
        Event evt=createEvent();
        if(evt != null)
        {
            ManageObjects.deleteCurrentRecord(evt.id);
            List<Event> evtList=[Select id 
                                 from Event 
                                 where id =:evt.id];
            system.assert(evtList.isEmpty());
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
    
    public static Event createEvent(){
        Event evt=new Event();
        evt.Subject='test';
        evt.StartDateTime=DateTime.now();
        evt.EndDateTime=DateTime.now();
        evt.OwnerId=userInfo.getUserId();
        insert evt;
        return evt;
    }
}