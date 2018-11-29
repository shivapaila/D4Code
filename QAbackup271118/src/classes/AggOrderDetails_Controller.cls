/* *******************************************************************************************************************
* Class Name   : AggOrderDetails_Controller
* Description  : Controller class for component AggregateOrderDetails.     
* Author       : Venkat (Perficient, Inc.)
* Created On   : 12/11/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer         Date            Modification ID         Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Perficient        02-26-2018      DEF-0146                Adding a user friendly error message (message from external object) when no records are returned
**************************************************************************************************************************************/
public class AggOrderDetails_Controller {
    
    //This method will send all the Aggregate details of the Order details related to the Account ID
    @AuraEnabled
    public static AggOrderDetails_Wrapper getDetails(Id objectID){
        Integer count =0;
        Decimal totalAmount =0;
        String spendLevel = System.Label.Spend_Levels_Less_than_1000; //Defaulted to casual shopper as Amount is defaulted to 0
        Boolean isDelTech = false;
        Boolean isException = false;
        String externalObjectExceptionMsg = ''; // DEF-0146
        try{
            List<SalesOrder__x> salesDetails = new List<SalesOrder__x>();
            
            //Fetching the Driver Technician Profile Ids            
            List<String> delTechProfileNames = Profile_Details__c.getValues('DeliveryTechnicians').Profile_Names__c.split(',');
            Map<Id,Profile> delTechProfiles = new Map<Id,Profile>([SELECT Id,Name 
                                                                   FROM Profile 
                                                                   WHERE Name IN :delTechProfileNames]);
            
            //Checking whether the LoggedIn Profile is Delivery or Technician
            if(delTechProfiles.containsKey(UserInfo.getProfileId())){
                isDelTech= true;
            }
            
            //Getting Sales Order details    
            if(!Test.isRunningTest()) { 
                salesDetails = [SELECT Id,phhPurchaseValue__c 
                                FROM SalesOrder__x 
                                WHERE phhGuestId__c =:objectID];                 
            }
            else{   //In Test class, we cant create external Objects, so just assigning the values from Test class.
                totalAmount = AggOrderDetails_Controller_Test.salesOrderAmount;            
            }
            
            count = salesDetails.size();            
            for(SalesOrder__x tempSales :salesDetails) { 
                if(tempSales.phhPurchaseValue__c != NULL){ 
                    totalAmount += tempSales.phhPurchaseValue__c; 
                }
            }
            
            //Spend levels based on Custome Life Time Spend value
            if(totalAmount<=1000){            
                spendLevel = System.Label.Spend_Levels_Less_than_1000;
            }
            else if(totalAmount>1000 && totalAmount <=5000){            
                spendLevel = System.Label.Spend_Levels_Btwn_1000_And_5000;
            }
            else if(totalAmount>5000 && totalAmount <=10000){            
                spendLevel = System.Label.Spend_Levels_Btwn_5000_And_10000;
            }
            else if(totalAmount>10000 && totalAmount <=20000){            
                spendLevel = System.Label.Spend_Levels_Btwn_10000_And_20000;
            }
            else{  // else will be > 20001            
                spendLevel = System.Label.Spend_Levels_Greater_than_20000;
            }
        }
        // DEF-0146
        catch (ExternalObjectException e){
            isException = true;
            externalObjectExceptionMsg = e.getMessage();
        }
        catch(Exception e){
            isException = true; //Based on this Boolean variable, in component Error message is shown.
            System.debug('Exception when retrieving Order Details: '+e.getMessage());
        }
        
        AggOrderDetails_Wrapper salesDetails = new AggOrderDetails_Wrapper();
        salesDetails.totalCount = count;
        salesDetails.totalAmount = totalAmount;
        salesDetails.spendLevel = spendLevel;
        salesDetails.isDelTech = isDelTech;
        salesDetails.isException = isException;
        salesDetails.externalObjectExceptionMsg = externalObjectExceptionMsg; // DEF-0146
        return salesDetails;
    }            
}