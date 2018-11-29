/****** v1 | Description: Methods for creating all customer associated records | 12/1/2017 | L OMeara */
/****** v2 | Update: changing support for note in create screen, per UX review with Andrew | 12/13/2017 | L OMeara */
/****** v3 | Update: completing customer endpoints create & update | 12/21/2017 | L OMeara */
/****** v4 | Update: updated for person accounts | 2/1/2018 | L OMeara */
public with sharing class AddCustomerController {
    static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    static final String ACCOUNT_TYPE_FIELD = 'General';
    static final Id AccountTypeCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACCOUNT_TYPE_CUSTOMER).getRecordTypeId();
        
    /* method used by add customer lightning component to create all customer related records from 
     * customer create form */
    @AuraEnabled
    public static Id createCustomerRecords(Account newCustomer, Address__c newShipping, Address__c newBilling, String noteStr){
        Savepoint sp = Database.setSavepoint();
        try {       
            // Set additional fields on contact record
            newCustomer.RecordtypeId = AccountTypeCustomer;
            newCustomer.Customer_Since__pc = system.today();

            // Create contact record
            insert(newCustomer);
            
            // Create associated address records
            if (newShipping != null) {
                newShipping.AccountId__c = newCustomer.Id;
                newShipping.Preferred__c = true;
                newShipping.Address_Type__c = 'Ship To';
                insert(newShipping);                
            }

            // check if new address is provided
            if (newBilling != null) {
                newBilling.AccountId__c = newCustomer.Id;
                newBilling.Address_Type__c = 'Bill To';
                insert(newBilling);
            }
            
            if (noteStr != null) {
                ManageRelatedNotesController.addNote(newCustomer.Id, noteStr);            
            }
            
            return newCustomer.Id;
        } catch (exception e) {
            Database.rollback(sp);
            system.debug(e.getMessage());
            throw new AuraHandledException('Could not create customer record: ' + e.getMessage());   
        }    
    }
    
    /* method used by add customer lightning component to update the customer related records from the 
     * customer create form */
    @AuraEnabled
    public static Id updateCustomerRecords(Account newCustomer, String noteStr) 
    {
        Savepoint sp = Database.setSavepoint();
        try {
            // update contact record
            upsert(newCustomer);

            if (noteStr != null) {
                ManageRelatedNotesController.addNote(newCustomer.Id, noteStr);            
            }
            
            return newCustomer.Id;
        } catch (exception e) {
            Database.rollback(sp);
            system.debug(e.getMessage());
            throw new AuraHandledException('Could not create customer record: ' + e.getMessage());   
        }    
    }
    
    /* method used by customr create rest endpoint to create all customer records */
    public static List<CustomerResponseWrapper.CustomerIdStruct> createAllCustomerRecords(List<CustomerWrapper> customerList) 
    {
        Map<Integer, CustomerWrapper> mappedCustomers = new Map<Integer, CustomerWrapper>();
        Map<Integer, Account> accounts = new Map<Integer, Account>();
        Map<Integer, Address__c> addressMap = new Map<Integer, Address__c>();
        
        Integer i=0;
        for (CustomerWrapper customer:customerList) {
            mappedCustomers.put(i, customer);

            accounts.put(i, new Account(
                RecordtypeId = AccountTypeCustomer, 
                //Commented by Venkat from D4 on 05/05/2018 this value will get from externalsystem.
                //Customer_Since__pc = system.today(), 
                FirstName = customer.firstName, 
                LastName = customer.lastName, 
                PersonEmail = customer.email, 
                Email_2__pc  = customer.email2, 
                Phone = customer.phone, 
                Phone_2__pc = customer.phone2, 
                Phone_3__pc = customer.phone3, 
                Primary_Language__pc = customer.primaryLanguage, 
                Tax_Exempt__pc = (customer.taxExempt!=null ? customer.taxExempt : false), 
                See_Management__pc = (customer.seeManagement!=null ? customer.seeManagement : false), 
                Twitter__pc = customer.twitterId, 
                Facebook__pc = customer.facebookId, 
                Instagram__pc = customer.instagramId, 
                Snapchat__pc = customer.snapchatId, 
                YouTube__pc = customer.youTubeId, 
                Pinterest__pc = customer.pinterestId,
                //added by Vankat from D4 for Customer Since field populate on 05/06/2018.
                Customer_Since__pc = customer.customerSince
            ));

            if (customer.addressLine1 != null) {
                addressMap.put(i, new Address__c (
                    address_line_1__c = customer.addressLine1, 
                    address_line_2__c = customer.addressLine2,
                    City__c = customer.city, 
                    State__c = customer.state, 
                    Zip_Code__c = customer.zip,
                    Country__c = (customer.country!=null? customer.country : 'US')
                ));
            }
            
            i++;
        }
        
        // create accounts 
        insert(accounts.values());
        
        // update the account associated records
        for (Integer key : accounts.keySet()) {
            Account acct = accounts.get(key);
            Address__c addr = addressMap.get(key);
            if (addr != null) {
                addr.AccountId__c = acct.id;
            }
        }
        
        insert(addressMap.values());
        
        List <CustomerResponseWrapper.CustomerIdStruct> contactIds = new List<CustomerResponseWrapper.CustomerIdStruct>();
        for (Integer key : mappedCustomers.keySet()) {
            Account account = accounts.get(key);
            CustomerWrapper cust = mappedCustomers.get(key);
            contactIds.add(new CustomerResponseWrapper.CustomerIdStruct(cust.globalId,account.id));
        }
        
        return contactIds;
    }

    /* method used by customr update rest endpoint to update all listed customer records */
    public static List<CustomerResponseWrapper.CustomerIdStruct> updateAllCustomerRecords(List<CustomerWrapper> customerList) 
    {
        Map<Id, CustomerWrapper> mappedCustomers = new Map<Id, CustomerWrapper>();
        Map<Id, Address__c> addressMap = new Map<Id, Address__c>();
        
        for (CustomerWrapper customer:customerList) {
            mappedCustomers.put(customer.customerID, customer);
        }
                
        Map<ID,Account> accounts = new Map<ID, Account>([SELECT Id, FirstName, LastName, 
                                                         PersonEmail, Email_2__pc, Phone, Phone_2__pc, 
                                                         Phone_3__pc, Primary_Language__pc, Tax_Exempt__pc, 
                                                         See_Management__pc, Twitter__pc, Facebook__pc, 
                                                         Instagram__pc, Snapchat__pc, YouTube__pc, 
                                                         Pinterest__pc,Customer_Since__pc 
                                                         FROM Account 
                                                         WHERE Id IN :mappedCustomers.keyset()]);

        // update the account associated records
        for (Id customerID : accounts.keySet()) {
            CustomerWrapper customer = mappedCustomers.get(customerID);
            // get customer entry
            Account acct = accounts.get(customerID);

            // prepare contact
            acct.FirstName = customer.firstName==null ? acct.FirstName : customer.FirstName; 
            acct.LastName = customer.lastName==null ? acct.LastName : customer.lastName; 
            acct.PersonEmail = customer.email==null ? acct.PersonEmail : customer.email; 
            acct.Email_2__pc  = customer.email2==null ? acct.Email_2__pc : customer.email2; 
            acct.Phone = customer.phone==null ? acct.Phone : customer.phone; 
            acct.Phone_2__pc = customer.phone2==null ? acct.Phone_2__pc : customer.phone2; 
            acct.Phone_3__pc = customer.phone3==null ? acct.Phone_3__pc : customer.phone3; 
            acct.Primary_Language__pc = customer.primaryLanguage==null ? acct.Primary_Language__pc : customer.primaryLanguage; 
            acct.Tax_Exempt__pc = customer.taxExempt==null ? acct.Tax_Exempt__pc : customer.taxExempt; 
            acct.See_Management__pc = customer.seeManagement==null ? acct.See_Management__pc : customer.seeManagement; 
            acct.Twitter__pc = customer.twitterId==null ? acct.Twitter__pc : customer.twitterId; 
            acct.Facebook__pc = customer.facebookId==null ? acct.Facebook__pc : customer.facebookId; 
            acct.Instagram__pc = customer.instagramId==null ? acct.Instagram__pc : customer.instagramId; 
            acct.Snapchat__pc = customer.snapchatId==null ? acct.Snapchat__pc : customer.snapchatId; 
            acct.YouTube__pc = customer.youTubeId==null ? acct.YouTube__pc : customer.youTubeId; 
            acct.Pinterest__pc = customer.pinterestId==null ? acct.Pinterest__pc : customer.pinterestId; 
            //added by Vankat from D4 for Customer Since field update on 05/06/2018.
            acct.Customer_Since__pc =customer.customerSince == null ? acct.Customer_Since__pc : customer.customerSince;
                        
            if (customer.addressLine1 != null) {
                // prepare address
                addressMap.put(customerID, new Address__c (
                    AccountId__c = acct.Id,
                    address_line_1__c = customer.addressLine1, 
                    address_line_2__c = customer.addressLine2,
                    City__c = customer.city, 
                    State__c = customer.state, 
                    Zip_Code__c = customer.zip,
                    Country__c = (customer.country!=null? customer.country : 'US')
                ));
            }
        }
        
        // make contact updates & address inserts
        update(accounts.values());
        if (addressMap.size() > 0 ) {
            insert(addressMap.values());        
        }
        
        List <CustomerResponseWrapper.CustomerIdStruct> contactIds = new List<CustomerResponseWrapper.CustomerIdStruct>();
        for (Id key : mappedCustomers.keySet()) {
            CustomerWrapper cust = mappedCustomers.get(key);
            contactIds.add(new CustomerResponseWrapper.CustomerIdStruct(cust.globalId,key));
        }
        
        return contactIds;
    }
    
    //add to add functionality on creating a customer DEF-0191
    @AuraEnabled
    public static void addToCart(String accountId, String prod,String prodPrice,Integer qty) {
        MyCustomerController.addToCart(accountId, prod, prodPrice, qty);
    }

    // EDQ added
    @AuraEnabled
    public static String SearchAddress(string searchTerm, string country, Integer take) {
        return EDQService.SearchAddress(searchTerm, country, take);
    }

    // EDQ added
    @AuraEnabled
    public static String FormatAddress(string formatUrl) {
        return EDQService.FormatAddress(formatUrl);
    }
}