/**************************************************************************************************
* Name       : AddressTriggerHandler
* Purpose    : TriggerHandler for Address__c
***************************************************************************************************
* Author            | REQ    | Created Date    | Description
***************************************************************************************************
*Perficient         |         | 03/05/2018      | Initial Draft
***************************************************************************************************
*D4         |       | 23/05/2018      | Make the changes for Bill to/Shi to
**************************************************************************************************/

public class AddressTriggerHandler 
{
    //public Static boolean isAddrUpdate = true;
    public static void afterInsert(Map<Id, Address__c> newMap)
    {
        // custom setting flag to switch on/off integration
        // probably for a bulk load of more than 10K records
        if(Trigger_Integration__c.getInstance().Account_Updates_to_CARA__c
                && API_CaraAccountUpdates.accountsToCARACodeLevelFlag // if an account is created by HOMES this flag will be false
                && !system.isBatch() && !system.isFuture())
        {
            // send the Address__c to CARA on every insert
            API_CaraAccountUpdates.sendAccountsAndAddressesToCara(newMap.keyset());
        }
    }

    public static void afterUpdate(Map<Id, Address__c> oldMap, Map<Id, Address__c> newMap)
    {
        Set<Id> addressIds = new Set<Id>();
        for(Id addressId : newMap.keySet())
        {
            // if any integration fields are changed, send the Address__c to CARA
            if(hasIntegrationFieldsChanged(oldMap.get(addressId), newMap.get(addressId)))
            {
                addressIds.add(addressId);
            }
        }

        // custom setting flag to switch on/off integration
        // probably for a bulk load of more than 10K records
        if(Trigger_Integration__c.getInstance().Account_Updates_to_CARA__c
                && API_CaraAccountUpdates.accountsToCARACodeLevelFlag // if an account is created by HOMES this flag will be false
                && !addressIds.isEmpty() && !system.isBatch() && !system.isFuture())
        {
            API_CaraAccountUpdates.sendAccountsAndAddressesToCara(addressIds);
        }
    }

    // method to check if any integration fields are changed; list of integration fields are in API_CaraAccountUpdates.cls
    private static boolean hasIntegrationFieldsChanged(Address__c oldAddress, Address__c newAddress)
    {
        for(SObjectField sf : API_CaraAccountUpdates.addressFields)
        {
            if(oldAddress.get(sf) != newAddress.get(sf))
            {
                return true;
            }
        }
        return false;
    }
    
    //method to check for Address Type added by Venkat
    public static void beforeInsertAddressType(List<Address__c> newAddrssLst){
        
        Set<String> accntIds = new Set<String>();
        List<Account> accLst = new List<Account>();
        List<Address__c> addrssLst = new List<Address__c>();
        List<Address__c> addrLst = new List<Address__c>();
        List<Address__c> addsLst = new List<Address__c>();
        Map<String, List<Address__c>> addrsMaplist = new Map<String, List<Address__c>>(); 
        
        for(Address__c objAddrss : newAddrssLst){
            //addrLst.add(addr);
            accntIds.add(objAddrss.AccountId__c);
            //addrsMaplist.put(objAddrss.AccountId__c,addrLst);
        }
        
        if(!accntIds.isEmpty())
        {
            addrssLst =[Select Id, Preferred__c, AccountId__c from Address__c where AccountId__c IN:accntIds];
            system.debug('addrssLst-------'+addrssLst);
        }
        if(!addrssLst.isEmpty())
        {
            for(Address__c addr : addrssLst)
            {
                if(addr.Preferred__c)
                {
                    addr.Preferred__c = false;
                    addrLst.add(addr);
                    addrsMaplist.put(addr.AccountId__c,addrLst);
                }
            }
        }
        
        system.debug('addrsMaplist-------'+addrsMaplist);
        for(Address__c objAddrss : newAddrssLst){
            system.debug('addrsMaplist-------'+addrsMaplist.get(objAddrss.AccountId__c));
            if(!addrsMaplist.isEmpty() && objAddrss.Preferred__c)
            {
                for(Address__c objAdrss : addrsMaplist.get(objAddrss.AccountId__c))
                {
                    Address__c Addrss = new Address__c();
                         
                    Addrss.Id = objAdrss.Id;
                    Addrss.Preferred__c = false;
                    addsLst.add(Addrss);
                    system.debug('addsLst---inf---'+addsLst);
                   
                }
                //addsLst.add(objAddrss);
                system.debug('addsLst---otf---'+addsLst);
            }
            else if(addrsMaplist.isEmpty())
            {
                objAddrss.Preferred__c = true;
                 
            }
            
            
        }
        
        if(!addsLst.isEmpty())
        {
            system.debug('addsLst---up---'+addsLst);
            upsert addsLst;
            
        }
        
    }
    public static void beforeUpdateAddressType(List<Address__c> newAddrssUpdte, Map<Id,Address__c> oldMap){
        Set<String> accntIds = new Set<String>();
        List<Account> accLst = new List<Account>();
        List<Address__c> addrssLst = new List<Address__c>();
        List<Address__c> addrLst = new List<Address__c>();
        List<Address__c> addsLst = new List<Address__c>();
        Map<String, List<Address__c>> addrsMaplist = new Map<String, List<Address__c>>(); 
        
        for(Address__c objAddrss : newAddrssUpdte){
            
            Address__c oldAdd = oldMap.get(objAddrss.Id);
            system.debug('Preferred---new----'+objAddrss.Preferred__c+'----old----'+oldAdd.Preferred__c);
            if(oldAdd.Preferred__c != objAddrss.Preferred__c)
            {
                system.debug('Preferred---new1----'+objAddrss.Preferred__c+'----old----'+oldAdd.Preferred__c);
                //addrLst.add(addr);
                accntIds.add(objAddrss.AccountId__c);
                //addrsMaplist.put(objAddrss.AccountId__c,addrLst);
            }
        }
        
        if(!accntIds.isEmpty())
        {
            addrssLst =[Select Id, Preferred__c, AccountId__c,Address_Type__c from Address__c where AccountId__c IN:accntIds and Preferred__c = true];
            system.debug('addrssLst-------'+addrssLst);
        }
        if(!addrssLst.isEmpty())
        {
            for(Address__c addr : addrssLst)
            {
                if(addr.Preferred__c)
                {
                    addr.Preferred__c = false;
                    addrLst.add(addr);
                    addrsMaplist.put(addr.AccountId__c,addrLst);
                }
            }
        }
       
        system.debug('addrsMaplist-------'+addrsMaplist);
        for(Address__c objAddrss : newAddrssUpdte){
            system.debug('addrsMaplist-------'+addrsMaplist.get(objAddrss.AccountId__c));
            Address__c oldAddress = oldMap.get(objAddrss.Id);
            if(!addrsMaplist.isEmpty() && objAddrss.Preferred__c)
            {
                for(Address__c objAdrss : addrsMaplist.get(objAddrss.AccountId__c))
                {
                    system.debug('objAdrss---inf---'+objAdrss);
                    //if(objAdrss.Preferred__c != oldAddress.Preferred__c)
                    //{
                        Address__c Addrss = new Address__c();
                             
                        Addrss.Id = objAdrss.Id;
                        Addrss.Preferred__c = false;
                        addsLst.add(Addrss);
                        system.debug('addsLst---inf---'+addsLst);
                   //}
                   /*else if(objAdrss.Address_Type__c == 'Bill To')
                   {
                       objAddrss.add
                   }*/
                }
                //addsLst.add(objAddrss);
                system.debug('addsLst---otf---'+addsLst);
            }
            /*else if(!addrsMaplist.isEmpty() && objAddrss.Preferred__c == false && oldAddress.Preferred__c == true)
            {
                objAddrss.addError('Account must have atleast one preffered address.');
            }*/
            
            
        }
        
        if(!addsLst.isEmpty())
        {
            system.debug('addsLst---up---'+addsLst);
            upsert addsLst;
            //isAddrUpdate = false;
        }
    }
    
    public static void afterInsertAddressType(List<Address__c> newAddrssLst){
        try{
            List<String> accIds = new List<String>();
            Map<String, Address__c> accntMap = new Map<String, Address__c>();
            for(Address__c addr : newAddrssLst)
            {
                if(addr.Preferred__c && addr.Address_Type__c == 'Ship To')
                {
                    accIds.add(addr.AccountId__c);
                    accntMap.put(addr.AccountId__c, addr);
                }
            }
            
            List<Account> accList = [Select Id, Name, BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry
                                     from Account where Id =:accIds[0]];
            //if(!accIds.isEmpty())
            //{
            //    addrssLst =[Select Id, Preferred__c, AccountId__c from Address__c where AccountId__c IN:accIds and Preferred__c = true];
            //}
            
            if(!accList.isEmpty())
            {
                List<Account> accntList =new List<Account>();
                for(Account ac: accList )
                {
                    Account act = new Account();
                    
                    act.Id = ac.Id;
                    act.BillingStreet = accntMap.get(ac.Id).Address_Line_1__c +','+accntMap.get(ac.Id).Address_Line_2__c;
                    act.BillingCity  = accntMap.get(ac.Id).City__c;
                    act.BillingState = accntMap.get(ac.Id).State__c;
                    act.BillingPostalCode = accntMap.get(ac.Id).Zip_Code__c;
                    if(accntMap.get(ac.Id).Country__c != null)
                    {
                        act.BillingCountry = accntMap.get(ac.Id).Country__c;
                    }
                    accntList.add(act); 
                }
                
                update accntList;
            }
        } 
        catch(exception ex){
            
        }
    }
    public static void duplicateAddress(List<Address__c> Address){
        
        Set<String> setName = new Set<String>();
      
        Map<String, Address__c> dupAddressMap = new Map<String, Address__c>();
        For(Address__c addr: Address)
        {
            setName.add(addr.AccountId__c);
        }
        
        if(setName.size() > 0 )
        {
            list<Address__c> Addresslist =new list<Address__c>([select id,AccountId__c,Address_Line_1__c,Address_Line_2__c,StatePL__c,City__c,State__c,Zip_Code__c,Country__c,Address_Type__c from Address__c where AccountId__c in :setName ]);
            
            
            For(Address__c addr: Addresslist)
            {
              String dupAddress= addr.AccountId__c +'-'+ addr.Address_Line_1__c +'-'+ addr.Address_Line_2__c +'-'+ addr.Country__c+'-'+addr.StatePL__c+'-'+addr.City__c+'-'+addr.Zip_Code__c+'-'+addr.Address_Type__c;
               dupAddressMap.put(dupAddress,addr);
                
            }
            System.debug('dupAddressMap'+dupAddressMap);
            For(Address__c  addr: Address)
            {
                
                String dupNewAddress= addr.AccountId__c +'-'+ addr.Address_Line_1__c +'-'+ addr.Address_Line_2__c +'-'+ addr.Country__c+'-'+addr.StatePL__c+'-'+addr.City__c+'-'+addr.Zip_Code__c+'-'+addr.Address_Type__c;
                 System.debug('dupNewAddress'+dupNewAddress);
                Address__c  oldAddress = dupAddressMap.get(dupNewAddress);
                System.debug('oldAddress'+oldAddress);
                if(oldAddress != null)
                {
                     addr.AccountId__c.addError('Customer Already has Same Address');
                }
            }
            
        }
    }
  /*  
    public static void afterInsertUpdatePreffered(List<Address__c> newAddList, Map<Id,Address__c> oldMap){
        system.debug('afterInsertUpdatePreffered-------'+newAddList);
        system.debug('afterInsertUpdatePreffered-------'+oldMap);
        Set<String> acctIds = new Set<String>();
        List<Address__c> addrssLst = new List<Address__c>();
        List<Address__c> addrssLstUpdate = new List<Address__c>();
        for(Address__c newAd : newAddList){
            Address__c oldAd = oldMap.get(newAd.Id);
            if(oldAd.AccountId__c != newAd.AccountId__c && newAd.Preferred__c){
                acctIds.add(newAd.AccountId__c);
            }
        }
        system.debug('acctIds------->'+acctIds);
        if(!acctIds.isEmpty()){
            addrssLst =[Select Id, Preferred__c, AccountId__c, CreatedDate from Address__c where AccountId__c IN:acctIds];
            system.debug('addrssLst-------'+addrssLst);
        }
        if(!addrssLst.isEmpty()){
            for(Address__c newAd : newAddList){
                for(Address__c addr : addrssLst){
                    if(addr.Preferred__c){
                        if(addr.CreatedDate >= newAd.CreatedDate){
                            system.debug('newAd CreatedDate------->'+newAd.CreatedDate);
                            newAd.Preferred__c = false;
                            addrssLstUpdate.add(newAd);
                        }
                        else{
                            addr.Preferred__c = false;
                            system.debug('newAd Preferred__c------->'+addr.Preferred__c);
                            addrssLstUpdate.add(addr);
                        }
                    }
                }
            }
        }
        if(!addrssLstUpdate.isEmpty()){
            system.debug('newAd addrssLstUpdate------->'+addrssLstUpdate);
            Update addrssLstUpdate;
        }
    } */
}