public class ProductPriceCmpCtrl {
     /**
    * @description: get price information for one product                                                       
    * @param: productSKUId - product sku value
    * @return: ProductWrapper
    **/
    @AuraEnabled
    public static ProductPriceWrapper getProductPrice(String productSKUId) {  
        ProductPriceAPIHelper priceAPIHelper = new ProductPriceAPIHelper();
        String sourceURL = priceAPIHelper.getAPIEndpoint(productSKUId);
        
        String resJSON = priceAPIHelper.connectAPIGetJSON(sourceURL);
        
        ProductPriceWrapper priceInfo =  priceAPIHelper.parseJSONToProductPriceWrapper(resJSON);   
        if(priceInfo==null || priceInfo.ItemSku==null){
            throw new AuraHandledException('Get Error when calling Product Price API, please check the response for reason:'+resJSON);
        }
        return priceInfo;
        
    }   
    
   
     /**
    * @description: get ecomm price information for one product                                                       
    * @param: productSKUId - product sku value
    * @return: ProductWrapper
    **/
    @AuraEnabled
    public static ProductEcommWrapper getEcommPrice(String productSKUId) { 
        ProductPriceAPIHelper priceAPIHelper = new ProductPriceAPIHelper();
        return priceAPIHelper.getEcommPrice(productSKUId); 
    }

      //REQ-480 
    @AuraEnabled
    public static String[] getItemDetailInfo(String productSKUId){
        Map<String, SalesOrderLineWrapper> skuMap = getItemDetailInfoMap(productSKUId);
        if(skuMap==null){
            return null;
        }else{
            return new List<String>(skuMap.keySet());
        }
    }
    //DEF-0870 
    public static Map<String, SalesOrderLineWrapper> getItemDetailInfoMap(String productSKUId){
         List<Shopping_cart_line_item__c> cartLst= new List<Shopping_cart_line_item__c>();
        Shopping_cart_line_item__c lineItem =  new Shopping_cart_line_item__c();
        lineItem.Product_SKU__c = productSKUId;
        lineItem.Quantity__c =1;
        lineItem.Delivery_Mode__c = 'HD';
        cartLst.add(lineItem);
        //get product ItemType value for product
        ShoppingCartItemDetailsAPIHelper taxAPIHelper = new ShoppingCartItemDetailsAPIHelper();
        String sourceURL = taxAPIHelper.getAPIEndpoint();
        String rawPost = taxAPIHelper.prepareCartItemRawPostWithoutOpp(cartLst);
        String resJSON = taxAPIHelper.connectAPIPostJSON(sourceURL, rawPost);
        ShoppingCartResponseWrapper scwRes =  taxAPIHelper.parseJSONToShoppingCartWrapperList(resJSON);
        Map<String, SalesOrderLineWrapper> skuLineWrapperMap = new Map<String, SalesOrderLineWrapper>();
        Integer packageLineNumber;
        if(scwRes!=null && scwRes.SalesOrderLineList!=null && !scwRes.SalesOrderLineList.isEmpty()){          
            for(SalesOrderLineWrapper s: scwRes.SalesOrderLineList){
                if(s.ItemNumber==productSKUId){
                     skuLineWrapperMap.put(s.ItemNumber, s);//add productSKUId line itself
                    if(s.ItemType==1){//product is a package type product
                        packageLineNumber=s.PackageLineNumber;
                        break;
                    }
                }
                
            } 
            if(packageLineNumber!=null){
                for(SalesOrderLineWrapper s: scwRes.SalesOrderLineList){
                    if(s.PackageLineNumber==packageLineNumber && s.ItemType==2){
                        skuLineWrapperMap.put(s.ItemNumber, s);//add sub component of productSKUId
                    }
                } 
            }
        }else{
            return null;
        }
        return skuLineWrapperMap;
    }
}