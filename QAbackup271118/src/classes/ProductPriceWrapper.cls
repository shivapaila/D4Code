public class ProductPriceWrapper {
      /* Example response: 
<ImagePath>https://www.ashleydirect.com/graphics/AD_Images/D705-03.jpg</ImagePath>
<ItemDescription>Dining UPH Side Chair (2/CN)</ItemDescription>
<ItemSku>D705-03</ItemSku>
<NailedDamagedQty>0.00</NailedDamagedQty>
<OnOrderAvailableQty>0.00</OnOrderAvailableQty>
<OriginalPrice>200.00</OriginalPrice>
<SalePrice null="true"/>

*/
    @AuraEnabled
    public String ItemSku{get;set;} 
    
    @AuraEnabled
    public String ItemDescription{get;set;}    
    
    @AuraEnabled
    public decimal OriginalPrice{get;set;}    

    @AuraEnabled
    public decimal SalePrice{get;set;}    

    @AuraEnabled
    public String ImagePath{get;set;}    

    /* this is the quantity available in store */
    @AuraEnabled
    public decimal NailedDamagedQty{get;set;}

    /* this is the quantity available for order */ 
    @AuraEnabled
    public decimal OnHandAvailableQty{get;set;}
        
    // NOTE - commenting old field from old API - ljo 1/9/2018
    // leaving in code in case it is added back or reverted
    /*
    @AuraEnabled
    public decimal OnOrderAvailableQty{get;set;}    
	*/
    
}