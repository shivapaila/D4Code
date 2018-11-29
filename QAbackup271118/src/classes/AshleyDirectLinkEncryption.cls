public class AshleyDirectLinkEncryption
{
    public Id cliId;
    public Case_Line_Item__c objCLI;
    
    public Blob cryptoKey;
    public Blob cryptoIV;
    public String algrType;
    
    public static final String MY_KEY = 'abcdefghijabcdef'; 
    public static final String MY_IV = '1234567890123456'; //it always will be 16 bytes

    public AshleyDirectLinkEncryption(ApexPages.standardController con)
    {
        //objCLI = (Case_Line_Item__c)con.getRecord(); 
        cliId = ApexPages.currentPage().getParameters().get('Id');
        
        if(cliId!= null)
        {
            objCLI = [Select Id,Name,Sales_Order_Number__c,Case__r.AccountId,Case__r.Account.Name,Case__r.Account.phone,Item_SKU__c,Ashley_Direct_Link_ID__c,Fulfiller_ID__c,Address_1__c,Address_2__c,City__c,State__c,Zip__c from Case_Line_Item__c where id=:cliId];
        } 
    }
    
    public pageReference openAD()
    {
        String strAddress1;
        String strAddress2;
        String strCity;
        String strState;
        String strZip;
        String strSOrder;
        String strAName;
        String strAPhone;
        String strISku;
        String strADLinkId;
        String strFFid;
        
        if(objCLI.Address_1__c!=null)
            strAddress1 = encryptValue(objCLI.Address_1__c);
        if(objCLI.Address_2__c!=null)
            strAddress2 = encryptValue(objCLI.Address_2__c);
        if(objCLI.City__c!=null)
            strCity = encryptValue(objCLI.City__c);
        if(objCLI.State__c!=null)
            strState = encryptValue(objCLI.State__c);
        if(objCLI.Zip__c!=null)
            strZip = encryptValue(objCLI.Zip__c);
        if(objCLI.Sales_Order_Number__c!= null)
            strSOrder = encryptValue(objCLI.Sales_Order_Number__c);
        if(objCLI.Case__r.Account.Name!= null)
            strAName = encryptValue(objCLI.Case__r.Account.Name);
        if(objCLI.Case__r.Account.phone!=null)
            strAPhone = encryptValue(objCLI.Case__r.Account.phone);
        if(objCLI.Item_SKU__c!= null)
            strISku = encryptValue(objCLI.Item_SKU__c);
        if(objCLI.Ashley_Direct_Link_ID__c != null)
            strADLinkId = encryptValue(objCLI.Ashley_Direct_Link_ID__c);
        if(objCLI.Fulfiller_ID__c != null)
            strFFid = encryptValue(objCLI.Fulfiller_ID__c);
        
        //decryptTest(strCity);
     //   String adURL = 'https://stage.ashleydirect.com/Login/SignIn?url=/ReplacementsPartsOrderEntry_NET/Order.aspx?CN%3D{!URLENCODE(LEFT('+strFFid+', FIND("-", '+strFFid+') - 1))}%26SN%3D{!IF(CONTAINS('+strFFid+',"-"),URLENCODE(RIGHT('+strFFid+', LEN('+strFFid+') - FIND("-", '+strFFid+'))),"")}%26AC%3Dnew%26IT%3D{!URLENCODE('+strFFid+')}%26PN%3D{!URLENCODE('+strADLinkId+')}%26AC%3Dnew%26IT%3D{!URLENCODE('+strISku+')}%26NM%3D{!URLENCODE('+strAName+')}%26A1%3D{!URLENCODE('+strAddress2+')}%26A2%3D{!URLENCODE('+strAddress1+')}%26CY%3D{!URLENCODE('+strCity+')}%26ST%3D{!URLENCODE('+strState+')}%26ZP%3D{!URLENCODE('+strZip+')}%26PH%3D{!URLENCODE('+strAPhone+')}%26CT%3DUSA%26AK%3D{!URLENCODE('+strSOrder+')}%26SARO%3D1%26decrypt%3Dtrue';
             String adURL = 'https://stage.ashleydirect.com/Login/SignIn?url=/ReplacementsPartsOrderEntry_NET/Order.aspx?CN%3D{!URLENCODE('+strFFid+')}%26PN%3D{!URLENCODE('+strADLinkId+')}%26AC%3Dnew%26IT%3D{!URLENCODE('+strISku+')}%26NM%3D{!URLENCODE('+strAName+')}%26A1%3D{!URLENCODE('+strAddress2+')}%26A2%3D{!URLENCODE('+strAddress1+')}%26CY%3D{!URLENCODE('+strCity+')}%26ST%3D{!URLENCODE('+strState+')}%26ZP%3D{!URLENCODE('+strZip+')}%26PH%3D{!URLENCODE('+strAPhone+')}%26CT%3DUSA%26AK%3D{!URLENCODE('+strSOrder+')}%26SARO%3D1%26decrypt%3Dtrue';
        system.debug('url' + adURL);
        PageReference pr = new PageReference(adURL);
        
        return pr;
    }
    
    
    
    public String encryptValue(String valueforEncrypt){
         
         Encrypt_Data__c setting = Encrypt_Data__c.getInstance();//getValues('crypto__c');
         cryptoKey = Blob.valueOf(setting.crypto__c);
         cryptoIV = Blob.valueOf(setting.cryptoIV__c);
         algrType= setting.AlgorthemType__c;
         system.debug('setting-----'+setting.crypto__c);
        Blob newcryptoKey256 = EncodingUtil.base64Decode(setting.crypto__c);
         system.debug('cryptoKey-----'+cryptoKey);
         Blob data = Blob.valueOf(valueforEncrypt);
         Blob encryptedData = Crypto.encryptWithManagedIV(algrType, newcryptoKey256, data );
         String encryptedValue = EncodingUtil.base64Encode(encryptedData);
         System.debug('encryptedValue: ' + encryptedValue);
         System.debug('iv: ' + EncodingUtil.base64Encode(Blob.valueOf(AshleyDirectLinkEncryption.MY_IV)));
         System.debug('key: ' + EncodingUtil.base64Encode(Blob.valueOf(AshleyDirectLinkEncryption.MY_KEY)));
         
         return encryptedValue; 
    }
    
   

}