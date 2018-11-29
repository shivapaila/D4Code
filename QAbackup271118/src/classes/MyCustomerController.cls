/* *******************************************************************************************************************
* Class Name   : MyCustomerController
* Description  : Controller class for MyCustomer Lightning Component.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/14/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Moon Cui (Perficient)                       2/1/2018                                    Updated for Person Account.
* JoJo Zhao (Perficient)                      2/13/2018                               for DEF-0308, update ItemType value when add item to cart
* JoJo Zhao (Perficient)                      2/25/2018                               for REQ-299, Enhancement
* Theyagarajan Sadhasivam (Perficient, Inc.)  2/28/2018								  search customers by name, email &  phone(Enhancement)
* JoJo Zhao (Perficient)                      3/28/2018                               Refix DEF-0424 to fix  ReOpen on DEF-0308
**************************************************************************************************************************************/
public class MyCustomerController 
{
    
    @AuraEnabled
    public static List<Account> getAccounts() {
        List<Account> accountLst= new List<Account>();
        
        accountLst=[SELECT Id, Name, PersonMailingAddress, Phone, PersonEmail	
                    FROM Account 
                    WHERE RecordType.DeveloperName='Customer' AND OwnerId=:UserInfo.getUserId() Order by Name];
        Date validityStartingDate = Date.today().addDays(0-Integer.valueOf(System.Label.Cart_limit));
        accountLst = [select Id, Name, PersonMailingAddress, Phone, Phone_2__pc, Phone_3__pc, PersonEmail, Last_Activity_Date__pc, LastModifiedDate,
                      (SELECT id FROM opportunities WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND StageName != 'Sale Suspended' AND CreatedDate > :validityStartingDate),
                      (SELECT id, LastModifiedDate, City__c, State__c FROM addresses__r ORDER BY LastModifiedDate DESC)
                      from Account WHERE id IN :accountLst ORDER BY Last_Activity_Date__pc, LastModifiedDate DESC];
        return accountLst;
    }
    @AuraEnabled
    public static List <Account> findAccount(String searchKeyWord, Boolean isMyGuest) {
        String searchKey = '%'+searchKeyWord+'%';
        List<List<sObject>> searchListName;
        List<List<sObject>> searchListEmail;
        List<List<sObject>> searchListPhone;
        if(isMyGuest){
            searchListName = [FIND :searchKey IN NAME FIELDS RETURNING 
                              Account(Id, Name, PersonMailingAddress, Phone, PersonEmail, Current_Owner_Email__c, Previous_Owner_Email__c 
                                      WHERE RecordType.DeveloperName='Customer' 
                                      AND OwnerId=:UserInfo.getUserId())];
            searchListEmail = [FIND :searchKey IN EMAIL FIELDS RETURNING 
                               Account(Id, Name, PersonMailingAddress, Phone, PersonEmail, Current_Owner_Email__c, Previous_Owner_Email__c 
                                       WHERE RecordType.DeveloperName='Customer' 
                                       AND OwnerId=:UserInfo.getUserId())];
            searchListPhone = [FIND :searchKey IN PHONE FIELDS RETURNING 
                               Account(Id, Name, PersonMailingAddress, Phone, PersonEmail, Current_Owner_Email__c, Previous_Owner_Email__c 
                                       WHERE RecordType.DeveloperName='Customer' 
                                       AND OwnerId=:UserInfo.getUserId())];
            
        }else{
            searchListName = [FIND :searchKey IN NAME FIELDS RETURNING 
                              Account(Id, Name, PersonMailingAddress, Phone, PersonEmail, Current_Owner_Email__c, Previous_Owner_Email__c 
                                      WHERE RecordType.DeveloperName='Customer'  
                                      ORDER BY Name)];
            searchListEmail = [FIND :searchKey IN EMAIL FIELDS RETURNING 
                               Account(Id, Name, PersonMailingAddress, Phone, PersonEmail, Current_Owner_Email__c, Previous_Owner_Email__c 
                                       WHERE RecordType.DeveloperName='Customer'  
                                       ORDER BY Name)];
            searchListPhone = [FIND :searchKey IN PHONE FIELDS RETURNING 
                               Account(Id, Name, PersonMailingAddress, Phone, PersonEmail, Current_Owner_Email__c, Previous_Owner_Email__c 
                                       WHERE RecordType.DeveloperName='Customer'  
                                       ORDER BY Name)];
            
        }
        List<Account> lstAccounts = new List<Account>();
        if(!searchListName.isEmpty()){
            lstAccounts.addAll((List<Account>)searchListName[0]);  
        }
        if(!searchListEmail.isEmpty()){
            lstAccounts.addAll((List<Account>)searchListEmail[0]);  
        }
        if(!searchListPhone.isEmpty()){
            lstAccounts.addAll((List<Account>)searchListPhone[0]);  
        }
        Date validityStartingDate = Date.today().addDays(0-Integer.valueOf(System.Label.Cart_limit));
        lstAccounts = [select Id, Name, PersonMailingAddress, Phone, Phone_2__pc, Phone_3__pc, PersonEmail, Last_Activity_Date__pc, LastModifiedDate, Owner.Name,Previous_Owner_Email__c,Current_Owner_Email__c,
                       (SELECT id FROM opportunities WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND StageName != 'Sale Suspended' AND CreatedDate > :validityStartingDate),
                       (SELECT id, LastModifiedDate, City__c, State__c FROM addresses__r ORDER BY LastModifiedDate DESC)
                       FROM Account WHERE id IN :lstAccounts AND (NOT Previous_Owner_Email__c LIKE :searchKey ) AND (NOT Current_Owner_Email__c LIKE :searchKey)
                       ORDER BY Last_Activity_Date__pc,LastModifiedDate DESC];
        
        return lstAccounts;
    }
    // DEF-0780 - Manually add product performance fix - updated to return the new added product list
    @AuraEnabled
    public static List<Shopping_cart_line_item__c> addToCart(Id accountId, String prod,String prodPrice,Integer qty) {
        
        Double Qnty = double.valueOf(qty);
        
        //getting productDetails
        Map<String, Object> objMap =(Map<String, Object> ) JSON.deserializeUntyped(prod);
        system.debug('objMap---'+objMap);
        String productSKUId = (String)objMap.get('sku');
        Map<String, SalesOrderLineWrapper> skuArrMap= ProductPriceCmpCtrl.getItemDetailInfoMap(productSKUId);
        if(skuArrMap==null){
            throw new ItemDetailsAPIException('This Product is failed when calling item-details API');
        }
        Set<String> skuArr = skuArrMap.keySet().clone();
        skuArr.remove(productSKUId);
        String[] subSKUArr =new List<String>(skuArr);

        //REQ-438 set Product_Title__c when add to cart 
        String productTitle = (String)objMap.get('productTitle');
        
        String oppExpireLimit=System.Label.Cart_limit;
        String query='Select Id, AccountId,Account.Name,CreatedDate '+
            'From Opportunity '+
            'Where AccountId =:accountId And StageName != \'Closed Won\' and StageName != \'Closed Lost\' and StageName != \'Sale Suspended\'  And CreatedDate = LAST_N_DAYS:'+oppExpireLimit;
        system.debug('query---'+query);
        List<Opportunity> oppLst=Database.query(query);
        system.debug('oppLst---'+oppLst);
        List<Opportunity> newOppLst=new List<Opportunity>();
        //adding new opportunity to the Customer
        Boolean isNewOpp = false;
        if(oppLst.isEmpty())
        {
            system.debug('entered');
            isNewOpp = true;
            Account con=[Select Name 
                         from Account 
                         where Id=:accountId];
            Address__c[] addrs =[SELECT Id,AccountId__c,Address_Line_1__c,Address_Line_2__c,City__c,State__c,Country__c,Zip_Code__c 
                FROM Address__c 
                WHERE AccountId__c = :accountId
                ORDER BY Preferred__c DESC, LastModifiedDate DESC limit 1];
        
            Opportunity opp =new Opportunity();
            opp.Name=con.Name+'-'+system.today().format();
            opp.StageName='Saved Shopping Cart';
            opp.CloseDate=system.today()+30;
            opp.AccountId=accountId;
            if(addrs!=null && addrs.size()>0){
                if(addrs[0].Zip_Code__c!=null){
                    opp.Cart_ZipCode__c = addrs[0].Zip_Code__c;
                }
                if(addrs[0].Zip_Code__c!=null){
                    opp.Cart_State__c = addrs[0].State__c;
                }   
            }
            newOppLst.add(opp);
            oppLst.add(opp);
        }
        
        List<Shopping_cart_line_item__c> cartLst= new List<Shopping_cart_line_item__c>();
        Map<Id, Shopping_cart_line_item__c> deliveryDateUpdateLIneMap = new Map<Id, Shopping_cart_line_item__c>();
      
        Boolean isPackageTypeProd =false;
        if(oppLst[0].Id!=null){
            if(subSKUArr.size()>0){
                cartLst=[Select Id, Product_SKU__c, Opportunity__c,Quantity__c 
                         From Shopping_cart_line_item__c 
                         Where Opportunity__c=:oppLst[0].Id and Product_SKU__c in :subSKUArr];
                isPackageTypeProd=true;
            }else{         
                cartLst=[Select Id, Product_SKU__c, Opportunity__c,Quantity__c 
                         From Shopping_cart_line_item__c 
                         Where Opportunity__c=:oppLst[0].Id and Product_SKU__c =:productSKUId];
            }
        }else{//opp is a new cart, no existing item yet.
            if(subSKUArr.size()>0){
                 isPackageTypeProd=true;
            }
        }
       // Double originalQnty =0;
        String[] newSKUArr = new String[]{};
            
            if(cartLst.isEmpty())
        {
            if(!isPackageTypeProd){
                newSKUArr.add(productSKUId);
            }else{
                newSKUArr.addAll(subSKUArr);
            }
            
            
        }else{
           if(isPackageTypeProd){
                Set<String> existSKU = new Set<String>();

                for(Shopping_cart_line_item__c cartItem:cartLst){
                    existSKU.add(cartItem.Product_SKU__c);
                }
                for(String pSKUId:subSKUArr){
                    if(!existSKU.contains(pSKUId)){
                        newSKUArr.add(pSKUId);
                    }
                }
            }
        }
         List<Shopping_cart_line_item__c> cartLsttest= new List<Shopping_cart_line_item__c>();
            Map<String, Shopping_cart_line_item__c> cartmap = new Map<String, Shopping_cart_line_item__c>();
            string idname = oppLst[0].Id;
            system.debug('idname---'+idname);
            cartLsttest=[Select Id, Product_SKU__c, Opportunity__c,Quantity__c,DeliveryType__c,Delivery_Mode__c 
                         From Shopping_cart_line_item__c 
                     Where Opportunity__c=:idname];
            system.debug('cartLsttest----'+cartLsttest);
            
            for(Shopping_cart_line_item__c tt:cartLsttest)
            {
              cartmap.put(tt.DeliveryType__c,tt);  
            }
        for(String pSKUId:newSKUArr){
           
            
            Shopping_cart_line_item__c lineItem=new Shopping_cart_line_item__c();
            lineItem.Opportunity__c=oppLst[0].Id;
            lineItem.Product_SKU__c=pSKUId;
            lineItem.Quantity__c=0;
            lineItem.Delivery_Mode__c = 'HD';
            if(cartmap.containsKey('THD'))
            {
             lineItem.DeliveryType__c = 'THD';   
            }
            if(cartmap.containsKey('PDI'))
            {
             lineItem.DeliveryType__c = 'PDI';   
            }
            
          //  lineItem.DeliveryType__c = 'THD';
            //REQ-431- defaulting delivery mode based on isDirectShipOnly attribute
            //exclude *SKU when call product feed API  
            if(!pSKUId.startsWith('*')){
                ProductWrapper prodDetail=ProductDetailCmpCtrl.getProductDetail(pSKUId);
                //3X0000004153   is 3x  SKU, it's special,which has info from Unbxd, but Not Found in product feed detail API.                                      
                if(prodDetail!=null){
                    if(prodDetail.isDirectShipOnly == true){
                        lineItem.Delivery_Mode__c = 'DS';
                    }
                    //REQ-438 set Product_Title__c from product feed detail API when add to cart 
                    lineItem.Product_Title__c=prodDetail.productTitle;
                    //DEF-0780 - Caching required info
                    lineItem.eComm_Small_Image__c = prodDetail.ecommSmallImage;
                    lineItem.Item_Color__c = prodDetail.itemColor;
                    
                }else{
                    try{
                        //DEF-0818 Find product title for prod which has info from Unbxd, but Not Found in product feed detail API.
                        Map<String, object> prodDetailUnbxd=(Map<String, object>)JSON.deserializeUntyped(ProductDetailCmpCtrl.getProductListSearch(pSKUId, 0, 96, null));
                        Map<String, object> prods=(Map<String, object>)prodDetailUnbxd.get('response');
                        List<Object> objs =  (List<Object>) prods.get('products');
                        Map<String, Object> prodObj=(Map<String, Object>)objs[0];
                        lineItem.Product_Title__c=(String)prodObj.get('name');
                        //DEF-0780 - Caching required info
                        lineItem.eComm_Small_Image__c = (String)prodObj.get('smallImageUrl');
                        if(prodObj.get('colors') != null) {
                            String s = JSON.serialize(prodObj.get('colors'));
                            if(s != null && s != '') {
                                List<String> colors = (List<String>)JSON.deserialize(s, List<String>.class);
                                if(colors != null && !colors.isEmpty()) {
                                    lineItem.Item_Color__c = colors[0];
                                }
                            }
                        }

                    }catch(JSONException ex){
                        //keep this debug info in case fail to fetch product title from unbxd api, do not do save error log DML before any call out. 
                        System.debug('ex:'+ex.getMessage());
                    }catch(Exception e){
                        //In case other exception when fetch unbxd api to get product name, so that not block addToCart process
                        System.debug('e:'+e.getMessage());
                    }
                }
            }
           
            //DEF-0870 and DEF-0849  retrieve price from item-details API response lineItem
            lineItem.List_Price__c=skuArrMap.get(pSKUId).OriginalPrice;
            
            
            List<Shopping_cart_line_item__c> lineitems=[Select Id, Product_SKU__c, Opportunity__c,Delivery_Mode__c,DeliveryDate__c
                                                        From Shopping_cart_line_item__c 
                                                        Where Opportunity__c=:oppLst[0].Id and Delivery_Mode__c='HD']; 
            
            //DEF-0562 adding delivery date for *SKU
            if(pSKUId.startsWith('*')){
                if(lineitems!=null && lineitems.size()>0){                    
                    lineItem.DeliveryDate__c = lineitems[0].DeliveryDate__c;
                }
            }else{
                //Empty the delivery date DEF-0424
                if(!lineitems.isEmpty()){
                    for(Shopping_cart_line_item__c line:lineitems){
                        line.DeliveryDate__c=null;
                        deliveryDateUpdateLIneMap.put(line.Id, line);
                    }
                    
                }
            }
            cartLst.add(lineItem);
        }
        
        if(isNewOpp){
            insert newOppLst;
            for(Shopping_cart_line_item__c cartItem:cartLst){
                
                cartItem.Opportunity__c=newOppLst[0].Id;
            }
        }
        List<Shopping_cart_line_item__c> lstToBeUpdated= new List<Shopping_cart_line_item__c>();
        for(Shopping_cart_line_item__c cartItem:cartLst){
            
            cartItem.Quantity__c=cartItem.Quantity__c+Qnty;
            if(deliveryDateUpdateLIneMap.get(cartItem.Id)!=null){
                
                cartItem.DeliveryDate__c = deliveryDateUpdateLIneMap.get(cartItem.Id).DeliveryDate__c;
                deliveryDateUpdateLIneMap.remove(cartItem.Id);
            }
            lstToBeUpdated.add(cartItem);
        }
        lstToBeUpdated.addAll(deliveryDateUpdateLIneMap.values());
        upsert lstToBeUpdated;
        return cartLst;
        
    }
    
    @AuraEnabled
    static public Boolean isCaliforniaStore(){
        return SignatureController.isCaliforniaStore();
    }
    
    public class ItemDetailsAPIException extends Exception {}
  
}