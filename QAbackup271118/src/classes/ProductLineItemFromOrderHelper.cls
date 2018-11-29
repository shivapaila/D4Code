global class ProductLineItemFromOrderHelper {
    public boolean isvalidNum;
    public ProductLineItemFromOrderHelper(ApexPages.StandardController controller){
        
    }
    @AuraEnabled
    public static Boolean getSerialNumber(ID ProductLineItemId, String plsrNum){   
        string returnTxt;
        System.debug('My record ProductLineItemId'+ProductLineItemId);
        ProductLineItem__c record = [SELECT Id,Item_SKU__c,Item_Serial_Number__c 
                                     FROM ProductLineItem__c WHERE Id =:ProductLineItemId LIMIT 1];
        ID mynum = record.Id;
        // String PLSerialNum = record.Item_Serial_Number__c;
        String PLSerialNum;
        if(plsrNum != '')
            PLSerialNum = plsrNum;
        else
            PLSerialNum = '';
        String PLSKU = record.Item_SKU__c;
        
        //trim 0s
        String ItemNum = PLSKU;
        System.debug(ItemNum);
        String[] ItemNum1 = ItemNum.split('[^0]*'); 
        integer i=0;
        for(i=0; i< ItemNum1.size(); i++){
            if(ItemNum1[i]=='') break;
            System.debug('Num1-->'+ItemNum1[i]);
            System.debug('\n');
        }
        System.debug('i-->'+i);
        String s1 = ItemNum.substring(i);
        s1.trim();
        System.debug('s1-->'+s1);
        PLSKU = s1;
        
        System.debug('PLSerialNumfromedit' +PLSerialNum);
        System.debug('PLSKU' +PLSKU);
        Boolean isValid = true;
        // get Access token call
        ServiceReplacementPartsAuthorization replPart= new ServiceReplacementPartsAuthorization();
        String response;
        String accessTkn = replPart.accessTokenData();
        system.debug('accesstokenresponse' + accessTkn);
        //Send the request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(System.label.ReplacementPartSerialNumber+'/serialnumbers/validation?serialNumber='+PLSerialNum+'&itemNumber='+PLSKU);
        req.setMethod('GET');
        req.setHeader('Content-Type' ,'application/json;charset=utf-8');
        req.setHeader('Authorization', 'Bearer '+accessTkn);
        req.setHeader('apikey', System.label.TechSchedulingApiKey);
        string errMsg;
        Http http = new Http();
        HttpResponse res = http.send(req);
        // Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        System.debug('***Serial num Response Status: '+ res.getStatus());
        System.debug('***Serial num Response Body: '+ res.getBody());
        System.debug('***Serial num Response Status Code: '+ res.getStatusCode());
        Integer statusCode = res.getStatusCode();
        //Check the response
        System.debug('My Serial num entered--' +record.Item_Serial_Number__c);
        system.debug('body ' + res.getBody()); 
        
        if(statusCode == 200){
            if(res.getBody() =='false' && PLSerialNum!=null){
                System.debug('serial number not valid'+record);
                System.debug('mynum--> '+mynum);
                isValid = ProductLineItemFromOrderValidation.Validation('PLIH',mynum);
                System.debug('isValid--> '+isValid);
                return false;
            }
            else{
                System.debug('No Serial Number'+record);
                System.debug('mynum--> '+mynum);
                isValid = ProductLineItemFromOrderValidation.UpdateValidation('PLIH',mynum);
                System.debug('isValid--> '+isValid);
                System.debug('true'+record);
                return true;
            }
        }
        return true;
    }
    
    @AuraEnabled
    public static boolean check(){ 
        return true;
    }
    
    @AuraEnabled
    public static boolean getTrackingNumber(ID mynum, String FulfillerId, String PoNum){
        System.debug('My record ID' +mynum);
        ProductLineItem__c record = [SELECT Id,Part_Order_Number__c,Fulfiller_ID__c 
                                     FROM ProductLineItem__c Where ID =:mynum];
        String strTest = FulfillerId;
        System.debug(strTest);
        List<String> arrTest = strTest.split('\\-');
        String customerNumber = arrTest[0];
        String shipTo = arrTest[1];
        String PONumber = PoNum;
        System.debug(customerNumber);
        System.debug(shipTo);
        if((strTest != null || strTest != '') && (PONumber != null || PONumber != '' )){
            // get Access token call
            ServiceReplacementPartsAuthorization replParts= new ServiceReplacementPartsAuthorization();
            //  String response;
            String accessTkn = replParts.accessTokenData();
            system.debug('accesstokenresponse' + accessTkn);
            //Send API the request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(System.label.ReplacementPartSerialNumber+'/orders/status?customerNumber='+customerNumber+'&shipTo='+shipTo+'&poNumber='+PONumber);
            req.setMethod('GET');
            req.setHeader('Content-Type' ,'application/json;charset=utf-8');
            req.setHeader('Authorization', 'Bearer '+accessTkn);
            req.setHeader('apikey', System.label.TechSchedulingApiKey);
            string errMsg;
            Http http = new Http();
            HttpResponse res = http.send(req);
            // Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('***Tracking Number Response Status: '+ res.getStatus());
            System.debug('***Tracking Number Response Body: '+ res.getBody());
            System.debug('***Tracking Number Response Status Code: '+ res.getStatusCode());
            Integer statusCode = res.getStatusCode();
            //Check the response
            System.debug('My PO NUM entered--' +PoNum);
            System.debug('My FulfillerId entered--' +FulfillerId);
            system.debug('body ' + res.getBody()); 
            //POJSON.ExtDetail data = (POJSON.ExtDetail)JSON.deserialize(res.getBody(), POJSON.ExtDetail.class); 
            Type wrapperType = Type.forName('POJSON'); 
            POJSON data = (POJSON)JSON.deserialize(res.getBody(),wrapperType);
            System.debug('SO--->'+data.ExtDetail.Street);
            if(statusCode == 200){
                System.debug('Success');
                boolean isRes = ProductLineItemFromOrderValidation.updateTrackingNumber(mynum,data.ExtDetail.UPSTracking);
                if(isRes == true){
                    return true;
                }
                else{
                	return false;
                }
            }
            else{
                System.debug('FAILED');
                return false;
            }
        }
        return false;
    }
    
}