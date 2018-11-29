/* *******************************************************************************************************************
* Class Name   : CheckoutController
* Description  : Controller class for Checkout component to show addresses associated with an account to use it as 
				 shipping address and billing address  
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/06/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class CheckoutController {
    public static final String FINANCE_PMT_TYPE = 'Financing';
    public static final String PAYMENT_PROFILENAMESKEY  = 'ShowCheckoutTo';

	@AuraEnabled
    public List<CheckOutWrapper> addressList	{ get;set; }
    
    @AuraEnabled
    public List<CheckOutWrapper1> addressList1	{ get;set; }
    
    @AuraEnabled
    public CheckoutFormWrapper formWrap			{ get;set; }
    
    
    // REQ 444 - Added
    @AuraEnabled
    public Map<String, CheckoutFormWrapper> formWrapMap	{ get;set; }
    
     @AuraEnabled
    public String error { get;set; }
    
    
    @AuraEnabled
    public String acctNo { get;set; }
    @AuraEnabled
    public String RDC { get;set; } 
    @AuraEnabled
    public List<String> lstPhones	{ get;set; }
    @AuraEnabled
    public List<String> lstEmails	{ get;set; }
  
    @AuraEnabled
    public String shipPhone   { get;set; }
    @AuraEnabled
    public String shipEmail   { get;set; }
    @AuraEnabled
    public String billPhone   { get;set; }
    @AuraEnabled
    public String billEmail   { get;set; }
    @AuraEnabled
    public String billFirstName   { get;set; }
    @AuraEnabled
    public String billLastName   { get;set; }
    
    @AuraEnabled
    public String currShipAddr   { get;set; }
    @AuraEnabled
    public String currBillAddr   { get;set; }
    @AuraEnabled
    public Opportunity currOpp   { get;set; }
    @AuraEnabled 
    public StoreInfoWrapper storeInfoWrap {get;set;}
    @AuraEnabled
    public String entityName {get;set;} 
    
    // Method to get all addresses associated with the person account
    @AuraEnabled
    public static CheckoutController getAddresses(Id personAccId) {
        CheckoutController cntrl = new CheckoutController();
        cntrl.addressList = new List<CheckOutWrapper>();
        cntrl.addressList1 = new List<CheckOutWrapper1>();
        // REQ 444 - Added
        cntrl.formWrapMap = new Map<String, CheckoutFormWrapper>();
        
        cntrl.lstPhones = new List<String>();
        cntrl.lstEmails = new List<String>();
        
        for(Address__c addr : [SELECT Id,AccountId__c,Address_Line_1__c,Address_Line_2__c,City__c,State__c,Country__c,Zip_Code__c,Address_Type__c 
                               FROM Address__c 
                               WHERE AccountId__c = :personAccId
                               ORDER BY Preferred__c DESC, LastModifiedDate DESC]) {                                   
                                   String fullAddress;
                                   string fullAddress1;
                                   // REQ 444 - Added
                                   CheckoutFormWrapper frmWrpTemp = new CheckoutFormWrapper();
                                   if(addr.Address_Type__c != null){
                                   if(addr.Address_Type__c == 'Ship To'){
                                   if(addr.Address_Line_1__c != null) {
                                       fullAddress = addr.Address_Line_1__c;
                                       frmWrpTemp.shipAddr1 = addr.Address_Line_1__c;
                                   }
                                   if(fullAddress != null && addr.Address_Line_2__c != null) {
                                       fullAddress += ', '+addr.Address_Line_2__c;
                                       frmWrpTemp.shipAddr2 = addr.Address_Line_2__c;
                                   }
                                   if(fullAddress != null && addr.City__c != null) {
                                       fullAddress += ', '+addr.City__c;
                                       frmWrpTemp.shipCity = addr.City__c;
                                   } 
                                   
                                   if(fullAddress != null && addr.State__c != null) {
                                       fullAddress += ', '+addr.State__c;
                                       frmWrpTemp.shipState = addr.State__c;
                                   } 
                                   
                                   if(fullAddress != null && addr.Country__c != null) {
                                       fullAddress += ', '+addr.Country__c;                                      
                                   } 
                                   
                                   if(fullAddress != null && addr.Zip_Code__c != null) {
                                       fullAddress += ' '+addr.Zip_Code__c;
                                       frmWrpTemp.shipPostalCode = addr.Zip_Code__c;
                                   } 
                                     cntrl.addressList.add(new CheckOutWrapper(fullAddress,addr.Id));
                                   }
									
									// Bill Address
                                   if(addr.Address_Type__c == 'Bill To'){
                                   if(addr.Address_Line_1__c != null) {
                                       fullAddress1 = addr.Address_Line_1__c;
                                       frmWrpTemp.billAddr1 = addr.Address_Line_1__c;
                                   }
                                   if(fullAddress1 != null && addr.Address_Line_2__c != null) {
                                       fullAddress1 += ', '+addr.Address_Line_2__c;
                                       frmWrpTemp.billAddr2 = addr.Address_Line_2__c;
                                   }
                                   if(fullAddress1 != null && addr.City__c != null) {
                                       fullAddress1 += ', '+addr.City__c;
                                       frmWrpTemp.billCity = addr.City__c;
                                   } 
                                   
                                   if(fullAddress1 != null && addr.State__c != null) {
                                       fullAddress1 += ', '+addr.State__c;
                                       frmWrpTemp.billState = addr.State__c;
                                   } 
                                   
                                   if(fullAddress1 != null && addr.Country__c != null) {
                                       fullAddress1 += ', '+addr.Country__c;                                      
                                   } 
                                   
                                   if(fullAddress1 != null && addr.Zip_Code__c != null) {
                                       fullAddress1 += ' '+addr.Zip_Code__c;
                                       frmWrpTemp.billPostalCode = addr.Zip_Code__c;
                                   }
                                       cntrl.addressList1.add(new CheckOutWrapper1(fullAddress1,addr.Id)); 
                                 }
                                  cntrl.formWrapMap.put(addr.Id, frmWrpTemp);
                                 }      
                                   // REQ 444 - Added

                                   // DEF - 860 - Moved these lines to the end of this method
                                   /*cntrl.formWrap = new CheckoutFormWrapper();
                                   cntrl.formWrapMap.put('New', cntrl.formWrap);*/
								   // End of DEF - 860
                               }
        Opportunity opp = new Opportunity();
        try{
            opp = CreateSalesOrderHelper.getOpportunity(personAccId);
        }catch(Exception ex){
            System.debug('Unable to find cart for this guest.');
        }
        cntrl.currOpp = opp;
        
        cntrl.currShipAddr = opp.ShipTo_Address__c;
        cntrl.currBillAddr = opp.Bill_To_Address__c;
        cntrl.shipPhone = opp.Shipping_Phone__c;
      if(String.isNotBlank(opp.Shipping_Phone__c)){
        cntrl.lstPhones.add(opp.Shipping_Phone__c);
     }
        cntrl.shipEmail = opp.Shipping_Email__c;
       if(String.isNotBlank(opp.Shipping_Email__c)){
           cntrl.lstEmails.add(opp.Shipping_Email__c);
      }
        cntrl.billPhone = opp.Billing_Phone__c;
       if(String.isNotBlank(opp.Billing_Phone__c)){
           cntrl.lstPhones.add(opp.Billing_Phone__c);
        }
        cntrl.billEmail = opp.Billing_Email__c;
        if(String.isNotBlank(opp.Billing_Email__c)){
         //  cntrl.lstEmails.add(opp.Billing_Email__c);
       }
        
        cntrl.addressList.add(new CheckoutWrapper('Add a new address',''));
        cntrl.addressList1.add(new CheckoutWrapper1('Add a new address',''));
        
        List<Account> acc = [SELECT id, Phone,Phone_2__pc,Phone_3__pc, PersonEmail, Firstname, Lastname FROM account WHERE id=:personAccId];
        if(!acc.isEmpty()) {
        	cntrl.billFirstName = acc[0].Firstname;
            cntrl.billLastName = acc[0].Lastname;
            if(String.isNotBlank(acc[0].Phone)){
                cntrl.lstPhones.add(acc[0].Phone);
            }
            if(String.isNotBlank(acc[0].Phone_2__pc)){
                cntrl.lstPhones.add(acc[0].Phone_2__pc);
            }
            if(String.isNotBlank(acc[0].Phone_3__pc)){
                cntrl.lstPhones.add(acc[0].Phone_3__pc);
            }
            cntrl.lstPhones.add('Add New');
            
            if(String.isNotBlank(acc[0].PersonEmail)){
                cntrl.lstEmails.add(acc[0].PersonEmail);
            }
            cntrl.lstEmails.add('Add New');    
        }
		// DEF - 860 - formWrap should be initialized to hold Shipping Phone even if there are no addresses.
        cntrl.formWrap = new CheckoutFormWrapper();
        cntrl.formWrapMap.put('New', cntrl.formWrap);
        // End of DEF - 860
        return cntrl;
    }
 
    /*@AuraEnabled
    public static Account createAddList(Id personAccId, string newphone,string newemail){
    	Account acc= [select Id,Phone,PersonEmail FROM Account WHERE Id = :personAccId];
        acc.Phone = newphone;
    	acc.PersonEmail = newemail ;
        Update acc;
        system.debug('acc'+acc);
        Return acc;
    } */
   
    // Method to save new address
    @AuraEnabled
    public static CheckoutController createNewAddress(List<CheckOutWrapper> addressList,List<CheckOutWrapper1> addressList1, String formWrapStr, Boolean isShipping, String personAccId, String mapWrap) {
        CheckoutController cntrl = new CheckoutController();
        cntrl.formWrap = new CheckoutFormWrapper();
        cntrl.formWrapMap = new Map<String, CheckoutFormWrapper>();
        String addr1,addr2,city,state,zip,addtype;
        CheckoutFormWrapper formWrap = (CheckoutFormWrapper) JSON.deserialize(formWrapStr, CheckoutFormWrapper.class);	
        cntrl.formWrap = formWrap;
        Map<String,CheckoutFormWrapper> formWrapMap = (Map<String,CheckoutFormWrapper>)JSON.deserialize(mapWrap, Map<String,CheckoutFormWrapper>.class);
        cntrl.formWrapMap = formWrapMap;
        Address__c newAddr;
        try{
        if(isShipping == true) 
        {
            addr1 = formWrap.shipAddr1;
            addr2 = formWrap.shipAddr2;
            city = formWrap.shipCity;
            state = formWrap.shipState; 
            zip = formWrap.shipPostalCode;
            addtype = 'Ship To';
        }
        else 
        {
            addr1 = formWrap.billAddr1; 
            addr2 = formWrap.billAddr2;
            city = formWrap.billCity;
            state = formWrap.billState; 
            zip = formWrap.billPostalCode;
            addtype = 'Bill To';
        }
        List<Address__c> addrLst=[Select Id,AccountId__c,Address_Line_1__c,Address_Line_2__c,City__c,State__c,Zip_Code__c,Address_Type__c
                                  From Address__c
                                  Where AccountId__c=: personAccId and Address_Line_1__c =:addr1 and Address_Line_2__c =:addr2
                                  and City__c =:city and State__c =:state 
                                  and Zip_Code__c =:zip and Address_Type__c =:addtype];
        if(addrLst.isEmpty()){
            newAddr = new Address__c(AccountId__c = personAccId,
                                     Address_Line_1__c =addr1, Address_Line_2__c =addr2,
                                     City__c =city, State__c =state, 
                                     Zip_Code__c =zip,Address_Type__c =addtype);
            if(String.isNotBlank(formWrap.oldAddrId)){
                newAddr.id=formWrap.oldAddrId;
            }
            Upsert newAddr;
            cntrl.formWrap.newAddrId = newAddr.Id;
            cntrl.formWrap.oldAddrId = '';
            cntrl.formWrap.addressList = getAddresses(personAccId).addressList;
            cntrl.formWrap.addressList1 = getAddresses(personAccId).addressList1;
            cntrl.formWrapMap.put(newAddr.Id,cntrl.formWrap);
        }
        else{
            if(addrLst[0].Id == formWrap.oldAddrId){
                cntrl.formWrap.newAddrId = addrLst[0].Id;
                cntrl.formWrap.addressList = getAddresses(personAccId).addressList;
                cntrl.formWrap.addressList1 = getAddresses(personAccId).addressList1;
                cntrl.formWrapMap.put(addrLst[0].Id,cntrl.formWrap);
            }
            else{
                cntrl.error='Duplicate address found';
            }
            
        }
        }
        catch (Exception e) {
            system.debug('Exception is ' + e);
             throw new AuraHandledException(e.getMessage());
        }
        cntrl.formWrapMap = getAddresses(personAccId).formWrapMap;
        return cntrl;
       
    }
     
    
    // Performance issue fix - perform single update on opportunity instead of multiple updates
    // Update Shipping, Billing address, Cart item details and SalesGuid__c information on opportunity
    @AuraEnabled
    public static CheckoutFormWrapper updateAddressOnOpty(String formWrapStr, String personAccId, String billAddr, String shipAddr) {
    	
        CheckoutFormWrapper formWrap = (CheckoutFormWrapper) JSON.deserialize(formWrapStr, CheckoutFormWrapper.class);          
        Opportunity opp = CreateSalesOrderHelper.getOpportunity(personAccId);
        
        Address__c shipToAddr = new Address__c();
        Address__c billToAddr = new Address__c();
        for(Address__c addr : [Select Id,Address_Line_1__c,Address_Line_2__c,City__c,State__c,Zip_Code__c From Address__c Where Id = :shipAddr Or Id = :billAddr]) {
            if(addr.Id == shipAddr) {
                shipToAddr = addr;
            }    
            else {
                billToAddr = addr;
            }
        }
       
        ShoppingCartDeliveryWrapper shipDelivWrap = new ShoppingCartDeliveryWrapper();
        ShoppingCartAddressWrapper shipAddrWrap = new ShoppingCartAddressWrapper();
        shipAddrWrap.Address1 = shipToAddr.Address_Line_1__c;
        shipAddrWrap.Address2 = shipToAddr.Address_Line_2__c;
        shipAddrWrap.City = shipToAddr.City__c;
        shipAddrWrap.StateOrProvince = shipToAddr.State__c;
        shipAddrWrap.PostalCode = shipToAddr.Zip_Code__c;
        shipDelivWrap.Address = shipAddrWrap;
        
        ShoppingCartDeliveryWrapper billDelivWrap = new ShoppingCartDeliveryWrapper();
        ShoppingCartAddressWrapper billAddrWrap = new ShoppingCartAddressWrapper();
        billAddrWrap.Address1 = billToAddr.Address_Line_1__c;
        billAddrWrap.Address2 = billToAddr.Address_Line_2__c;
        billAddrWrap.City = billToAddr.City__c;
        billAddrWrap.StateOrProvince = billToAddr.State__c;
        billAddrWrap.PostalCode = billToAddr.Zip_Code__c;
        billDelivWrap.Address = billAddrWrap;
        
        // Payments Testing Fix
        ConciergePaymentItemDetailsHelper.ItemDetailsWrapper iWrapper = ConciergePaymentItemDetailsHelper.getItemDetails(personAccId,false,billDelivWrap,shipDelivWrap);
        if(iWrapper != null) {
            opp = iWrapper.oppt;
        }
        
        opp.Shipping_Phone__c = formWrap.shipPhone;
        opp.Shipping_Email__c = formWrap.shipEmail;
        opp.Billing_Phone__c = formWrap.billPhone;
        opp.Billing_Email__c = formWrap.billEmail;
        opp.ShipTo_Address__c = shipAddr;
        opp.Bill_To_Address__c = billAddr;
        
        // Update Phone field in opportunity when new address is used
        if(opp.Shipping_Phone__c != null 
           || opp.Billing_Phone__c != null
           || opp.Shipping_Email__c != null 
           || opp.Billing_Email__c != null
           || opp.ShipTo_Address__c != null
           || opp.Bill_To_Address__c != null) {
               try {
                   update opp;
               }
               catch(DMLException de) {
                   ErrorLogController.Log log = new ErrorLogController.Log('CheckoutController','updateOpptyAddress',de.getDMLMessage(0));
                   new ErrorLogController().createLog(log);
                   throw new AuraHandledException(de.getDMLMessage(0));
               }
           }
		   
		// DEF-0860
        Account acc = new Account();
        acc = [Select Id,Phone,Phone_2__pc,Phone_3__pc,Phone_Type__pc,Phone_2_Type__pc,Phone_3_Type__pc From Account Where Id = :personAccId][0];
        if(acc.Phone_Type__pc != null && acc.Phone_Type__pc.equals('Home') && acc.Phone == null) {
            acc.Phone = formWrap.shipPhone;
        } 
        else if(acc.Phone_2_Type__pc != null && acc.Phone_2_Type__pc.equals('Home') && acc.Phone_2__pc == null) {
            acc.Phone_2__pc = formWrap.shipPhone;
        }
        else if(acc.Phone_3_Type__pc != null && acc.Phone_3_Type__pc.equals('Home') && acc.Phone_3__pc == null ) {
            acc.Phone_3__pc = formWrap.shipPhone;
        }
        // DEF 860 - Default to 'Home' if none of the Phone types are 'Home'
        else {
                acc.Phone_Type__pc = 'Home';
           // acc.Phone = formWrap.shipPhone;
        }
        update acc;
        // End of DEF-0860
         
        return formWrap;	    
    }

    @AuraEnabled
    public static Map<String ,List<Shopping_cart_line_item__c>> getShoppingCartLineItems(String accountId){
        CheckoutController ctrl=new CheckoutController();
        
        
        Map<String ,List<Shopping_cart_line_item__c>> deliveryModeToItemMap= new Map<String ,List<Shopping_cart_line_item__c>>();
             
        for (Shopping_cart_line_item__c master : [Select Id,Product_Title__c, Product_SKU__c, Discount__c,DeliveryType__c,Discount_Price__c,DiscountType__c,isFutureDatedSale__c,
                                           Flat_Discounted_Amount__c,Last_Price__c,List_Price__c, Average_Cost__c, Quantity__c,
                                           Opportunity__c,Delivery_Mode__c,Opportunity__r.Cart_State__c,Opportunity__r.Cart_ZipCode__c,isCallItem__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c,DeliveryDate__c
                                           from  Shopping_cart_line_item__c where Opportunity__r.AccountId=:accountId 
                                            and Opportunity__r.StageName != 'Closed Won' 
                                            and Opportunity__r.StageName != 'Closed Lost' 
                                            and Opportunity__r.StageName != 'Sale Suspended'
                                            and Opportunity__r.createdDate = LAST_N_DAYS:30 ]) {
                                       
                                           if(!master.Product_SKU__c.startsWith('*')){
                                              List<Shopping_cart_line_item__c> shoppingDetail = new  List<Shopping_cart_line_item__c>();
                                               if(deliveryModeToItemMap.containsKey(master.Delivery_Mode__c)){
                                                   shoppingDetail=deliveryModeToItemMap.get(master.Delivery_Mode__c);
                                               }
                                               
                                               shoppingDetail.add(master);                                               
                                           	deliveryModeToItemMap.put(master.Delivery_Mode__c, shoppingDetail);
                                           }
                                           
                                       
                                   }
        
       
        return deliveryModeToItemMap;
    }
    
    @AuraEnabled
    public static Map<String ,List<Shopping_cart_line_item__c>> updateShoppingCartLineItems(String selectedDate,List<Shopping_cart_line_item__c> selectedItems,String accId)
    {
        
        Date deliveryDate=Date.valueOf(selectedDate);
        
        for(Shopping_cart_line_item__c item:selectedItems){
            item.DeliveryDate__c=deliveryDate;
            //REQ-451
            /*if(String.isNotBlank(deliveryNotes))
            {
                item.Delivery_Notes__c=deliveryNotes;
            }*/
            if(item.isCallItem__c == true){
                item.isCallItem__c=false;
            }
        }
        update selectedItems;
        
        //DEF-0562
        List<Shopping_cart_line_item__c> allHDLineItems=new List<Shopping_cart_line_item__c>();
        if(selectedItems[0].Delivery_Mode__c == 'HD')
        {
            
            for (Shopping_cart_line_item__c master : [Select Id, Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,isFutureDatedSale__c,
                                                      Flat_Discounted_Amount__c,Last_Price__c,List_Price__c, Average_Cost__c, Quantity__c,
                                                      Opportunity__c,Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c,DeliveryDate__c
                                                      from  Shopping_cart_line_item__c where Opportunity__c=:selectedItems[0].Opportunity__c and Delivery_Mode__c= 'HD'
                                                      and Opportunity__r.StageName != 'Closed Won' 
                                                      and Opportunity__r.StageName != 'Closed Lost' 
                                                      and Opportunity__r.StageName != 'Sale Suspended'
                                                      and Opportunity__r.createdDate = LAST_N_DAYS:30 ]) 
            {
                if(master.Product_SKU__c.startsWith('*'))
                {
                    master.DeliveryDate__c=selectedItems[0].DeliveryDate__c;
                    allHDLineItems.add(master);
                }
                
            }
            
            update allHDLineItems;
        }
        Map<String ,List<Shopping_cart_line_item__c>> deliveryModeToItemMap=CheckoutController.getShoppingCartLineItems(accId);
        return deliveryModeToItemMap;
    }
    
    // this should not need to be exposed to aura - and it does not appear to be used - please discuss 
    // with me - Lauren OMeara
    
    @AuraEnabled
    public static CheckoutController getStoreInfo(){
        CheckoutController ctrl=new CheckoutController();
        if(Test.isRunningTest()){
            ctrl.storeInfoWrap = new StoreInfoWrapper('8888300-164-23-SWF');          
        }else{            
            ctrl.storeInfoWrap = StoreInfo.getStoreInfo();
        }
        ctrl.acctNo=ctrl.storeInfoWrap.acctNo;
        ctrl.RDC =ctrl.storeInfoWrap.RDC;
        ctrl.entityName = ctrl.storeInfoWrap.legalEntityName;
        return ctrl;
    }
	 @AuraEnabled
     public Static Account updatePhone(Id PersonAccId,String Phonevalue,String Emailvalue) {
         Account acc=[Select Id,Phone,Phone_2__pc,Phone_3__pc, PersonEmail FROM Account WHERE Id=:PersonAccId];
         if(Phonevalue != null){
         if(acc.Phone == null){
             acc.Phone=Phonevalue;
         }
         else if(acc.Phone_2__pc == null){
             acc.Phone_2__pc=Phonevalue;
             
         }
          else if(acc.Phone_3__pc == null){
             acc.Phone_3__pc=Phonevalue;
         }
             
         }
         if(Emailvalue != null){
           acc.PersonEmail= Emailvalue; 
              
         }
             
             
         
         UPDATE acc;
         return acc;
         
     }
    
    @AuraEnabled
    public static Map<String ,List<Shopping_cart_line_item__c>> updateAsFutureDatedSale(List<Shopping_cart_line_item__c> selectedItems,String accId,Boolean bool)
    {
        
        
        //2049-09-09 delivery date for future dated sale
        Date deliveryDate=Date.valueOf(System.Label.FutureDatedSaleDate);
        
        if(bool == false){
            for(Shopping_cart_line_item__c item:selectedItems){
                item.isFutureDatedSale__c=false;
                item.DeliveryDate__c=null;
            }
        }
        else{
            for(Shopping_cart_line_item__c item:selectedItems){
                item.isFutureDatedSale__c=true;
                item.DeliveryDate__c=deliveryDate;
            }
        }
        update selectedItems;
        
        //DEF-0562
        List<Shopping_cart_line_item__c> allHDLineItems=new List<Shopping_cart_line_item__c>();
        if(selectedItems[0].Delivery_Mode__c == 'HD')
        {
            
            for (Shopping_cart_line_item__c master : [Select Id, Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,isFutureDatedSale__c,
                                                      Flat_Discounted_Amount__c,Last_Price__c,List_Price__c, Average_Cost__c, Quantity__c,
                                                      Opportunity__c,Opportunity__r.Cart_State__c,Opportunity__r.Cart_ZipCode__c,Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c,DeliveryDate__c
                                                      from  Shopping_cart_line_item__c where Opportunity__c=:selectedItems[0].Opportunity__c and Delivery_Mode__c= 'HD'
                                                      and Opportunity__r.StageName != 'Closed Won' 
                                                      and Opportunity__r.StageName != 'Closed Lost' 
                                                      and Opportunity__r.StageName != 'Sale Suspended'
                                                      and Opportunity__r.createdDate = LAST_N_DAYS:30 ]) 
            {
                if(master.Product_SKU__c.startsWith('*'))
                {
                    master.isFutureDatedSale__c=true;
                    master.DeliveryDate__c=selectedItems[0].DeliveryDate__c;
                    allHDLineItems.add(master);
                }
                
            }
            
            update allHDLineItems;
        }
        
        Map<String ,List<Shopping_cart_line_item__c>> deliveryModeToItemMap=CheckoutController.getShoppingCartLineItems(accId);
        return deliveryModeToItemMap;
    }
    
    
    @AuraEnabled
    public static Boolean suspendSales(String formWrapStr, String personAccId,String billAddr, String shipAddr){
        CheckoutFormWrapper formWrap = (CheckoutFormWrapper) JSON.deserialize(formWrapStr, CheckoutFormWrapper.class);  
     
        try{
        
            CreateSalesOrderHelper.CreateOrder(personAccId,true,billAddr,shipAddr,formWrap);
            //After Callout, maintain PaymentType, do the DML
            PaymentTypeHelper.maintainPaymentTypeMapping();
            Opportunity oppt = CreateSalesOrderHelper.getOpportunity(personAccId);
 
            //update opportunity
            oppt.StageName = 'Sale Suspended';
            oppt.ShipTo_Address__c = shipAddr;
            oppt.Bill_To_Address__c = billAddr;
            // saving the shipping and billing phone/email
            oppt.Shipping_Phone__c = formWrap.shipPhone;
            oppt.Shipping_Email__c = formWrap.shipEmail;
            oppt.Billing_Phone__c = formWrap.billPhone;
            oppt.Billing_Email__c = formWrap.billEmail;

            update oppt;
            
        }catch(AuraHandledException ae){
            throw ae;
        }catch(Exception e){
            ErrorLogController.Log log = new ErrorLogController.Log('CheckoutController','suspendSales',e.getMessage());
            new ErrorLogController().createLog(log);
            throw new AuraHandledException('Failed to Suspend Sales.');
        }
        return true;
    }

    @AuraEnabled
    public static SalesOrderResponseWrapper sendOrderToHome(String formWrapStr,String accountId, String billAddr, String shipAddr){
          CheckoutFormWrapper formWrap = (CheckoutFormWrapper) JSON.deserialize(formWrapStr, CheckoutFormWrapper.class);  
     	  SalesOrderResponseWrapper orderWrapper;	
        try{

            Opportunity oppt = CreateSalesOrderHelper.getOpportunity(accountId);
            orderWrapper = CreateSalesOrderHelper.CreateOrderInHome(accountId,billAddr,shipAddr,formWrap);
            String salesOrderNumber = ((SalesOrderResultWrapper)orderWrapper.salesOrderResult.get(0)).SalesOrderNumber;
            //After Callout, maintain PaymentType, do the DML
            PaymentTypeHelper.maintainPaymentTypeMapping();
            
            //update opportunity
            CreateSalesOrderHelper.saveShoppingCartLineItems(oppt.Id, salesOrderNumber);
            oppt.StageName = 'Closed Won';
            oppt.ShipTo_Address__c = shipAddr;
            oppt.Bill_To_Address__c = billAddr;
            update oppt;
            
        }catch(Exception e){
            system.debug('got exception ' + e.getMessage());
            ErrorLogController.Log log = new ErrorLogController.Log('CheckoutController','sendOrderToHome',e.getMessage());
            new ErrorLogController().createLog(log);
            throw new AuraHandledException('Failed to Create Order: ' + e.getMessage());
        }
        return orderWrapper;
    }
	
	@AuraEnabled
    public static boolean isDeliveryDatesChosen(String oppId,String notes){
        Boolean isDateSelected= true;
        List<Shopping_cart_line_item__c> lstSCartLineItems 
            = CreateSalesOrderHelper.getShoppingCartLineItems(oppId);
        for(Shopping_cart_line_item__c lineItem : lstSCartLineItems){
            if(lineItem.DeliveryDate__c == null && lineItem.isCallItem__c == false){
                isDateSelected= false;
            }
        }
        //REQ-451
        if(isDateSelected && String.IsNotBlank(notes))
        {
            Opportunity opp=[Select Id,Delivery_Notes__c from Opportunity where id=:oppId];
            if(opp != null){
               opp.Delivery_Notes__c= notes;
               update opp;
            }
            
            }
        return isDateSelected;
    }

    @AuraEnabled
    public static String SearchAddress(string searchTerm, string country, Integer take) {
        return EDQService.SearchAddress(searchTerm, country, take);
    }

    @AuraEnabled
    public static String FormatAddress(string formatUrl) {
        return EDQService.FormatAddress(formatUrl);
    }
	
    /*For a given delivery mode, if atleast one item is a "CALL" item, 
	then the ATC call needs to be made per item to identify which is(are) a CALL Item and which items have availability */
    @AuraEnabled
    public static Map<String ,List<Shopping_cart_line_item__c>> callItemCheck(String preferredDeliveryDate,List<Shopping_cart_line_item__c> selectedItems,String accId,String shipToAddr)
    {
        Date preferredDeliveryDateConverted = Date.valueOf(preferredDeliveryDate);	
		boolean isCallItemPresent = false;
        Delivery_Window__c windowSettings = Delivery_Window__c.getValues('Delivery Window');
        for(Shopping_cart_line_item__c lineItems:selectedItems){
            if(!lineItems.Product_SKU__c.startsWith('*')){
             API_ATCClient.ATCPayload  payload = new API_ATCClient.ATCPayload();
            
            if(lineItems.Delivery_Mode__c != null){
                payload.deliveryMode=lineItems.Delivery_Mode__c;
            }
            if(String.isBlank(payload.deliveryMode)){
                payload.deliveryMode = 'HD';
            }
            DeliveryWindowLookupController.updatePayloadWithOpenLineItemShipToAddress(payload, shipToAddr);
           
            payload.products.add(new API_ATCClient.ProductWrapper(lineItems.Product_SKU__c, Integer.valueOf(lineItems.Quantity__c)));
            CheckoutController ctrl=getStoreInfo();
            API_ATCClient.ATCResponseWrapper apiCallResponse = API_ATCClient.getAvailableDeliveryWindows(ctrl.acctNo, ctrl.RDC,preferredDeliveryDateConverted, preferredDeliveryDateConverted.addDays(Integer.valueOf(windowSettings.window__c)), payload);
                if(apiCallResponse.deliveryWindows.isEmpty()){
                    //update the call items field in shoppingcartLineitems object
                    if(lineItems.DeliveryDate__c != null){
                       lineItems.DeliveryDate__c= null; 
                    }
                    lineItems.isCallItem__c=true;
                    isCallItemPresent = true;
                }
                else{
                    
                    lineItems.isCallItem__c=false;
                }
                
            }
        }
		if(isCallItemPresent){
            Date callDate= date.today() + Integer.valueOf(windowSettings.window__c);
            for(Shopping_cart_line_item__c lineItem:selectedItems){
                    lineItem.DeliveryDate__c=callDate;
            }
        }
        update selectedItems;
        Map<String ,List<Shopping_cart_line_item__c>> deliveryModeToItemMap=CheckoutController.getShoppingCartLineItems(accId);
        return deliveryModeToItemMap;
    }
    
    
    @AuraEnabled
    public static Boolean saveDesiredDeliveryDate(String oppId, String selectedDesiredDate){
        try{
           
            System.debug(selectedDesiredDate);
            String[] dateArr = selectedDesiredDate.split('-');
            Opportunity opp=[Select Desired_Delivery_Date__c from Opportunity where Id=:oppId];
            
            opp.Desired_Delivery_Date__c =  Date.newInstance(Integer.valueOf(dateArr[0]), Integer.valueOf(dateArr[1]), Integer.valueOf(dateArr[2]));
            update opp;
            return true;
        }catch(DMLException ex){
            throw new AuraHandledException('Failed to save desired delivery date.');
        }
    }

    @AuraEnabled
    public static Opportunity getOpportunity(Id personAccId) {
        return CreateSalesOrderHelper.getOpportunity(personAccId);
    }  
    
}