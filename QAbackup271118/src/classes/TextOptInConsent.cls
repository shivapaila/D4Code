//REQ-455 - Text Opt In
public class TextOptInConsent {
    
    public static String textOptIn(){
        //String below to be replaced by the API method which will return the Entity Full Name to be displayed in the Custom Label
        StoreInfoWrapper storeInfoWrapperObj = StoreInfo.getStoreInfo();
        String textOptIn = storeInfoWrapperObj.legalEntityName;
        return textOptIn;
    }
}