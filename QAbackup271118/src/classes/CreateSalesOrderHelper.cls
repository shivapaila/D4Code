/**************************************************************************************************
* Name       : CreateSalesOrderHelper
* Purpose    : Helper class for Sending Sales Orders to HOMES
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Sridhar            | 1.0        | 2/20/2018       | Initial Draft
*Sridhar            | 1.0        | 2/25/2018       | Final Draft
**************************************************************************************************/
public class CreateSalesOrderHelper{

    private static final String SIGNATURE_TYPE_CUSTOMER_ORDER_ACCEPTANCE = 'Customer Order Acceptance';
    private static final String SIGNATURE_TYPE_TERMS_AND_CONDITIONS = 'Terms and Conditions';
    private static final String SIGNATURE_TYPE_OPT_INTO_TEXT_MESSAGES = 'Opt into text messages';

    private static final Map<String, String> SALES_ORDER_ATTRIBUTES_BY_SIGNATURE_TYPE 
                            = new Map<String, String>{
                                SIGNATURE_TYPE_CUSTOMER_ORDER_ACCEPTANCE => 'orderAcceptanceSignature' 
                                , SIGNATURE_TYPE_TERMS_AND_CONDITIONS => 'termsAndConditionSignature'
                                , SIGNATURE_TYPE_OPT_INTO_TEXT_MESSAGES => 'textConsentSignature'
                            };
    // CR Fixes - custom exception so parent controller aurahandled exception will throw the actual error in front end
    public class CreateOrderException extends Exception {}
    
    public static SalesOrderResponseWrapper CreateOrderInHome(Id referenceId, String billAddr, String shipAddr,
                                          CheckoutFormWrapper formWrap){        
        return CreateOrder(referenceId, false, billAddr, shipAddr, formWrap);
    }

    public static SalesOrderResponseWrapper CreateOrder(Id referenceId, Boolean suspendedSale,String billAddr, String shipAddr,
                                         CheckoutFormWrapper formWrap)
    {
        String shipPhone = formWrap.shipPhone;
        String billPhone = formWrap.billPhone;
        String shipEmail = formWrap.shipEmail;
        String billEmail = formWrap.billEmail;
        String billFirstName = formWrap.billFirstName;
        String billLastName = formWrap.billLastName;
        String shipFirstName = formWrap.shipFirstName;
        String shipLastName = formWrap.shipLastName;
        
        try{
        
        Opportunity oppt = CreateSalesOrderHelper.getOpportunity(referenceId);
        List<Shopping_cart_line_item__c> lineItems = getShoppingCartLineItems(oppt.Id);
        ShoppingCartDeliveryWrapper billToAddress= getAddress( referenceId, billAddr, billPhone, billEmail, billFirstName, billLastName);
        ShoppingCartDeliveryWrapper shipToAddress= getAddress( referenceId, shipAddr, shipPhone, shipEmail, shipFirstName, shipLastName);
        if(billToAddress==null || shipToAddress==null){
            // CR Fixes - custom exception so parent controller aurahandled exception will throw the actual error in front end
              throw new CreateOrderException('please set shipTo and billTo Address');
        }
      	ConciergePaymentItemDetailsHelper.ItemDetailsWrapper itemDetailWrapper =  ConciergePaymentItemDetailsHelper.getItemDetails(referenceId,false,billToAddress,shipToAddress); 
       
      
        StoreInfoWrapper storeInfo = getStoreInfo();
        if(lineItems.size() >0){
           /* ShoppingCartItemDetailsAPIHelper ItemAPI = new ShoppingCartItemDetailsAPIHelper();
            String sourceURL = ItemAPI.getAPIEndpoint();
            String rawData = ItemAPI.prepareCheckOutItemsRawPost(lineItems,referenceId,shipToAddress);
            String resJSON = ItemAPI.connectAPIPostJSON(sourceURL, rawData);
            System.debug('resJSON from ItemAPI---->'+resJSON);
            */
            Map<String, Object>  objMap = itemDetailWrapper.objectMap;
      /*      try{
                objMap =(Map<String, Object> ) JSON.deserializeUntyped(resJSON);
            }catch(Exception ex){
                  throw new AuraHandledException('Get Error when calling Tax API, please check the response for reason:'
                                                 +resJSON);
            }*/
            // Parameter should be SaleGuid for Place Order API
            Object saleGuid = objMap.get('CartGuid');
            objMap.remove('CartGuid');
            objMap.put('SaleGuid', saleGuid);

            objMap.put('SalesOrderLines', objMap.get('SalesOrderLineList'));
            objMap.remove('SalesOrderLineList');
            Decimal grandTotal = (Decimal) objMap.get('SalesGrandTotal');
            
            //REQ-454, customer desired delivery date
            objMap.put('CustomerDesiredDate',oppt.Desired_Delivery_Date__c);
            
            User currentUser = [Select RSA_ID__c, Email, LegalEntityName__c from user where Id = :UserInfo.getUserId()];
            objMap.put('RSAId',currentUser.RSA_ID__c);
            objMap.put('RsaEmailId', currentUser.Email);
            // DEF-0943 - Passing Legal entity name to Sales order api
            objMap.put('LegalEntityName', currentUser.LegalEntityName__c != null ? currentUser.LegalEntityName__c : '');
            //REQ-455 - Text Opt In
            objMap.put('SendSurvey', oppt.Text_Message_Opt_In__c);
            objMap.put('ProfitCenterID',storeInfo.profitCtr);
            //Adding commissions(REQ-430)
            List<OpportunitySplit> opptSplit=[Select id,OpportunityId,SplitOwner.RSA_ID__c,SplitPercentage
                                              From OpportunitySplit
                                              Where OpportunityId=:oppt.Id];
            List<CommissionWrapper> lstcommwrapper = new List<CommissionWrapper>();
            for(OpportunitySplit oppSplt:opptSplit)
            {
            CommissionWrapper commission =  new CommissionWrapper();
            commission.Percent=oppSplt.SplitPercentage;
            commission.SalespersonId=oppSplt.SplitOwner.RSA_ID__c;
            lstcommwrapper.add(commission);
            }
            //End(REQ-430)
            objMap.put('DefaultCommissionSplits', lstcommwrapper);
            //REQ-451
            if(String.isNotBlank(oppt.Delivery_Notes__c)){
            List<DeliveryNotesWrapper> delNoteWraper=new List<DeliveryNotesWrapper>();
            DeliveryNotesWrapper note=new DeliveryNotesWrapper();
            note.Note=oppt.Delivery_Notes__c;
            delNoteWraper.add(note);
            objMap.put('Notes',delNoteWraper);
            }
            
            objMap.put('BillTo',billtoAddress);
            objMap.put('ShipTo',shiptoAddress);
            //REQ-440

            
            
            if(suspendedSale){
                objMap.put('Payments',null);
                objMap.put('SuspendedSale',true);
            }else{
                PaymentsWrapper pw = getPayments(oppt.Id);
                system.debug('GOT PAYMENTS WRAPPER ' + pw);
                objMap.put('Payments',new List<PaymentsWrapper>{pw});
//Handle all signatures in one go
            objMap.putAll(getSignatures(referenceId, SALES_ORDER_ATTRIBUTES_BY_SIGNATURE_TYPE));
            }

            SalesCreateOrderAPIHelper coHelper = new SalesCreateOrderAPIHelper();
            String createOrderSourceURL = coHelper.getAPIEndpoint(referenceId);
            system.debug('Input :'+JSON.serialize(objMap));
            String salesorderResJSON = coHelper.connectAPIPostJSON(createOrderSourceURL, JSON.serialize(objMap));
            system.debug('-----salesorderResJSON-----'+salesorderResJSON);
            if(salesorderResJSON == null){
                // CR Fixes - custom exception so parent controller aurahandled exception will throw the actual error in front end
                throw new CreateOrderException('Get Error when calling create order API, please check the Error Log');
            }
            SalesOrderResponseWrapper orderWrapper = coHelper.parseJSONToSalesOrderResponseWrapper(salesorderResJSON);
            if(orderWrapper==null || (orderWrapper != null 
                && ((orderWrapper.eReceiptBlobStorageUri == null && !suspendedSale) || orderWrapper.salesOrderResult == null))){
                // CR Fixes - custom exception so parent controller aurahandled exception will throw the actual error in front end
                throw new CreateOrderException('Get Error when calling create order API, please check the response for reason:'
                                               +salesorderResJSON);
                	
            }
            //String SalesOrderNumber =((SalesOrderResultWrapper)orderWrapper.salesOrderResult.get(0)).SalesOrderNumber;
            //return SalesOrderNumber;
            return orderWrapper;
        }
              }catch(Exception ex){
                
            throw ex;

        }
        return null;
    }
    
    public static StoreInfoWrapper getStoreInfo(){
        StoreInfoWrapper si;
        if(Test.isRunningTest()){
            si = new StoreInfoWrapper('8888300-164-23-SWF');          
        }else{            
            si = StoreInfo.getStoreInfo();
        }
        return si;
    }
    public static Opportunity getOpportunity(Id guestId){
        Opportunity[] oppt = [SELECT Id, AccountId,ShipTo_Address__c,Bill_To_Address__c, StageName, 
                              Shipping_Phone__c, Billing_Phone__c,Billing_Email__c, Shipping_Email__c,
                              Billing_First_Name__c, Billing_Last_Name__c, Shipping_First_Name__c, 
                              Shipping_Last_Name__c,Desired_Delivery_Date__c,SalesGuid__c,Cart_Item_Details__c,
                              Survey_Opt_In__c, Text_Message_Opt_In__c, Declined_Survey_and_Text_Opt_In__c,Delivery_Notes__c
                              FROM Opportunity WHERE AccountId=:guestId 
                              and StageName != 'Closed Won' 
                              and StageName != 'Closed Lost'
                              and StageName != 'Sale Suspended'
                              AND createdDate=LAST_N_DAYS:30];        
        if (oppt.size() < 1) {
            throw new AuraHandledException('Unable to find cart for this guest.');
        }
        return oppt[0];
    }

    public static boolean saveShoppingCartLineItems(Id opptId, String SalesOrderNumber){ 
        // finance API defect fix
        List<Cart_Payment_Transaction__c> paymentTransList = [SELECT Transaction_Number__c, Payment_Type__c, Payment_Amount__c,ReferenceNumber__c,TermsCode__c ,Third_Party_Terms_Code__c, TenderCode__c, OrderNumber__c, isvoid__c 
                                                              FROM Cart_Payment_Transaction__c 
                                                              WHERE Opportunity__c = :opptId AND isvoid__c = false];        
        for(Cart_Payment_Transaction__c cartPaymentTrans : paymentTransList ){
            cartPaymentTrans.OrderNumber__c = SalesOrderNumber;
        }                                         
        if(paymentTransList.size() >0)
            update paymentTransList;                 
        return true;        
    }

    public static List<Shopping_cart_line_item__c> getShoppingCartLineItems(Id opptId){ 
        List<Shopping_cart_line_item__c> shoppingDetail = [SELECT Id,WarrantySku__c, Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,
                                           Flat_Discounted_Amount__c,Last_Price__c,List_Price__c, Average_Cost__c, Quantity__c,
                                           Opportunity__c,Delivery_Mode__c,DeliveryType__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c, Extended_Price__c, ItemType__c,
                                           DeliveryDate__c,As_Is__c,isCallItem__c
                                            FROM Shopping_cart_line_item__c
                                            WHERE Opportunity__c = :opptId];
                                      
        if(shoppingDetail.size() == 0){
            system.debug('Zero items found in cart: ' + opptId);
            throw new AuraHandledException('Unable to find any item.');
        }                              
        return shoppingDetail;        
    }


    public static PaymentsWrapper getPayments(Id opptId){
        // finance API defect fix
        List<Cart_Payment_Transaction__c> paymentTransList = [SELECT Transaction_Number__c, Payment_Type__c, Payment_Amount__c,ReferenceNumber__c,TermsCode__c , Third_Party_Terms_Code__c, TenderCode__c, isvoid__c, Check_DocumentNumber__c
                                                              FROM Cart_Payment_Transaction__c 
                                                              WHERE Opportunity__c = :opptId AND isvoid__c = false];
        if(paymentTransList.size() == 0){
            throw new AuraHandledException('No Payments found');
        }
        Map<String, Payment_Type__c> paymentTypeMapping = PaymentTypeHelper.getPaymentTypeMapping();
        if(paymentTypeMapping.isEmpty()){
            throw new AuraHandledException('Something wrong in System.');
        }
        PaymentsWrapper pmWrapper = new PaymentsWrapper();
        pmWrapper.PaymentDate = System.today();
        List<PaymentDistributionWrapper> pdWrapperList = new List<PaymentDistributionWrapper>();
        
        for(Cart_Payment_Transaction__c cartPaymentTrans : paymentTransList){
            PaymentDistributionWrapper pdWrapper = new PaymentDistributionWrapper();
            pdWrapper.Amount = cartPaymentTrans.Payment_Amount__c;
            // DEF-0893 - For financing payment, paymentreceived should be false
            pdWrapper.PaymentReceived = cartPaymentTrans.Payment_Type__c == MultiPaymentMethodsCtrl.FINANCE_PMT_TYPE ? false : true;
            pdWrapper.AuthorizationNumber = cartPaymentTrans.Transaction_Number__c;
            pdWrapper.ReferenceNumber = cartPaymentTrans.ReferenceNumber__c;
            /* Change in logic - should pickup TermsCode from Pay Terms API
            Payment_Type__c pt = new Payment_Type__c();
            if(cartPaymentTrans.Payment_Type__c == MultiPaymentMethodsCtrl.CASH_PMT_TYPE){
                pt = paymentTypeMapping.get('CSH');
                pdWrapper.TermsCode = pt.TenderCode__c;
            }else if(cartPaymentTrans.Payment_Type__c == MultiPaymentMethodsCtrl.CHECK_PMT_TYPE){
                pt = paymentTypeMapping.get('CHK');
                pdWrapper.TermsCode = pt.TenderCode__c;
            }else{
                List<API_PaymentType.PaymentTermWrapper> ptWrap = API_PaymentType.getPaymentTerm(cartPaymentTrans.TenderCode__c);
                if(ptWrap ==null || ptWrap.size() ==0){
                    throw new AuraHandledException('Unable to find Payment Type for ' + cartPaymentTrans.Payment_Type__c);
                }
                // finance API defect fix
                API_PaymentType.PaymentTermWrapper payTerm = findPaymentTerm(cartPaymentTrans.Third_Party_Terms_Code__c,ptWrap);
                if(payTerm ==null){
                    throw new AuraHandledException('Unable to find Payment Term for ' + cartPaymentTrans.Payment_Type__c);   
                }
                pdWrapper.TermsCode = payTerm.TermsCode;
                pt = paymentTypeMapping.get(cartPaymentTrans.TenderCode__c);
            }*/
            // Change in logic - should pickup TermsCode from Cart Payment Transaction
            Payment_Type__c pt = new Payment_Type__c();
            String tenderCode;
            if(cartPaymentTrans.Payment_Type__c == MultiPaymentMethodsCtrl.CASH_PMT_TYPE){
                pt = paymentTypeMapping.get('CSH');
            }
            else if(cartPaymentTrans.Payment_Type__c == MultiPaymentMethodsCtrl.CHECK_PMT_TYPE){
                pt = paymentTypeMapping.get('CHK');
            }
            else if(cartPaymentTrans.Payment_Type__c == MultiPaymentMethodsCtrl.FINANCE_PMT_TYPE
                    || cartPaymentTrans.Payment_Type__c == MultiPaymentMethodsCtrl.CC_PMT_TYPE) {
                pt = paymentTypeMapping.get(cartPaymentTrans.TenderCode__c);
            }
            pdWrapper.TermsCode = cartPaymentTrans.TermsCode__c;

            if(pt != null){
                pdWrapper.Code = pt.TenderCode__c;
                pdWrapper.Description = pt.TenderCodeDescription__c;
                if(cartPaymentTrans.Payment_Type__c == MultiPaymentMethodsCtrl.CHECK_PMT_TYPE){
                    pdWrapper.DocumentNumber = Integer.valueOf(pt.DocumentNumber__c+ String.valueOf(cartPaymentTrans.Check_DocumentNumber__c));
                }else{
                    pdWrapper.DocumentNumber = Integer.valueOf(pt.DocumentNumber__c);
                }
                pdWrapper.CashGroup = 0;
                pdWrapper.TermsDescription = pt.TenderCodeDescription__c;
            }else{
                throw new AuraHandledException('Unable to find Payment Type for ' + cartPaymentTrans.Payment_Type__c);
            }
            pdWrapperList.add(pdWrapper);
        }
        pmWrapper.Distributions = pdWrapperList;
        system.debug('building payment wrapper' + pmWrapper);
        return pmWrapper;
    }

    private static API_PaymentType.PaymentTermWrapper findPaymentTerm (String TermsCode, List<API_PaymentType.PaymentTermWrapper> ptWrap){
        if(ptWrap.size() ==1){
            return (API_PaymentType.PaymentTermWrapper)ptWrap.get(0);
        }
        for(API_PaymentType.PaymentTermWrapper payment : ptWrap){
            if(payment.TermsCode.equals(TermsCode)){
                return payment;
            }
        }
        return null;
    }

    public static  ShoppingCartDeliveryWrapper getAddress(String accId, Id addrId, String phone,
                                                          String email, String firstname, String lastname){
		Address__c add =[SELECT Id,AccountId__c,Address_Line_1__c,Address_Line_2__c,City__c,State__c,Country__c,Zip_Code__c 
                               FROM Address__c 
                               WHERE Id = :addrId];
        ShoppingCartDeliveryWrapper addressWrapper = new ShoppingCartDeliveryWrapper();
        addressWrapper.Address = new ShoppingCartAddressWrapper();
        addressWrapper.Address.Address1= add.Address_Line_1__c;
        addressWrapper.Address.Address2= add.Address_Line_2__c;
        addressWrapper.Address.City= add.City__c;
        addressWrapper.Address.PostalCode= add.Zip_Code__c;
        addressWrapper.Address.StateOrProvince= add.State__c;
        Account acc = [SELECT id, firstname, lastname, personMobilePhone, phone, personemail,
                       Phone_2__pc, Phone_3__pc FROM account WHERE id=:accId][0];
        
        if(String.isNotBlank(firstname) && String.isNotBlank(lastname)){
            addressWrapper.FirstName= firstname;
            addressWrapper.LastName= lastname;
        }else{
            addressWrapper.FirstName= acc.firstname;
            addressWrapper.LastName= acc.lastname;
        }
        addressWrapper.EmailAddress= String.isEmpty(email)? acc.personemail : email;
        addressWrapper.HomePhone= String.isEmpty(phone) ? acc.Phone : phone;
        //addressWrapper.CellPhone=acc.Phone_2__pc;   
        //addressWrapper.WorkPhone=acc.Phone_3__pc;                       
        return addressWrapper;

    }

    public static Map<String, Object> getSignatures(String accountId, Map<String, String> salesOrderAttributeBySignatureType){

        Map<String, Object> objMap = new Map<String, Object>();
        Set<String> signatureTypes = salesOrderAttributeBySignatureType.keySet();

        Map<String, Object> base64SignaturesBySignatureType = new Map<String, Object>();
        Map<String, Id> electronicSignatureIdsBySignatureType = new Map<String, String>();
        Map<String, Id> contentDocumentIdBySignatureType = new Map<String, String>();

        for (Electronic_Signature__c electronicSignature : [SELECT Id, AccountId__c, ObjectID__c, Signature_Type__c 
                                                            FROM Electronic_Signature__c 
                                                            WHERE AccountId__c = :accountId 
                                                            AND Signature_Type__c IN :signatureTypes
                                                            ORDER BY Signature_Date_Time__c DESC]){
            if (!electronicSignatureIdsBySignatureType.containsKey(electronicSignature.Signature_Type__c)){
                electronicSignatureIdsBySignatureType.put(electronicSignature.Signature_Type__c, electronicSignature.Id);
            }
        }
        List<Id> electronicSignatureIds = electronicSignatureIdsBySignatureType.values();
        for (ContentDocumentLink attachment :  [   SELECT Id, ContentDocumentId, LinkedEntityId 
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId IN :electronicSignatureIds]){
            String signatureType;
            for (String s : electronicSignatureIdsBySignatureType.keySet()){
                if (electronicSignatureIdsBySignatureType.get(s).equals(attachment.LinkedEntityId)){
                    signatureType = s;
                }
            }
            if (!contentDocumentIdBySignatureType.containsKey(signatureType)){
                contentDocumentIdBySignatureType.put(signatureType, attachment.ContentDocumentId);   
            }
        }
        List<Id> contentDocumentIds = contentDocumentIdBySignatureType.values();
        for (ContentVersion contentVersion :  [   SELECT Id, VersionData, ContentDocumentId 
                                                    FROM ContentVersion 
                                                    WHERE ContentDocumentId IN :contentDocumentIds]){
            String signatureType;
            for (String s : contentDocumentIdBySignatureType.keySet()){
                if (contentDocumentIdBySignatureType.get(s).equals(contentVersion.ContentDocumentId)){
                    signatureType = s;
                }
            }
            if (!base64SignaturesBySignatureType.containsKey(signatureType)){
                base64SignaturesBySignatureType.put(signatureType, contentVersion.VersionData);   
            }
        }        
        for (String signatureType : base64SignaturesBySignatureType.keySet()){
            objMap.put(salesOrderAttributeBySignatureType.get(signatureType), base64SignaturesBySignatureType.get(signatureType));
        }
        return objMap;
    }
}