/****** v1 | Description: Methods for querying for ATC date info from components | 1/11/2018 | L OMeara */
public with sharing class EstimatedDeliveryDateController {
    @AuraEnabled    
    public static String getDatesFromZip(String postalCode, String sku, Integer quantity) {
        API_ATCClient.ATCPayload payLoad = new API_ATCClient.ATCPayload ();
        payLoad.country = 'US';
        payLoad.deliveryMode = 'Home';
        payLoad.postalCode = postalCode;
        payLoad.products.add(new API_ATCClient.ProductWrapper(sku, quantity));
        
        // get account number & shipto
        StoreInfoWrapper si = StoreInfo.getStoreInfo();
        List<String> fulfillerIdParts = si.fulfillerId.split('-');
        
        API_ATCClient.ATCResponseWrapper result = API_ATCClient.getAvailableDeliveryWindows(fulfillerIdParts.get(0), fulfillerIdParts.get(1), Date.Today(), Date.Today().addDays(30), payLoad);

        // NOTE - when i was returning the wrapper, the javascript side received an empty object
        return JSON.serialize(result);
    }
}