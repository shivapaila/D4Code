/****** v1 | Description: Test methods for picklist controller | 12/1/2017 | L OMeara */
@isTest
public class PickListController_Test {
    @isTest
    static void testGetPickListValuesIntoList() {
        List<String> results = PickListController.getPickListValuesIntoList('Contact', 'Primary_Language__c');
    	system.assertNotEquals(0,results.size());
    }
}