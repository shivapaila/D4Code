public class salesOrderRouting
{
       
    @AuraEnabled
    public Static List<SORoutingItems> soRoutingData(String soID) 
    {
        SORoutingAuthorization sora = new SORoutingAuthorization();
        system.debug('SOId------routing-----'+ soID);
        SalesOrder__x so = new SalesOrder__x();
        if(Test.isRunningTest())
        {
            so = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                         ExternalId = '17331400:001q000000raDkvAAE',  
                                                         phhProfitcenter__c = 1234567,
                                                         Phhcustomerid__c = '784584585',
                                                         phhSalesOrder__c = '200442750',
                                                         phhStoreID__c = '133'
                                                         );
        }
        else
        {
            so = [Select Id, phhSalesOrder__c,phhStoreID__c,phhCustomerID__c, ExternalId from SalesOrder__x where Id=:soID];
        }
            system.debug('so-----------'+ so); 
        List<SORoutingItems> routingItems = new List<SORoutingItems>();
        String response;
        
        String accessTkn = sora.accessTokenData();   
        //system.debug('accessTkn-----------'+ accessTkn);
        //String SONum = '200442750';//so.phhSalesOrder__c;//'200442870';200442870 200403150
        String SONum = so.phhSalesOrder__c;
        String SONumEn = EncodingUtil.urlEncode(SONum, 'UTF-8');
        String strId = so.phhStoreID__c;//133
        Integer storeId = Integer.ValueOf(EncodingUtil.urlEncode(strId, 'UTF-8'));
         
        String test = 'SalesOrderNumber eq'+ ' ' + '\'' +SONumEn + '\'' +' '+'and StoreID eq'+' '+ storeId;
                               String x = test.replaceAll(' ','%20');
                                String tst1 = EncodingUtil.urlEncode(test, 'UTF-8');
        //system.debug('tes----'+ test);
        //system.debug('tes1-----'+ tst1);
        String test2 = tst1.replace('+','%20');
         //system.debug('test2---------------------------'+ test2);
        //String EPoint = 'https://test.cara.ashleyretail.com/odata/DTRouting?$filter=' + test2;
        String EPoint = System.Label.CaraSORoutingAPIEndPoint+'DTRouting?$filter=' + test2;
        EPoint=  Epoint.replace('+','%20');
        //String EPoint = ' https://cara-api-dev-slot1.azurewebsites.net/odata/DTRouting?$filter=SalesOrderNumber eq '+SONum +' and StoreID eq 133';
        system.debug('EPoint-----'+ EPoint);
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpResp = new HttpResponse();
        httpReq.setHeader('Authorization', 'Bearer '+accessTkn);
        httpReq.setEndpoint(EPoint);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setMethod('GET');  
        
        
        httpResp = http.send(httpReq); 
        //System.debug('httpResp-------Routing--------'+httpResp);
        //system.debug('httpResp-----'+httpResp);
        
        if (httpResp.getStatusCode() == 200) {
            
            response = httpResp.getBody(); 
            system.debug('response--RD---'+response);
            SORoutingWrapper soRouting = new SORoutingWrapper();
            
                soRouting = (SORoutingWrapper) JSON.deserialize(response, SORoutingWrapper.class);
            
                system.debug('soRouting----------'+soRouting);
            if(!soRouting.value.isEmpty()){
                
                List<SORoutingWrapper.value> SOValues = soRouting.value;
                    system.debug('SOValues----------------'+SOValues);
                List<SORoutingItems.SOLineItem> srItemsList = new List<SORoutingItems.SOLineItem>();                   
                for (SORoutingWrapper.value SOWrap: SOValues) {  
                    system.debug('SOWrap----------'+SOWrap);
                    system.debug('SOWrap.SOLineItems----------------'+SOWrap.SOLineItems);
                    
                    SORoutingItems sorObj = new SORoutingItems();  
                   
                    
                    sorObj.StoreID = SOWrap.StoreID ;
                    sorObj.SalesOrderNumber = SOWrap.SalesOrderNumber ;
                    sorObj.TransportationOrderID = SOWrap.TransportationOrderID ;
                    sorObj.IsConfirmed = SOWrap.IsConfirmed ;
                    sorObj.BegunTime = convertDatetimeToLocal(SOWrap.BegunTime) ;
                    sorObj.CompletedTime = convertDatetimeToLocal(SOWrap.CompletedTime) ;
                    sorObj.UserName = SOWrap.UserName ;
                    sorObj.RoutingPass = SOWrap.RoutingPass ;
                    sorObj.TimeChanged = SOWrap.TimeChanged ;
                    sorObj.ProfitCenter = SOWrap.ProfitCenter;
                    sorObj.DeliverDate  = SOWrap.DeliverDate;
                    sorObj.CustomerWindowOpen   = SOWrap.CustomerWindowOpen;
                    sorObj.CustomerWindowClose  = SOWrap.CustomerWindowClose;
                    sorObj.TruckID  = SOWrap.TruckID;
                    sorObj.SFPersonAccountID    = SOWrap.SFPersonAccountID;
                    //sorObj.UniqueID   = SOWrap.UniqueID;
                  // condatetime=string.valueOfGmt(SOWrap.ConfirmationDateTime);
                   sorObj.ConfirmationDateTime = SOWrap.ConfirmationDateTime;
                    sorObj.AccountShipTo = SOWrap.AccountShipTo;
                    //sorObj.SOLineItems = SOWrap.SOLineItems;
                    //for(Integer i=0; i<SOValues.size();i++){
                        for(Integer j=0; j<SOWrap.SOLineItems.size();j++){
                             SORoutingItems.SOLineItem srItems = new SORoutingItems.SOLineItem();
                             srItems.SKU = SOWrap.SOLineItems[j].SKU; 
                             srItems.ItemDescription = SOWrap.SOLineItems[j].ItemDescription;
                             srItems.Quantity = SOWrap.SOLineItems[j].Quantity;
                             srItemsList.add(srItems);
                            system.debug('sorOb--------'+srItemsList);
                        }
                    //}
                    system.debug('sorOb AGAIN--------'+srItemsList);
                    
                    sorObj.SOLineItems = srItemsList;
                    
                    routingItems.add(sorObj);
                }                
            }else{
                String errMsg='No records founds--';  
                AuraHandledException ex = new AuraHandledException(errMsg);
                return routingItems = null;
                //ex.setMessage(errMsg);
                //throw ex;
            }            
        }else{            
            String errMsg='Invalid Response. Error Code:'+httpResp.getStatusCode();
            AuraHandledException ex = new AuraHandledException(errMsg);
            return routingItems = null;
            //ex.setMessage(errMsg);
            //throw ex;
        }
        system.debug('routingItems------'+routingItems);        
        return routingItems;
    }
    
    @AuraEnabled
    public Static List<SORoutingItems.SOLineItem> soLineItemsData(String soNumber)
    //public Static String soLineItemsData(String soNumber)
    {
        SORoutingAuthorization sora = new SORoutingAuthorization();
        system.debug('soNumber-----------'+ soNumber);
        SalesOrder__x so = new SalesOrder__x();
        if(Test.isRunningTest())
        {
            so = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                         ExternalId = '17331400:001q000000raDkvAAE',  
                                                         phhProfitcenter__c = 1234567,
                                                         Phhcustomerid__c = '784584585',
                                                         phhSalesOrder__c = '200442750',
                                                         phhStoreID__c = '133'
                                                         );
        }
        else
        {
            so = [Select Id, phhSalesOrder__c,phhStoreID__c,phhCustomerID__c, ExternalId from SalesOrder__x where Id=:soNumber];
        }//system.debug('so-----------'+ so);  
        List<SORoutingItems> routingItems = new List<SORoutingItems>();
        List<SORoutingItems.SOLineItem> srItemsList = new List<SORoutingItems.SOLineItem>();  
        Map<String,List<SORoutingItems.SOLineItem>> srItemsListMap = new Map<String,List<SORoutingItems.SOLineItem>>();
                
        String response;
        
        String accessTkn = sora.accessTokenData();
        //system.debug('accessTkn-----------'+ accessTkn);
        //String SONum = '200442750';//so.phhSalesOrder__c;
        String SONum = so.phhSalesOrder__c;
        String SONumEn = EncodingUtil.urlEncode(SONum, 'UTF-8');
        String strId = so.phhStoreID__c;
        Integer storeId = Integer.ValueOf(EncodingUtil.urlEncode(strId, 'UTF-8')); 
         
        String test = 'SalesOrderNumber eq'+ ' ' + '\'' +SONumEn + '\'' +' '+'and StoreID eq'+' '+ storeId;
                               String x = test.replaceAll(' ','%20');
                                String tst1 = EncodingUtil.urlEncode(test, 'UTF-8');
        //system.debug('tes----'+ test);
        //system.debug('tes1-----'+ tst1);
        String test2 = tst1.replace('+','%20');
        //String EPoint = 'https://test.cara.ashleyretail.com/odata/DTRouting?$filter=' + test2;
        String EPoint = System.Label.CaraSORoutingAPIEndPoint+'DTRouting?$filter=' + test2;
        EPoint=  Epoint.replace('+','%20');
        //String EPoint = ' https://cara-api-dev-slot1.azurewebsites.net/odata/DTRouting?$filter=SalesOrderNumber eq '+SONum +' and StoreID eq 133';
        system.debug('EPoint-----'+ EPoint);
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpResp = new HttpResponse();
        httpReq.setHeader('Authorization', 'Bearer '+accessTkn);
        httpReq.setEndpoint(EPoint);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setMethod('GET');  
        
        
        httpResp = http.send(httpReq); 
        
        system.debug('httpResp---IL--'+httpResp);
        
        if (httpResp.getStatusCode() == 200) {
            
            response = httpResp.getBody(); 
            system.debug('response-----'+response);
            SORoutingWrapper soRouting = new SORoutingWrapper();
            soRouting = (SORoutingWrapper) JSON.deserialize(response, SORoutingWrapper.class);
            system.debug('soRouting----------'+soRouting);
            
            if(!soRouting.value.isEmpty()){
                
                List<SORoutingWrapper.value> SOValues = soRouting.value;
                    system.debug('SOValues----------------'+SOValues);
                for (SORoutingWrapper.value SOWrap: SOValues) {  
                    system.debug('SOWrap----------'+SOWrap); 
                    system.debug('SOWrap.SOLineItems----------------'+SOWrap.SOLineItems);
                    
                    SORoutingItems sorObj = new SORoutingItems();  
                    
                    
                    sorObj.StoreID = SOWrap.StoreID ;
                    sorObj.SalesOrderNumber = SOWrap.SalesOrderNumber ;
                    sorObj.TransportationOrderID = SOWrap.TransportationOrderID ;
                    sorObj.IsConfirmed = SOWrap.IsConfirmed ;
                    sorObj.BegunTime = convertDatetimeToLocal(SOWrap.BegunTime) ;
                    sorObj.CompletedTime = convertDatetimeToLocal(SOWrap.CompletedTime) ;
                    sorObj.UserName = SOWrap.UserName ;
                    sorObj.RoutingPass = SOWrap.RoutingPass ;
                    sorObj.TimeChanged = SOWrap.TimeChanged ; 
                    sorObj.ProfitCenter = SOWrap.ProfitCenter;
                    sorObj.DeliverDate  = SOWrap.DeliverDate;
                    sorObj.CustomerWindowOpen   = SOWrap.CustomerWindowOpen;
                    sorObj.CustomerWindowClose  = SOWrap.CustomerWindowClose;
                    sorObj.TruckID  = SOWrap.TruckID;
                    sorObj.SFPersonAccountID    = SOWrap.SFPersonAccountID;
                    //sorObj.UniqueID   = SOWrap.UniqueID;
                   // condatetime=string.valueOfGmt(SOWrap.ConfirmationDateTime);
                   sorObj.ConfirmationDateTime = SOWrap.ConfirmationDateTime;
                    sorObj.AccountShipTo = SOWrap.AccountShipTo;
                    //sorObj.SOLineItems = SOWrap.SOLineItems;
                    //for(Integer i=0; i<SOValues.size();i++){ 
                        for(Integer j=0; j<SOWrap.SOLineItems.size();j++){
                             SORoutingItems.SOLineItem srItems = new SORoutingItems.SOLineItem();
                             srItems.SKU = SOWrap.SOLineItems[j].SKU; 
                             srItems.ItemDescription = SOWrap.SOLineItems[j].ItemDescription;
                             srItems.Quantity = SOWrap.SOLineItems[j].Quantity;
                             srItemsList.add(srItems);
                            system.debug('sorOb--------'+srItemsList);  
                      }
                    //}
                    srItemsListMap.put(sorObj.SalesOrderNumber,srItemsList);
                    sorObj.SOLineItems = srItemsList;
                    system.debug('sorObj.SOLineItems----------------------'+sorObj.SOLineItems);
                    system.debug('sorObj----------------------'+sorObj);
                    routingItems.add(sorObj);
                }                
            }else{ 
                String errMsg='No records founds';
                AuraHandledException ex = new AuraHandledException(errMsg);
                ex.setMessage(errMsg);
                throw ex;
            }            
        }else{            
            String errMsg='Invalid Response. Error Code:'+httpResp.getStatusCode();
            AuraHandledException ex = new AuraHandledException(errMsg);
            ex.setMessage(errMsg);
            throw ex;
        }
        system.debug('routingItems------'+routingItems);
        //system.debug('routingItems[0]------'+routingItems[0]); 
       
        //return routingItems;  
        //return srItemsList;
        system.debug('routingItems------'+srItemsListMap.get(SONum));
        return srItemsListMap.get(SONum);     
        //return response; [0].SOLineItems
        
    }
    
     @AuraEnabled
    public Static List<SORoutingItems> soRoutingHistoryData(String soHID)
    {
        SORoutingAuthorization sora = new SORoutingAuthorization();
        system.debug('soHID------routing-----'+ soHID);
        //SalesOrder__x so = [Select Id, phhSalesOrder__c,phhStoreID__c, ExternalId from SalesOrder__x where Id=:soHID];
        SalesOrder__x so = new SalesOrder__x();
        if(Test.isRunningTest())
        {
            so = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                         ExternalId = '17331400:001q000000raDkvAAE',  
                                                         phhProfitcenter__c = 1234567,
                                                         Phhcustomerid__c = '784584585',
                                                         phhSalesOrder__c = '200442750',
                                                         phhStoreID__c = '133'
                                                         );
        }
        else
        {
            so = [Select Id, phhSalesOrder__c,phhStoreID__c,phhCustomerID__c, ExternalId from SalesOrder__x where Id=:soHID];
        }
         system.debug('so-----------'+ so); 
        List<SORoutingItems> routingItems = new List<SORoutingItems>();
        String response;
        
        String accessTkn = sora.accessTokenData();   
        system.debug('accessTkn-----------'+ accessTkn);
       // String SONum = '200406200';//'200442870';200442870 200403150, 200406200
        String SONum=so.phhSalesOrder__c;
        String SONumEn = EncodingUtil.urlEncode(SONum, 'UTF-8');
        String strId = so.phhStoreID__c;//133
        Integer storeId = Integer.ValueOf(EncodingUtil.urlEncode(strId, 'UTF-8'));
         
        String test = 'SalesOrderNumber eq'+ ' ' + '\'' +SONumEn + '\'' +' '+'and StoreID eq'+' '+ storeId;
                               String x = test.replaceAll(' ','%20');
                                String tst1 = EncodingUtil.urlEncode(test, 'UTF-8');
        system.debug('tes----'+ test);
        system.debug('tes1-----'+ tst1);
        String test2 = tst1.replace('+','%20');
         system.debug('test2---------------------------'+ test2);
        //String EPoint = 'https://test.cara.ashleyretail.com/odata/DTRoutingHistory?$filter=' + test2;
        String EPoint = System.Label.CaraSORoutingAPIEndPoint+'DTRoutingHistory?$filter=' + test2;
        EPoint=  Epoint.replace('+','%20');
        //String EPoint = ' https://cara-api-dev-slot1.azurewebsites.net/odata/DTRoutingHistory?$filter=SalesOrderNumber eq '+SONum +' and StoreID eq 133';
        system.debug('EPoint-----'+ EPoint);
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpResp = new HttpResponse();
        httpReq.setHeader('Authorization', 'Bearer '+accessTkn);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setMethod('GET');  
        httpReq.setEndpoint(EPoint);
        
        httpResp = http.send(httpReq); 
         System.debug('httpResp-------Hstry--------'+httpResp);
        if (httpResp.getStatusCode() == 200) {
            
            response = httpResp.getBody(); 
                system.debug('response-----'+response);
            SORoutingWrapper soRouting = new SORoutingWrapper();
            soRouting = (SORoutingWrapper) JSON.deserialize(response, SORoutingWrapper.class);
                system.debug('soRouting----------'+soRouting);
            if(!soRouting.value.isEmpty()){
                
                List<SORoutingWrapper.value> SOValues = soRouting.value;
                    system.debug('SOValues----------------'+SOValues);
                List<SORoutingItems.SOLineItem> srItemsList = new List<SORoutingItems.SOLineItem>();                   
                for (SORoutingWrapper.value SOWrap: SOValues) {  
                    system.debug('SOWrap----------'+SOWrap);
                    system.debug('SOWrap.SOLineItems----------------'+SOWrap.SOLineItems);
                    
                    SORoutingItems sorObj = new SORoutingItems();  
                    
                    
                    sorObj.StoreID = SOWrap.StoreID ;
                    sorObj.SalesOrderNumber = SOWrap.SalesOrderNumber ;
                    sorObj.TransportationOrderID = SOWrap.TransportationOrderID ;
                    sorObj.IsConfirmed = SOWrap.IsConfirmed ;
                    sorObj.BegunTime = convertDatetimeToLocal(SOWrap.BegunTime) ;
                    sorObj.CompletedTime = convertDatetimeToLocal(SOWrap.CompletedTime) ;
                    sorObj.UserName = SOWrap.UserName ;
                    sorObj.RoutingPass = SOWrap.RoutingPass ;
                    sorObj.TimeChanged = SOWrap.TimeChanged ;
                    sorObj.ProfitCenter = SOWrap.ProfitCenter;
                    sorObj.DeliverDate  = SOWrap.DeliverDate;
                    sorObj.CustomerWindowOpen   = SOWrap.CustomerWindowOpen;
                    sorObj.CustomerWindowClose  = SOWrap.CustomerWindowClose;
                    sorObj.TruckID  = SOWrap.TruckID;
                    sorObj.SFPersonAccountID    = SOWrap.SFPersonAccountID;
                    //sorObj.UniqueID   = SOWrap.UniqueID;
                  // condatetime=string.valueOfGmt(SOWrap.ConfirmationDateTime);
                   sorObj.ConfirmationDateTime = SOWrap.ConfirmationDateTime;
                    sorObj.AccountShipTo = SOWrap.AccountShipTo;
                    //sorObj.SOLineItems = SOWrap.SOLineItems;
                    //for(Integer i=0; i<SOValues.size();i++){
                        for(Integer j=0; j<SOWrap.SOLineItems.size();j++){
                             SORoutingItems.SOLineItem srItems = new SORoutingItems.SOLineItem();
                             srItems.SKU = SOWrap.SOLineItems[j].SKU; 
                             srItems.ItemDescription = SOWrap.SOLineItems[j].ItemDescription;
                             srItems.Quantity = SOWrap.SOLineItems[j].Quantity;
                             srItemsList.add(srItems);
                            system.debug('sorOb--------'+srItemsList);
                        }
                    //}
                    system.debug('sorOb AGAIN--------'+srItemsList);
                    
                    sorObj.SOLineItems = srItemsList;
                    
                    routingItems.add(sorObj);
                }                
            }else{
                String errMsg='No records found ++++';
                AuraHandledException ex = new AuraHandledException(errMsg);
                //ex.setMessage(errMsg);
                //throw ex;
                return null;
            }            
        }else{            
            String errMsg='Invalid Response. Error Code:'+httpResp.getStatusCode();
            AuraHandledException ex = new AuraHandledException(errMsg);
            //ex.setMessage(errMsg);
            //throw ex;
            return null;
        }   
        system.debug('routingItems--------History_data------------'+routingItems);
        return routingItems;
        
    }
    
     @AuraEnabled
    public Static List<SORoutingItems.SOLineItem> soLineItemHistoryData(String soHNumber)
    {
        SORoutingAuthorization sora = new SORoutingAuthorization();
        system.debug('soHID------routing-----'+ soHNumber);
        //SalesOrder__x so = [Select Id, phhSalesOrder__c,phhStoreID__c, ExternalId from SalesOrder__x where Id=:soHNumber];
        SalesOrder__x so = new SalesOrder__x();
        if(Test.isRunningTest())
        {
            so = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                         ExternalId = '17331400:001q000000raDkvAAE',  
                                                         phhProfitcenter__c = 1234567,
                                                         Phhcustomerid__c = '784584585',
                                                         phhSalesOrder__c = '200442750',
                                                         phhStoreID__c = '133'
                                                         );
        }
        else
        {
            so = [Select Id, phhSalesOrder__c,phhStoreID__c,phhCustomerID__c, ExternalId from SalesOrder__x where Id=:soHNumber];
        }
        // system.debug('so-----------'+ so); 
        List<SORoutingItems> routingItems = new List<SORoutingItems>();
        List<SORoutingItems.SOLineItem> srItemsList = new List<SORoutingItems.SOLineItem>(); 
        Map<String,List<SORoutingItems.SOLineItem>> srItemsListMap = new Map<String,List<SORoutingItems.SOLineItem>>();
        String response;
        
        String accessTkn = sora.accessTokenData();   
        system.debug('accessTkn-----------'+ accessTkn);
        String SONum = so.phhSalesOrder__c;//'200442870';200442870 200403150,'200406200'
        String SONumEn = EncodingUtil.urlEncode(SONum, 'UTF-8');
        String strId = so.phhStoreID__c;//133
        Integer storeId = Integer.ValueOf(EncodingUtil.urlEncode(strId, 'UTF-8'));
         
        String test = 'SalesOrderNumber eq'+ ' ' + '\'' +SONumEn + '\'' +' '+'and StoreID eq'+' '+ storeId;
                               String x = test.replaceAll(' ','%20');
                                String tst1 = EncodingUtil.urlEncode(test, 'UTF-8');
        system.debug('tes----'+ test);
        system.debug('tes1-----'+ tst1);
        String test2 = tst1.replace('+','%20');
         system.debug('test2---------------------------'+ test2);
        //String EPoint = 'https://test.cara.ashleyretail.com/odata/DTRoutingHistory?$filter=' + test2;
        String EPoint = System.Label.CaraSORoutingAPIEndPoint+'DTRoutingHistory?$filter=' + test2;
        EPoint=  Epoint.replace('+','%20');
        //String EPoint = ' https://cara-api-dev-slot1.azurewebsites.net/odata/DTRoutingHistory?$filter=SalesOrderNumber eq '+SONum +' and StoreID eq 133';
        system.debug('EPoint-----'+ EPoint);
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpResp = new HttpResponse();
        httpReq.setHeader('Authorization', 'Bearer '+accessTkn);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setMethod('GET');  
        httpReq.setEndpoint(EPoint);
        
        httpResp = http.send(httpReq); 
         System.debug('httpResp-------Hstry--------'+httpResp);
        if (httpResp.getStatusCode() == 200) {
            
            response = httpResp.getBody(); 
                system.debug('response-----'+response);
            SORoutingWrapper soRouting = new SORoutingWrapper();
            soRouting = (SORoutingWrapper) JSON.deserialize(response, SORoutingWrapper.class);
                system.debug('soRouting----------'+soRouting);
            if(!soRouting.value.isEmpty()){
                
                List<SORoutingWrapper.value> SOValues = soRouting.value;
                    system.debug('SOValues----------------'+SOValues);
                //List<SORoutingItems.SOLineItem> srItemsList = new List<SORoutingItems.SOLineItem>();                   
                for (SORoutingWrapper.value SOWrap: SOValues) {  
                    system.debug('SOWrap----------'+SOWrap);
                    system.debug('SOWrap.SOLineItems----------------'+SOWrap.SOLineItems);
                    
                    SORoutingItems sorObj = new SORoutingItems();  
                   
                    
                    sorObj.StoreID = SOWrap.StoreID ;
                    sorObj.SalesOrderNumber = SOWrap.SalesOrderNumber ;
                    sorObj.TransportationOrderID = SOWrap.TransportationOrderID ;
                    sorObj.IsConfirmed = SOWrap.IsConfirmed ;
                    sorObj.BegunTime = convertDatetimeToLocal(SOWrap.BegunTime) ;
                    sorObj.CompletedTime = convertDatetimeToLocal(SOWrap.CompletedTime) ;
                    sorObj.UserName = SOWrap.UserName ;
                    sorObj.RoutingPass = SOWrap.RoutingPass ;
                    sorObj.TimeChanged = SOWrap.TimeChanged ;
                    sorObj.ProfitCenter = SOWrap.ProfitCenter;
                    sorObj.DeliverDate  = SOWrap.DeliverDate;
                    sorObj.CustomerWindowOpen   = SOWrap.CustomerWindowOpen;
                    sorObj.CustomerWindowClose  = SOWrap.CustomerWindowClose;
                    sorObj.TruckID  = SOWrap.TruckID;
                    sorObj.SFPersonAccountID    = SOWrap.SFPersonAccountID;
                    //sorObj.UniqueID   = SOWrap.UniqueID;
                  // condatetime=string.valueOfGmt(SOWrap.ConfirmationDateTime);
                   sorObj.ConfirmationDateTime = SOWrap.ConfirmationDateTime;
                    sorObj.AccountShipTo = SOWrap.AccountShipTo;
                    //sorObj.SOLineItems = SOWrap.SOLineItems;
                    //for(Integer i=0; i<SOValues.size();i++){
                        for(Integer j=0; j<SOWrap.SOLineItems.size();j++){
                             SORoutingItems.SOLineItem srItems = new SORoutingItems.SOLineItem();
                             srItems.SKU = SOWrap.SOLineItems[j].SKU; 
                             srItems.ItemDescription = SOWrap.SOLineItems[j].ItemDescription;
                             srItems.Quantity = SOWrap.SOLineItems[j].Quantity;
                             srItemsList.add(srItems);
                            system.debug('sorOb--------'+srItemsList);
                        }
                    //}
                    system.debug('sorOb AGAIN--------'+srItemsList);
                    srItemsListMap.put(sorObj.SalesOrderNumber,srItemsList);
                    sorObj.SOLineItems = srItemsList;
                    
                    routingItems.add(sorObj);
                }                
            }else{
                String errMsg='No records found';
                AuraHandledException ex = new AuraHandledException(errMsg); 
                ex.setMessage(errMsg);
                throw ex;
            }            
        }else{            
            String errMsg='Invalid Response. Error Code:'+httpResp.getStatusCode();
            AuraHandledException ex = new AuraHandledException(errMsg);
            ex.setMessage(errMsg);
            throw ex;
        }   
        system.debug('routingItems--------History_data------------'+routingItems);
        //return routingItems;
        //return srItemsList;
        return srItemsListMap.get(SONum);
    }
    
   @AuraEnabled
    public Static List<SORoutingItems> soConfirmData(String sOrders,Integer rPass)
    {
        System.debug('sOrders----'+sOrders);
        System.debug('rPass----'+rPass);
        List<SORoutingItems> sOrderList = new List<SORoutingItems>();
        List<SORoutingItems> SOrderDataList = new List<SORoutingItems>();
        Map<Integer,SORoutingItems> srMap = new Map<Integer,SORoutingItems>();
        
        
        try
        {
            SORoutingItems sri = new SORoutingItems();
            if(!String.isBlank(sOrders)){
                sOrderList = (List<SORoutingItems>)JSON.deserialize(sOrders, List<SORoutingItems>.class);
            }
            
            for(SORoutingItems sr : sOrderList)
            {
                if(sr.RoutingPass == rPass)
                {
                    srMap.put(sr.RoutingPass,sr);
                } 
            }
            
            sri = srMap.get(rPass);
            User objUsr = [Select Id, Name, Alias,CommunityNickname from User where Id=:UserInfo.getUserId()];
            String currentUser = objUsr.CommunityNickname;//UserInfo.getLastName()+','+UserInfo.getFirstName();
            System.Debug('currentUser------' + currentUser);
            
             //SalesOrder__x so = [Select Id, phhSalesOrder__c,phhStoreID__c, ExternalId,phhProfitcenter__c,phhDatePromised__c from SalesOrder__x where Id=:soID];
             String EPoint = System.Label.AshleyApigeeEndpoint+sri.AccountShipTo+'/salesorders/'+sri.SalesOrderNumber+'/SalesOrderConfirmDelivery?profitcenter='+sri.ProfitCenter+'&ConfirmedFlag='+true+'&TruckId='+sri.TruckID+'&DeliverDate='+sri.DeliverDate+'&RoutingPass='+sri.RoutingPass+'&profitusername='+currentUser;
             //String EPoint = ' https://ashley-preprod-dev.apigee.net/homestores/8888300-164/salesorders/34007960/SalesOrderConfirmDelivery?profitcenter=34&ConfirmedFlag=true&TruckId=G1&DeliverDate=2016-11-03 00:00:00.000&RoutingPass=2&CustomerETAOpen=2016-11-03 14:15:00.000&CustomerETAClose=2016-11-03 18:25:00.000&profitusername=80009000';
            EPoint = EPoint.replace(' ','%20');
            String response;
            
            Http http = new Http();
            HttpRequest httpReq = new HttpRequest();
            HttpResponse httpResp = new HttpResponse();
            httpReq.setHeader('apikey',System.label.AshleyApigeeApiKey);
            //httpReq.setHeader('Authorization', 'Bearer '+accessTkn);
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setHeader('Accept' ,'application/json');
            httpReq.setMethod('PUT'); 
            httpReq.setTimeout(120000);
            httpReq.setBody('{}');
            httpReq.setEndpoint(EPoint);
            
            httpResp = http.send(httpReq); 
             System.debug('httpResp-------Hstry--------'+httpResp);
            if (httpResp.getStatusCode() == 200) {
                System.debug('httpResp-------Hstry--------'+httpResp.getBody());
                response = httpResp.getBody();
                System.debug('response--------'+response);
                if(response.contains('successfully'))
                {
                    for(SORoutingItems sr : sOrderList)
                    {   
                       System.debug('sr--------'+sr);                         
                        if(sr.RoutingPass == rPass)
                        {
                            SORoutingItems sOrd = new SORoutingItems();
                            Datetime condatetime;
                            
                            sOrd.StoreID = sr.StoreID;
                            sOrd.SalesOrderNumber = sr.SalesOrderNumber;
                            sOrd.TransportationOrderID = sr.TransportationOrderID;
                            sOrd.AccountShipTo = sr.AccountShipTo;
                            sOrd.BegunTime = sr.BegunTime;
                            sOrd.CompletedTime = sr.CompletedTime;
                            //condatetime = System.now();
                            //sOrd.ConfirmationDateTime = string.valueOfGmt(condatetime);
                            sOrd.CustomerWindowClose = sr.CustomerWindowClose;
                            sOrd.CustomerWindowOpen = sr.CustomerWindowOpen;
                            sOrd.DeliverDate = sr.DeliverDate;
                            sOrd.IsConfirmed = True;
                            sOrd.ProfitCenter = sr.ProfitCenter;
                            sOrd.RoutingPass = sr.RoutingPass;
                            sOrd.SFPersonAccountID = sr.SFPersonAccountID;
                            sOrd.TimeChanged = sr.TimeChanged;
                            sOrd.TransportationOrderID = sr.TransportationOrderID;
                            sOrd.TruckID = sr.TruckID;
                            //sOrd.UniqueID = sr.UniqueID;
                            //sOrd.UserName = sr.UserName;
                            sOrd.UserName = currentUser;
                            SOrderDataList.add(sOrd);
                        }
                        else
                        {
                            SOrderDataList.add(sr);
                        }
                    }
                    
                    system.debug('SOrderDataList--------'+SOrderDataList);
                    return SOrderDataList; 
                }
                                           
            }else{            
                //String errMsg='Invalid Response. Error Code:'+httpResp.getStatusCode();
                //AuraHandledException ex = new AuraHandledException(errMsg);
                //ex.setMessage(errMsg);
                //throw ex;
                return sOrderList;
            }
        }
        catch(Exception ex)
        {
            ErrorLog__c el = new ErrorLog__c();
            el.ApexClass__c = 'salesOrderRouting';
            el.Method__c = 'soConfirmData';
            el.Message__c = 'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString();
            
            insert el;
            System.debug('ex-------'+ex);
        }
        //system.debug('SOrderDataList--------'+SOrderDataList);
        return null;        
        
    }
    
    public Static String convertDatetimeToLocal(DateTime beDateTime)
    {
        Datetime thisDT = beDateTime;
        string stime=thisDT.format('hh:mm');
        system.debug('s3 value is----------- '+stime);
        return stime;
    }
}