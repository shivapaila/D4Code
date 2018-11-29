/* *******************************************************************************************************************
* Class Name   : AggOrderDetails_Controller_Test
* Description  : Test class for the Controller class AggOrderDetails_Controller.     
* Author       : Venkat (Perficient, Inc.)
* Created On   : 12/13/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/

@isTest
public class AggOrderDetails_Controller_Test {
        
    public static Decimal salesOrderAmount;
    
    //Non-DeliveryTechnician User 
    private static testMethod void testOrderDetails()
    {
        Profile nonDelTech = [SELECT Id 
                              FROM Profile 
                              WHERE Name ='Store Management'];
        //creating user
        User testUser =  new User(ProfileId = nonDelTech.Id,LastName = 'Testing User',Email = 'testUser@example.com',
                                  Username = 'testUser.Ashley@example.com',CompanyName = 'TEST',Title = 'title',Alias = 'alias',
                                  TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');
         
        System.runAs(testUser)
        {     
            //Creating Custom Setting 
            Profile_Details__c delTechProfiles = new Profile_Details__c();
            delTechProfiles.Name = 'DeliveryTechnicians';
            delTechProfiles.Profile_Names__c='';
            for(Profile tempProfile :[SELECT Id,Name 
                                      FROM Profile 
                                      WHERE Name LIKE '%Delivery%' OR Name LIKE '%Technician%'])
                delTechProfiles.Profile_Names__c += tempProfile.Name+',';
            insert delTechProfiles;            
            
            //Creating Account
            List<Account> testAccount = TestDataFactory.initializePersonAccounts(1);
            insert testAccount;            
            
            //Case 1: Amount < 1000 
            //In Test class, we cant create external Objects, so just passing the amount value and checking for the desired Spend level        
            salesOrderAmount = 500;  
            AggOrderDetails_Wrapper result = AggOrderDetails_Controller.getDetails(testAccount[0].Id);
            System.assertEquals(System.Label.Spend_Levels_Less_than_1000,result.spendLevel,'Amount <1000');
            System.assertEquals(false,result.isDelTech,'Non DelTech');
            
            //Case 2: 1000 < Amount < 5000
            salesOrderAmount = 1500;
            result = AggOrderDetails_Controller.getDetails(testAccount[0].Id);
            System.assertEquals(System.Label.Spend_Levels_Btwn_1000_And_5000,result.spendLevel,'Amount > 1000 and Amount <5000');
            System.assertEquals(false,result.isDelTech,'Non DelTech');
        }
    }
    
    //Delivery User 
    private static testMethod void testDelOrderDetails()
    {
        Profile deliveryProfile = [SELECT Id 
                                   FROM Profile 
                                   WHERE Name LIKE '%Delivery%' Limit 1];
        //creating user
        User deliveryUser =  new User(ProfileId = deliveryProfile.Id,LastName = 'Testing User',Email = 'testUser@example.com',
                                  Username = 'testUser.Ashley@example.com',CompanyName = 'TEST',Title = 'title',Alias = 'alias',
                                  TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');
         
        System.runAs(deliveryUser)
        {     
            //Creating Custom Setting
            Profile_Details__c delTechProfiles = new Profile_Details__c();
            delTechProfiles.Name = 'DeliveryTechnicians';
            delTechProfiles.Profile_Names__c='';
            for(Profile tempProfile :[SELECT Id,Name 
                                      FROM Profile 
                                      WHERE Name LIKE '%Delivery%' OR Name LIKE '%Technician%']){
                delTechProfiles.Profile_Names__c += tempProfile.Name+',';
            }
            insert delTechProfiles;            
            
             List<Account> testAccount = TestDataFactory.initializePersonAccounts(1);
            insert testAccount;
            
            //Case 3: 5000 < Amount < 10000           
            salesOrderAmount = 5005;
            AggOrderDetails_Wrapper result = AggOrderDetails_Controller.getDetails(testAccount[0].Id);
            System.assertEquals( System.Label.Spend_Levels_Btwn_5000_And_10000,result.spendLevel,'Amount >5000');
            System.assertEquals(true,result.isDelTech,'Non DelTech');
            
            //Case 4: 10000 < Amount < 20000 
            salesOrderAmount = 15000; 
            result = AggOrderDetails_Controller.getDetails(testAccount[0].Id);
            System.assertEquals( System.Label.Spend_Levels_Btwn_10000_And_20000,result.spendLevel,'Amount > 10000 and Amount <20000');
            System.assertEquals(true,result.isDelTech,'Delivery User');
        }
    }   

    //Technician User 
    private static testMethod void testTechOrderDetails()
    {
        Profile techProfile = [SELECT Id 
                               FROM Profile 
                               WHERE Name LIKE '%Technician%' Limit 1];
        //creating user
        User technicianUser =  new User(ProfileId = techProfile.Id,LastName = 'Testing User',Email = 'testUser@example.com',
                                  Username = 'testUser.Ashley@example.com',CompanyName = 'TEST',Title = 'title',Alias = 'alias',
                                  TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');
         
        System.runAs(technicianUser)
        {     
            //Creating Custom Setting
            Profile_Details__c delTechProfiles = new Profile_Details__c();
            delTechProfiles.Name = 'DeliveryTechnicians';
            delTechProfiles.Profile_Names__c='';
            for(Profile tempProfile :[SELECT Id,Name 
                                      FROM Profile 
                                      WHERE Name LIKE '%Delivery%' OR Name LIKE '%Technician%']){
                delTechProfiles.Profile_Names__c += tempProfile.Name+',';
            }
            insert delTechProfiles;            
            
            List<Account> testAccount = TestDataFactory.initializePersonAccounts(1);
            insert testAccount;
            
            //Case 5: Amount > 20000          
            salesOrderAmount = 50005;
            AggOrderDetails_Wrapper result = AggOrderDetails_Controller.getDetails(testAccount[0].Id);
            System.assertEquals(System.Label.Spend_Levels_Greater_than_20000,result.spendLevel,'Amount >20000');
            System.assertEquals(true,result.isDelTech,'Technician User');                     
        }
    }
}