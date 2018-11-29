/* *******************************************************************************************************************
* Class Name   : DispatchTrackCtrlTest
* Description  : Test class for DispatchTrackCtrl controller     
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/12/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
public class DispatchTrackCtrlTest {
	
    @isTest
    public static void dispatchTrackTest() 
    {
        // Create custom setting
        Integration_Settings__c integSetting = new Integration_Settings__c(
        	Name = 'Dispatch_Track',
        	End_Point_URL__c = 'https://ashleyhomestore.dispatchtrack.com/track_order/6183ee9');
        insert integSetting;
                
        DispatchTrackCtrl.formDispatchTrackUrl('123');
    }
}