public class Ashleydirectproductlineitem {
    public Id PLIId;
    public ProductLineItem__c PLI;
    public blob cryptoKey;
    public blob cryptoIV;
    public string algrType;

    public static final string MY_KEY = 'abcdefghijabcdef'; 
    public static final string MY_IV = '1234567890123456'; //it always will be 16 bytes

    public Ashleydirectproductlineitem(ApexPages.standardController con)
    {
        PLIId = ApexPages.currentPage().getParameters().get('Id');

        if(PLIId!= null)
        {
            PLI = [SELECT Id,Name,Sales_Order_Number__c,AckNo__c,Country__c,Case__r.AccountId,Case__r.Account.Name,Case__r.Account.phone,Item_SKU__c,Ashley_Direct_Link_ID__c,Fulfiller_ID__c,Address_Line1__c,Address_Line2__c,City__c,State__c,Zip__c FROM ProductLineItem__c WHERE Id=:PLIId];
        }
    }

    public pageReference openAD()
    {
        string strAddress1;
        string strAddress2;
        string strCity;
        string strState;
        string strZip;
        string strSOrder;
        string strAName;
        string strAPhone;
        string strISku;
        string strADLinkId;
        string strFFid;
        string strAckno;
        string strCtry;
        if(PLI.Address_Line1__c!=null)
            strAddress1 = encryptValue(PLI.Address_Line1__c);
        if(PLI.Address_Line2__c!=null)
            strAddress2 = encryptValue(PLI.Address_Line2__c);
        if(PLI.City__c!=null)
            strCity = encryptValue(PLI.City__c);
        if(PLI.State__c!=null)
            strState = encryptValue(PLI.State__c);
        if(PLI.Zip__c!=null)
            strZip = encryptValue(PLI.Zip__c);
        if(PLI.Sales_Order_Number__c!= null)
            strSOrder = encryptValue(PLI.Sales_Order_Number__c);
        if(PLI.Case__r.Account.Name!= null)
            strAName = encryptValue(PLI.Case__r.Account.Name);
        if(PLI.Case__r.Account.phone!=null)
            strAPhone = encryptValue(PLI.Case__r.Account.phone);
        if(PLI.Item_SKU__c!= null)
            strISku = encryptValue(formatSku(PLI.Item_SKU__c));
        if(PLI.Ashley_Direct_Link_ID__c != null)
            strADLinkId = encryptValue(PLI.Ashley_Direct_Link_ID__c);
        if(PLI.Fulfiller_ID__c != null)
            strFFid = encryptValue(PLI.Fulfiller_ID__c);
        if(PLI.AckNo__c != null)
            strAckno = encryptValue(PLI.AckNo__c);
        //if(PLI.Country__c != null)
            //strCtry = encryptValue(PLI.Country__c);
       // String adURL = 'https://stage.ashleydirect.com/Login/SignIn?url=/ReplacementsPartsOrderEntry_NET/Order.aspx?CN%3D{!URLENCODE(LEFT('+strFFid+', FIND("-", '+strFFid+') - 1))}%26SN%3D{!IF(CONTAINS('+strFFid+',"-"),URLENCODE(RIGHT('+strFFid+', LEN('+strFFid+') - FIND("-", '+strFFid+'))),"")}%26PN%3D{!URLENCODE('+strADLinkId+')}%26AC%3Dnew%26IT%3D{!URLENCODE('+strISku+')}%26NM%3D{!URLENCODE('+strAName+')}%26A1%3D{!URLENCODE('+strAddress2+')}%26A2%3D{!URLENCODE('+strAddress1+')}%26CY%3D{!URLENCODE('+strCity+')}%26ST%3D{!URLENCODE('+strState+')}%26ZP%3D{!URLENCODE('+strZip+')}%26PH%3D{!URLENCODE('+strAPhone+')}%26CT%3D{!URLENCODE('+strCtry+')}%26AK%3D{!URLENCODE('+strAckno+')}%26SARO%3D1{!URLENCODE('+strSOrder+')}%26decrypt%3Dtrue';
        string adURL = system.label.Ashley_Direct+ 'url=/ReplacementsPartsOrderEntry_NET/Order.aspx?CN%3D{!URLENCODE('+strFFid+')}%26PN%3D{!URLENCODE('+strADLinkId+')}%26AC%3Dnew%26IT%3D{!URLENCODE('+strISku+')}%26NM%3D{!URLENCODE('+strAName+')}%26A1%3D{!URLENCODE('+strAddress1+')}%26A2%3D{!URLENCODE('+strAddress2+')}%26CY%3D{!URLENCODE('+strCity+')}%26ST%3D{!URLENCODE('+strState+')}%26ZP%3D{!URLENCODE('+strZip+')}%26PH%3D{!URLENCODE('+strAPhone+')}%26CT%3DUSA%26AK%3D{!URLENCODE('+strAckno+')}%26SARO%3D{!URLENCODE('+strSOrder+')}%26decrypt%3Dtrue';
        PageReference pr = new PageReference(adURL);
        system.debug('Values in URL  '+adURL);
        return pr;
    }

     public static String cryptoGenerator () {
        /*crypto__c setting = crypto__c.getOrgDefaults();
        blob cryptoKey = Crypto.generateAesKey(128);
        setting.crypto__c =  EncodingUtil.base64Encode(cryptoKey);
        string valueForEncrypt = setting.crypto__c;
        system.debug('cryp' + EncodingUtil.base64Encode(cryptoKey));
        return valueForEncrypt;*/
        return null;
    }

    public String encryptValue(String valueforEncrypt){
        Encrypt_Data__c setting = Encrypt_Data__c.getInstance();//getValues('crypto__c');
        cryptoKey = blob.valueOf(setting.crypto__c);
        cryptoIV = blob.valueOf(setting.cryptoIV__c);
        algrType= setting.AlgorthemType__c;
        system.debug('setting-----'+setting.crypto__c);
        blob newcryptoKey256 = EncodingUtil.base64Decode(setting.crypto__c);
        system.debug('cryptoKey-----'+cryptoKey);
        blob data = Blob.valueOf(valueforEncrypt);
        blob encryptedData = Crypto.encryptWithManagedIV(algrType, newcryptoKey256, data );
        string encryptedValue = EncodingUtil.base64Encode(encryptedData);
        system.debug('encryptedValue: ' + encryptedValue);
        system.debug('iv: ' + EncodingUtil.base64Encode(Blob.valueOf(AshleyDirectLinkEncryption.MY_IV)));
        system.debug('key: ' + EncodingUtil.base64Encode(Blob.valueOf(AshleyDirectLinkEncryption.MY_KEY)));
        return encryptedValue;
    }

    public static string formatSku(String ipSku){
    	string opSku;
		if(ipSku != null)
        {
            string[] ItemNum1 = ipSku.split('[^0]*');
            integer i=0;
            for(i=0; i< ItemNum1.size(); i++){
                if(ItemNum1[i]=='') break;
                system.debug('Num1-->'+ItemNum1[i]);
                system.debug('\n');
            }
            system.debug('i-->'+i);
            opSku = ipSku.substring(i);
            opSku.trim();
            system.debug('opSku-->'+opSku);
		}
    	return opSku;
    }
}