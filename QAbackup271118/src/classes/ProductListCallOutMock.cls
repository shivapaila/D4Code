/* *******************************************************************************************************************
* Class Name   : ProductListCallOutMock
* Description  : Http Call Out Mock test class for Asheley Product Retail - Product Category ProductAbstract API .
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/20/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************///
@isTest
global class ProductListCallOutMock implements HttpCalloutMock {
    private String fetchType;
    /**
    * @description <Constructor to set apiType> 
    **/
    global ProductListCallOutMock(String apiType){
        this.fetchType = apiType;
    }
    
    /**
    * @description <Implement the interface HttpCalloutMock's respond method to return mock response>
    * @return <return is the Mocked JSON string or throw a CalloutException>
    **/
    global HTTPResponse respond(HTTPRequest req) {
        if(fetchType == 'CalloutExceptionTest'){
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Throw CalloutException Test. Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }else{
            system.debug(req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            CategoryProductListWrapper productList;
            
            if(fetchType == 'JSONExceptionTest'){
                res.setBody('Non JSON format String to make it throw JSONException when do the JSON Parse');
            }else if(fetchType == 'Unbxd'){
                List<ProductListFilterWrapper>  ProductListFilterWrappers = prepareUnbxdProductList();
                String bodyContent = JSON.serialize(ProductListFilterWrappers);
                res.setBody(bodyContent);
            }else{
                productList = prepareProductList();
                String bodyContent = JSON.serialize(productList);
                res.setBody(bodyContent);
            }
            res.setStatusCode(200);
            return res;
        }
    }


    /**
* @description <Simulate ProdcutList of one category Info>                                                       
* @return <Asserts return is the Mocked CategoryProductListWrapper object>
**/    
    public static CategoryProductListWrapper prepareProductList(){
        CategoryProductListWrapper productList = new CategoryProductListWrapper();
        
        productList.productList = new List<ProductWrapper>();
        //Category Id: AFHS-0225
        //product Id: 'B136-53','B428-58','B428-57'
        String[] pImageUrls= new String[]{'https://ashleyfurniture.scene7.com/is/image/AshleyFurniture/R099001-DETAIL-WEB',
            'https://ashleyfurniture.scene7.com/is/image/AshleyFurniture/R217002-SWATCH-WEB',
            'https://ashleyfurniture.scene7.com/is/image/AshleyFurniture/R217002-SWATCH-WEB'};
             String[] pIds  = new String[]{'W669-88','B136-53','B428-58'};
            for(Integer i=0; i<pIds.size();i++){
                
                ProductWrapper p1 =  new ProductWrapper();
                p1.sku = pIds[i];
                p1.productTitle = p1.sku+' Title name';
                p1.categoryId = 'AFHS-0225';
                p1.imageUrl = pImageUrls[i];
                p1.largeImageUrl = pImageUrls[i];
                SwatchesWrapper sw1 =  new SwatchesWrapper();
                sw1.sku =  p1.sku;
                sw1.color = 'red';
                SwatchesWrapper sw2 =  new SwatchesWrapper();
                sw2.sku =  p1.sku;
                sw2.color = 'green';
                p1.swatches = new List<SwatchesWrapper>{sw1,sw2};
                    productList.productList.add(p1);
            }
        return productList;
    }
    
      /**
* @description <Simulate ProdcutList of one category Info>                                                       
* @return <Asserts return is the Mocked CategoryProductListWrapper object>
**/    
    public static  List<ProductListFilterWrapper>  prepareUnbxdProductList(){        
         List<ProductListFilterWrapper>  productList = new List<ProductListFilterWrapper>();
      
        String[] pImageUrls= new String[]{'https://ashleyfurniture.scene7.com/is/image/AshleyFurniture/R099001-DETAIL-WEB',
            'https://ashleyfurniture.scene7.com/is/image/AshleyFurniture/R217002-SWATCH-WEB',
            'https://ashleyfurniture.scene7.com/is/image/AshleyFurniture/R217002-SWATCH-WEB'};
             String[] pIds  = new String[]{'W669-88','B136-53','B428-58'};
                 for(Integer i=0; i<pIds.size();i++){
                     
                     ProductListFilterWrapper p1 =  new ProductListFilterWrapper();
                     p1.id = pIds[i];
                     p1.sku = pIds[i];
                     p1.productTitle = p1.sku+' Title name';
                     p1.imageUrl = pImageUrls[i];
                     p1.swatchesimageUrl = pImageUrls;
                     p1.swatchesname = new String[]{'red','green','blue'};
                         productList.add(p1);
                 }
        return productList;
    }
}