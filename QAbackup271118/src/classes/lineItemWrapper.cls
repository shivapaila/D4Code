public class lineItemWrapper {
        @AuraEnabled
        public Shopping_cart_line_item__c item {get;set;}
        
        @AuraEnabled
        public String msg {get;set;}
        
        @AuraEnabled
        public DateTime BestDate {get;set;}
        
         @AuraEnabled
        public Boolean isLocked {get;set;}
        
    	@AuraEnabled
        public Boolean isDiscountSelected {get;set;}
    
    	@AuraEnabled
        public Decimal averageDiscountCriteria {get;set;}
    }