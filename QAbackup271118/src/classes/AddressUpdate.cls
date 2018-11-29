global class AddressUpdate implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id FROM Account where id ='001q000000rs5p3AAA']); 
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accList){

        List<Address__c> addressList = [SELECT AccountId__c, Address_Type__c, Id FROM Address__c WHERE AccountId__c = :accList ORDER BY lastModifiedDate DESC];

        if(addressList.size() > 0){
            Map<String, List<Address__c>> addressMap = new Map<String, List<Address__c>>();
            List<Address__c> tmpAddress;
            for (Address__c adds:addressList)
            {
                tmpAddress = new List<Address__c>();
                if(addressMap.get(adds.AccountId__c) != null){
                    tmpAddress = addressMap.get(adds.AccountId__c);
                }
                tmpAddress.add(adds);
                addressMap.put(adds.AccountId__c, tmpAddress);
            }

            List<Address__c> updateAddress = new List<Address__c>();

            Integer i;
            for(Account accId:accList){
                tmpAddress = new List<Address__c>();
                if(addressMap.get(accId.Id) != null){
                    tmpAddress = addressMap.get(accId.Id);
                    i = 0;
                    for(Address__c addrs:tmpAddress){
                        if(tmpAddress.size() == 1){
                            addrs.Address_Type__c = 'Ship To';
                        }
                        else if(tmpAddress.size() == (i+1)){
                            addrs.Address_Type__c = 'Bill To';
                        }
                        else{
                            addrs.Address_Type__c = 'Ship To';
                        }
                        ++i;
                        updateAddress.add(addrs);
                    }
                }
            }
            if(updateAddress.size() > 0) update updateAddress;
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}