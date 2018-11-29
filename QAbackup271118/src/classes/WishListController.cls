/* *******************************************************************************************************************
* Class Name   : WishListController
* Description  : Controller class for WishListCmp to show wishlist products associated with an account    
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/09/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class WishListController {

    // Get wishlist records using retail wishlist API
    @AuraEnabled
    public static List<WishListWrapper> getWishlist(String accountId) {
        //Get account email from account
  		List<Account> currentGuest = [SELECT PersonEmail,Id FROM Account WHERE Id = :accountId];
        
        if(!currentGuest.isEmpty()) {
            String sourceURL=Integration_Settings__c.getInstance('RetailAPIs').End_Point_URL__c + '/retail/wishlists/'+currentGuest[0].PersonEmail;
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type','application/json');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Connection','close');
            req.setHeader('apikey',Integration_Settings__c.getInstance('RetailAPIs').API_Key__c);
            req.setEndpoint(sourceURL);
            req.setMethod('GET');
            try{
                HttpResponse res = h.send(req);
                JSONParser parser = JSON.createParser(res.getBody());
                List<WishListApiWrapper> wishLst=(List<WishListApiWrapper>)parser.readValueAs(List<WishListApiWrapper>.class);
                String prodSourceURL = Integration_Settings__c.getInstance('RetailAPIs').End_Point_URL__c + '/productinformation/retail/products?sku=';
                Map<String,WishListProductWrapper> prodMap = new Map<String,WishListProductWrapper>(); 
                // Make API call for each of the wishlist product to get its image url
                for(WishListApiWrapper wishWrap : wishLst) {
                	Http htp = new Http();
                    HttpRequest prodReq = new HttpRequest();
                    prodReq.setHeader('Content-Type','application/json');
                    prodReq.setHeader('Accept', 'application/json');
                    prodReq.setHeader('Connection','close');
                    prodReq.setHeader('apikey',Integration_Settings__c.getInstance('RetailAPIs').API_Key__c);
                    prodReq.setEndpoint(prodSourceURL+wishWrap.sku);
                    prodReq.setMethod('GET');
                    HttpResponse prodRes = h.send(prodReq);
                    JSONParser prodParser = JSON.createParser(prodRes.getBody());
                    WishListProdApiWrapper prod = (WishListProdApiWrapper)prodParser.readValueAs(WishListProdApiWrapper.class);
                	prodMap.put(wishWrap.sku,prod.product);
                }
                List<WishListWrapper> wishWraplist = new List<WishListWrapper>();
                for(WishListApiWrapper wishApiWrap : wishLst) {
                    WishListWrapper wishWrap = new WishListWrapper(wishApiWrap.sku, wishApiWrap.productName,
                                                                   wishApiWrap.purchasedQuantity, wishApiWrap.quantity,
                                                                   prodMap.get(wishApiWrap.sku).eCommLargeImage,
                                                                   prodMap.get(wishApiWrap.sku).eCommSmallImage);
                	wishWraplist.add(wishWrap);
                }
                return wishWrapList;
            }
            catch(CalloutException ex){     
                System.debug(LoggingLevel.ERROR, 'Failed to Connect Ashely API:'+ex.getMessage());         
            }
        }
        return null;
    }
}