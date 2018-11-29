public class ShoppingCartDiscountModalCtrl {
    public static final String DISCOUNT_PENDING_APPROVAL='Discount Pending Approval';
    public static final String NOT_APPLICABLE='Not Applicable';

    public class ShoppingCartDiscountModalCtrlException extends Exception {}
  
    @AuraEnabled  
    public static String saveDiscount
        (String lineItemId,
         String[] lineItemIdList, 
         Decimal percentDiscountAmount,
         String discountReasonCode,
         Id approverId) {
             System.debug(percentDiscountAmount);
        try{ 
             Set<String> choosedItems = new Set<String>();
             for(String itemId:lineItemIdList){
                 choosedItems.add(itemId);
             }
             Decimal marginCriteria = ShoppingCartDetailCmpCtrl.getRSAMarketDiscountThreshholds();
             if (marginCriteria==null || marginCriteria==0){
                throw new ShoppingCartDiscountModalCtrlException('Invalid discount threshold.');
             }
             
             //Get current Item   
             Shopping_cart_line_item__c currentLineItem =ShoppingCartLineItemCmpCtrl.getLineItemDetail(lineItemId);
             
             
             List<Shopping_cart_line_item__c> shoppingDetail = new  List<Shopping_cart_line_item__c>();
             List<Shopping_cart_line_item__c> needToApproveItems = new  List<Shopping_cart_line_item__c>();
             List<Opportunity> toUpdateOpps = new List<Opportunity>();
             //Get All items via current item's opportunity info                    
             for (Opportunity master : [Select Id, Discount__c, (Select Id, Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,
                                                Flat_Discounted_Amount__c,Last_Price__c, List_Price__c,Average_Cost__c,Quantity__c,
                                                Opportunity__c,Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c, 
                                                Discount_Approver__c,Discount_Approver__r.Name from  Shopping_cart_line_items__r) 
                                        From Opportunity where id = : currentLineItem.Opportunity__c]){
                                            for (Shopping_cart_line_item__c detail : master.Shopping_cart_line_items__r) {
                                                if(!Approval.isLocked(detail.Id) && !detail.Product_SKU__c.startsWith('*')){
                                                    
                                                    if(choosedItems.contains(detail.Id)){
                                                        detail.DiscountType__c = 'Percent';
                                                        Decimal averageCost = detail.Average_Cost__c;
                                                        Decimal originalPrice =  detail.List_Price__c;

                                                        averageCost = (averageCost!=null ? averageCost : 0);
                                                        originalPrice = (originalPrice!=null ? originalPrice : 0);
                                                        marginCriteria = (marginCriteria!=null ? marginCriteria : 0);
                                                        Decimal averageDiscountCriteria = 0;
                                                        if (averageCost != 0 && originalPrice != 0){
                                                            averageDiscountCriteria = (1-((averageCost*100)/(originalPrice*(100-marginCriteria))))*100;
                                                        }
                                                        
                                                        detail.Discount__c = percentDiscountAmount; 
                                                        
                                                        detail.Discount_Reason_Code__c = discountReasonCode;
                                                        Decimal itemDiscountPrice = detail.List_Price__c*(1-percentDiscountAmount/100);
                                                        if(percentDiscountAmount>0 
                                                           && percentDiscountAmount>averageDiscountCriteria
                                                           && (itemDiscountPrice.setScale(2, RoundingMode.HALF_UP) != detail.List_Price__c)){
                                                            needToApproveItems.add(detail);
                                                            detail.Discount_Status__c = DISCOUNT_PENDING_APPROVAL;
                                                            detail.Discount_Approver__c =  approverId;
                                                        }else{
                                                            detail.Discount_Status__c = NOT_APPLICABLE;
                                                        }
                                                        
                                                        shoppingDetail.add(detail);
                                                        
                                                    }
                                                }
                                            }
                                        }       
             
             //check whether discount need to approve
             update shoppingDetail;       
             requestApproveDiscount(needToApproveItems);
        } catch (Exception ex){
            System.debug(LoggingLevel.ERROR, 'Failed to save discount: '+ ex.getMessage());
            ErrorLogController.createLogFuture('ShoppingCartDiscountModalCtrl', 'saveDiscount', 'Failed to save discount: ' + ex.getMessage() +  ' Stack Trace: ' + ex.getStackTraceString() );         
            throw new AuraHandledException(ex.getMessage());
        }             
        return 'Success';
    }
    
    public static void requestApproveDiscount(List<Shopping_cart_line_item__c> lineItems){
        for(Shopping_cart_line_item__c lineItem: lineItems){
            Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
            psr.setComments('Submitting for approval.');
            psr.setObjectId(lineItem.id);
            psr.setSubmitterId( UserInfo.getUserId() ); 
            psr.setProcessDefinitionNameOrId('Discount_Approval_Process');
            psr.setSkipEntryCriteria(true); 
            psr.setNextApproverIds(new List<Id>{lineItem.Discount_Approver__c});
            try{
                Approval.ProcessResult result = Approval.process(psr);
                if(!result.isSuccess()){
                    new ErrorLogController().createLog(
                        new ErrorLogController.Log(
                            'ShoppingCartDiscountModalCtrl', 'requestApproveDiscount',
                            'Failed to request discount approval: ' + result.getErrors()
                        )
                    );          
                }
            }catch(Exception ex){
                new ErrorLogController().createLog(
                    new ErrorLogController.Log(
                        'ShoppingCartDiscountModalCtrl', 'requestApproveDiscount',
                        'Failed to request discount approval: ' + ex.getMessage() +
                        ' Stack Trace: ' + ex.getStackTraceString()
                    )
                );          
            }
        }
        
    }
}