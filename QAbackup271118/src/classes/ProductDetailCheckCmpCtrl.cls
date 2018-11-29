public class ProductDetailCheckCmpCtrl {
    
    @AuraEnabled
    public static ProductWrapper getProductDetail(String productSKUId) {  
        return ProductDetailCmpCtrl.getProductDetail(productSKUId);
    }
    
    @AuraEnabled
    public static ProductPriceWrapper getProductPrice(String productSKUId) {  
        return ProductPriceCmpCtrl.getProductPrice(productSKUId);
    }
}