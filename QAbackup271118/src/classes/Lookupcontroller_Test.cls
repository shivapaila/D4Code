@isTest
public class Lookupcontroller_Test {
    public static testMethod void querySalesforceRecordTest(){
       
        List<sObject> objs = Lookupcontroller.querySalesforceRecord('Select Id from User limit 1');
		System.assertEquals(1, objs.size());        
    }
}