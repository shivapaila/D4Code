/**
* This is a controller class for DeliveryWindowLookup Lightning component that provides ability to select a new Delivery date for an order/order Item by making
* an  API call out to the ATC(Available to Client) API. 
*/
public with sharing class DeliveryWindowLookupController {
    public static final string DEFAULT_DELIVERY_MODE = 'homex';
    public static final String ATC_CALL_DAYS_API_SETTING_NAME = 'ATC_CALL_DAYS API';
   	public static final String PATH_SETTING_NAME = 'ProductAPISetting';
    public class ATC_CALL_DAYS_APIException extends Exception {}
    
    public class MonthWrapper implements Attributable{
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public Integer index {get;set;}
        @AuraEnabled
        public boolean isFirst {get;set;}
        @AuraEnabled
        public boolean isCurrentSeletedDateMonth {get;set;}
        @AuraEnabled
        public boolean isLast {get;set;}
        @AuraEnabled
        public List<List<DateWrapper>> weeks {get;set;}
        
   
        
        public MonthWrapper(){
            weeks = new List<List<DateWrapper>>();   
            isFirst = false;
            isLast = false;
        }
        
    } 
    
    public class DateWrapper implements Attributable{
        @AuraEnabled
        public Date d {get;set;}
        @AuraEnabled
        public boolean availableForDelivery {get;set;}
        @AuraEnabled
        public boolean dateIsInCurrentMonth {get;set;}
        @AuraEnabled
        public string dateStringForDisplay {get;set;}
        @AuraEnabled
        public String dayofweek {get;set;}
       
        
        
        public DateWrapper(Date d){
            this.d = d;
            availableForDelivery = false;
            dateIsInCurrentMonth = false;
        }
    }
    public class TMonthWrapper implements Attributable{
        @AuraEnabled
        public string Tname {get;set;}
        @AuraEnabled
        public Integer Tindex {get;set;}
        @AuraEnabled
        public boolean TisFirst {get;set;}
        @AuraEnabled
        public boolean TisCurrentSeletedDateMonth {get;set;}
        @AuraEnabled
        public boolean TisLast {get;set;}
        @AuraEnabled
        
        public List<List<DateWrappethresholdr>> thresholdweeks {get;set;}
   
        
        public TMonthWrapper(){
            
            thresholdweeks = new List<List<DateWrappethresholdr>>();
            TisFirst = false;
            TisLast = false;
        }
        
    } 
    
    //Added by praneeth starts
       
    public class DateWrappethresholdr implements Attributable{
        @AuraEnabled
        public Date da {get;set;}
        @AuraEnabled
        public boolean ATCdates {get;set;}
        @AuraEnabled
        public boolean TavailableForDelivery {get;set;}
         @AuraEnabled
        public boolean TNopastdays {get;set;}
        @AuraEnabled
        public boolean TdateIsInCurrentMonth {get;set;}
        @AuraEnabled
        public string TdateStringForDisplay {get;set;}
        @AuraEnabled
        public String Tdayofweek {get;set;}
       
       
        
        
        public DateWrappethresholdr(Date da){
            this.da = da;
            TavailableForDelivery = false;
            TdateIsInCurrentMonth = false;
            TNopastdays = false;
            ATCdates = false;
        }
    }
    
    //end
    
    public class DeliveryCalendarResponse implements Attributable{
        @AuraEnabled
        public DeliveryCalendar calendar {get;set;}
        @AuraEnabled
        public boolean isSuccess {get;set;}
        @AuraEnabled
        public string message {get;set;} 
    }
    
    public class DeliveryCalendar implements Attributable{
        @AuraEnabled
        public List<MonthWrapper>  months {get;set;}
        
        @AuraEnabled
        public List<TMonthWrapper>  Tmonths {get;set;}
        
        @AuraEnabled
        public List<String> weekDayNames {get;set;}
    }
    
    /**
* Method gets a calendar that contains available delivery dates for a shipping address, deleivery mode and a set of products  
* Day names will be short hand names like Mon, Tue etc...
*
* @param  preferredDeliveryDate the delivery date requested by the customer, delivery dates arround this preferred date will be presened for choice
* @param  orderId the external id of the sales order
* @param  orderLineID the external id of the sales order line
* @param  accountNumber the account number of the fullfillment entity
* @param  rdcId the rdcId of the fullfillment entity
*
* @return a response that indicates the success/failure of the call, a calendar if the call was successful and a message in case of Failures 
*/
    @AuraEnabled	
    public static DeliveryCalendarResponse getDeliveryCalendarDays(string preferredDeliveryDate, string orderId, string orderLineID, string accountNumber, string rdcId, string shipToAddr){ 
        DeliveryCalendarResponse callResponse = new DeliveryCalendarResponse();
        String orderObjectTypeStr,orderLineObjectTypeStr;
         Integer window;
        API_ATCClient.ATCPayload  payload = new API_ATCClient.ATCPayload();
        try{			
            
            Date preferredDeliveryDateCoverted = Date.valueOf(preferredDeliveryDate);	
            system.debug('preferredDeliveryDate--'+preferredDeliveryDate);
            system.debug('preferredDeliveryDateCoverted--'+preferredDeliveryDateCoverted);
            //get delivery type code to delivery mode map
            Map<string,string> deliveryCodeTYpeToDeliveryModeMap = UpdateSalesOrderController.getDeliveryCodeTYpeToDeliveryModeMap();
            //checking object name using Id prefix
            
            if(orderId != null)
            {
                Schema.SObjectType orderObjectType=ManageObjects.getSobjectTypeByPrefix(orderId.substring(0, 3));
                orderObjectTypeStr=String.valueOf(orderObjectType);
            }
            else if(orderLineID != null)
            {
                Schema.SObjectType orderLineObjectType=ManageObjects.getSobjectTypeByPrefix(orderLineID.substring(0, 3));
                orderLineObjectTypeStr=String.valueOf(orderLineObjectType);   
            }
            // using internal opportunity and Shopping_cart_line_item__c @theyagu
            if(orderObjectTypeStr == 'Opportunity' || orderLineObjectTypeStr == 'Shopping_cart_line_item__c')
            {
                system.debug('in concierge code');
                //Opportunity order = SalesOrderDAO.getOrderByExternalId(orderId);					
                
                List<Shopping_cart_line_item__c> lineItems=new List<Shopping_cart_line_item__c>();
                if(orderLineID != null){
                    Shopping_cart_line_item__c item =[Select Id,Product_SKU__c,Opportunity__r.Cart_State__c,Opportunity__r.Cart_ZipCode__c,Quantity__c,DeliveryDate__c,Delivery_Mode__c,DeliveryType__c,Opportunity__c
                                                      From Shopping_cart_line_item__c 
                                                      where Id =: orderLineID];
                    if(item != null)
                    {
                        for (Shopping_cart_line_item__c detail : [Select Id, Product_SKU__c,Opportunity__r.Cart_State__c,Opportunity__r.Cart_ZipCode__c, Discount__c,Discount_Price__c,DiscountType__c,
                                                                  Flat_Discounted_Amount__c,Last_Price__c,List_Price__c, Average_Cost__c, Quantity__c,
                                                                  Opportunity__c,Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c
                                                                  from  Shopping_cart_line_item__c where Opportunity__c=: item.Opportunity__c and Delivery_Mode__c=: item.Delivery_Mode__c]) 
                        {
                            if(!detail.Product_SKU__c.startsWith('*')){
                                lineItems.add(detail);
                            }
                        }
                       
                    }
                }
                else{
                    for (Shopping_cart_line_item__c detail : [Select Id,Product_SKU__c,Opportunity__r.Cart_State__c,Opportunity__r.Cart_ZipCode__c,Quantity__c,DeliveryDate__c,Delivery_Mode__c
                                                              From Shopping_cart_line_item__c 
                                                              where Opportunity__c =: orderId]) {
                                                                  if(!detail.Product_SKU__c.startsWith('*')){
                                                                      lineItems.add(detail);
                                                                  }
                                                              }
                }
                
                if(!lineItems.isEmpty() && lineItems[0].Delivery_Mode__c != null){
                    //payload.deliveryMode = deliveryCodeTYpeToDeliveryModeMap.get(lineItems[0].Delivery_Mode__c.toUpperCase());
                    payload.deliveryMode=lineItems[0].Delivery_Mode__c;
                }
                if(String.isBlank(payload.deliveryMode)){
                    payload.deliveryMode = DEFAULT_DELIVERY_MODE;
                }
                
                // Adress setup
                updatePayloadWithOpenLineItemShipToAddress(payload,shipToAddr);
                
                for(Shopping_cart_line_item__c oli: lineItems){
                    payload.products.add(new API_ATCClient.ProductWrapper(oli.Product_SKU__c, Integer.valueOf(oli.Quantity__c)));
                }
                system.debug('payload-->'+payload);
            }
            //End of internal opportunity and Shopping_cart_line_item__c
            else{
                system.debug('in external'); 
                SalesOrder__x order = SalesOrderDAO.getOrderByExternalId(orderId);					
                
                List<SalesOrderItem__x> lineItems;
                if(orderLineID != null){
                    lineItems = new List<SalesOrderItem__x>{SalesOrderDAO.getOrderLineItemByExternalId(orderLineID)};
                        }
                else{
                    lineItems = SalesOrderDAO.getOrderLineItemsByOrderExternalId(orderId);
                }
                
                if(!lineItems.isEmpty() && lineItems[0].phdDeliveryType__c != null){
                    payload.deliveryMode = deliveryCodeTYpeToDeliveryModeMap.get(lineItems[0].phdDeliveryType__c.toUpperCase());
                }
                if(String.isBlank(payload.deliveryMode)){
                    payload.deliveryMode = DEFAULT_DELIVERY_MODE;
                }
                
                // Adress setup
                updatePayloadWithOpenLineItemShipToAddress(payload, lineItems);
                
                for(SalesOrderItem__x oli: lineItems){
                    payload.products.add(new API_ATCClient.ProductWrapper(oli.phdItemSKU__c, Integer.valueOf(oli.phdQuantity__c)));
                }
            }
            //API_ATCClient.ATCResponseWrapper apiCallResponse = API_ATCClient.getAvailableDeliveryWindows(accountNumber, rdcId, 
            //                                                                                            preferredDeliveryDateCoverted.adddays(-22), preferredDeliveryDateCoverted.addDays(22), payload);
            List<Delivery_Window__c> del=[SELECT Name, SetupOwnerId, CreatedDate,LastUpdatedDate__c,LastModifiedDate,window__c,Number_of_hours__c 
										  FROM Delivery_Window__c 
										  WHERE IsDeleted = False and Name='Delivery Window'];
            if(!del.isEmpty()){
                datetime updateDate;
                if(del[0].LastUpdatedDate__c == null && del[0].window__c == null)
                {
                del[0].LastUpdatedDate__c=system.now();
                }
                updateDate = del[0].LastUpdatedDate__c;
                updateDate = updateDate.addHours(Integer.valueOf(del[0].Number_of_hours__c));
                system.debug('updateDate-->'+updateDate.format('yyyy-MM-dd HH:mm:ss', 'PST') +'system.today()-->'+DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'PST') );
                if(updateDate <= DateTime.now() || del[0].window__c == null)
                {
                    //time to update the custom setthings Delivery_Window__c
                    StoreInfoWrapper si = ShoppingCartDetailCmpCtrl.getStoreInfoInShoppingCartDetail();
                    
                    //Get API key and End Point URL from Custom Settings     
                    Integration_Settings__c pmtTypesConf= Integration_Settings__c.getValues(ATC_CALL_DAYS_API_SETTING_NAME);
                    
                    if(pmtTypesConf==null){
                        throw new ATC_CALL_DAYS_APIException('ATP config missing: Custom Setting > Integration Setting' 
                                                  + ATC_CALL_DAYS_API_SETTING_NAME+', Please contact a system administrator.');
                    }      
                    // Get endpoint path configuration from custom settings
                    ConciergeProductAPISetting__c prodApiSetting = ConciergeProductAPISetting__c.getValues(PATH_SETTING_NAME);
                    String path = prodApiSetting.ATC_CALL_DAYS_API__c;
                    
                    List<String> strList = new List<String>();
                    strList.add(si.fulfillerId);
                    strList.add(si.profitCtr);
                    
                    String endPointURL = pmtTypesConf.End_Point_URL__c + String.format(path,strList);
                    //String endPointURL='https://ashley-preprod-dev.apigee.net/homestores/8888300-164/inventory/sales-order-settings/ATC_CALL_DAYS?profitCenter=23';                   
                    
                    ShoppingCartItemDetailsAPIHelper itemDetailAPIHelper = new ShoppingCartItemDetailsAPIHelper();
                    String resJSON = itemDetailAPIHelper.connectToAPIGetJSON(endPointURL,new Map<String, String> {'apiKey'=> pmtTypesConf.API_Key__c});
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resJSON);
                    system.debug('result---'+result);
                    integer windowtemp =Integer.valueOf(result.get('Value'));
                    if(windowtemp != null){
                    window =  Integer.valueOf(result.get('Value'));
                    system.debug('window---'+window);
                    del[0].window__c=window;
                    del[0].LastUpdatedDate__c=DateTime.now();
                    }
                       else{
                           window= Integer.valueOf(del[0].window__c);
                       }
                }
                else{
                    //custom settings Delivery_Window__c lastUpdated within 24 hrs
                    window= Integer.valueOf(del[0].window__c);
                    system.debug('window--1-'+window);
                }
                
            }
            //calling Threshold Api days 
            List<TresholdAvailableDaysWrapper> Thresholdresponse = new list<TresholdAvailableDaysWrapper>();
            
            Thresholdresponse = TresholdAvlbDays();
            system.debug('Thresholdresponse----'+Thresholdresponse);
            //Response Days
            List<String> threshoresponseAvldays = new List<String>();
            if(Thresholdresponse != null){
            for(TresholdAvailableDaysWrapper tda: Thresholdresponse){
              string dayname=tda.value;
                threshoresponseAvldays.add(dayname);
            }
                system.debug('threshoresponseAvldays--'+threshoresponseAvldays);
                }
             List<Date> thresholdfinaldays = new List<Date>();
           
            system.debug('Thresholdresponse--'+Thresholdresponse);
            system.debug('accountNumber--'+accountNumber);
              system.debug('payload--'+payload);
            system.debug('rdcId--'+rdcId);
            system.debug('preferredDeliveryDateCoverted.addDays(window)--'+preferredDeliveryDateCoverted.addDays(window));
          
           
            API_ATCClient.ATCResponseWrapper apiCallResponse = API_ATCClient.getAvailableDeliveryWindows(accountNumber, rdcId, 
                                                                                                         preferredDeliveryDateCoverted,preferredDeliveryDateCoverted.addDays(window), payload);
            update del;
            if(apiCallResponse.isSuccess){
                callResponse.isSuccess = true;
                
                if(apiCallResponse.deliveryWindows != null && !apiCallResponse.deliveryWindows.isEmpty()){
                    List<Date> deliveryDates = new List<Date>();
                    for(API_ATCClient.DeliveryWindow dw: apiCallResponse.deliveryWindows){
                        deliveryDates.add(dw.getStartDate());
                    }
                    
                    deliveryDates.sort();
                    Set<Date> deliverDatesSet = new Set<Date>(deliveryDates);
                    system.debug('deliveryDates----'+deliveryDates);
                    DeliveryCalendar calendar = new DeliveryCalendar();
                    calendar.weekDayNames = weekDayNames();
                    
                    List<MonthWrapper> months = new List<MonthWrapper>();
                    calendar.months = months;
                    List<TMonthWrapper> Tmonths = new List<TMonthWrapper>();
                    calendar.Tmonths = Tmonths;
                    
                    
                    
                    Date firstMonthStart = deliveryDates[0].toStartOfMonth();
                    Date lastMonthStart = deliveryDates[deliverydates.size() -1].toStartOfMonth();
                    List<Date> monthStarts = new List<Date>();
                    monthStarts.add(firstMonthStart);
                    if(firstMonthStart != lastMonthStart){
                        Date monthIterator = firstMonthStart.addMonths(1);
                        while(monthIterator <= lastMonthStart){
                            monthStarts.add(monthIterator);
                            monthIterator = monthIterator.addMonths(1);
                        }
                    }
                    
                    for(Integer i=0; i < monthStarts.size(); i++){
                        MonthWrapper mw = new MonthWrapper();
                        //set isfirst
                        if(i == 0){
                            mw.isFirst = true;
                        }				
                        //set is last
                        if(i == monthStarts.size()-1){
                            mw.isLast = true;
                        }
                        mw.index = i;
                        mw.name = DateTime.newInstance(monthStarts[i].year(), monthStarts[i].month(), monthStarts[i].day()).format('MMM, yyyy');

                        //Added by Ajay started 
                        integer monthval = monthStarts[i].month();
                        integer yearval = monthStarts[i].year();
                       system.debug('month and year--'+monthval+yearval);
                        //available days for reponse Day names
                       if(Thresholdresponse != null){
                        if(monthval != null && yearval != null){
                          
                           Date[] dates = new Date[] {};
                           list<string> resultss = new list<string>();    
                           list<string> wekname = new list<string>();
                           Integer daysInMonth = Date.daysInMonth(yearval, monthval);
                          for (Integer day = 1; day <= daysInMonth; day++) {
                            dates.add(Date.newInstance(yearval, monthval, day));
                                 
                          }
                            system.debug('dates---'+dates);
                            for(Date d:dates){
                                datetime dt=DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
                                string weekname=dt+'/'+dt.format('EEEE'); 
                                system.debug('weekname---'+weekname+d);
                                
                                for(String dd:threshoresponseAvldays){
                                   if(weekname.contains(dd)){
                                      string[] spltdate = weekname.split(' ');
                                      string[] spltformat = spltdate[0].split('-');
                                      Date AvailabledaysofT = date.newinstance(integer.valueOf(spltformat[0]), integer.valueOf(spltformat[1]), integer.valueOf(spltformat[2]));
                                       for(date tfinal:deliverDatesSet){
                                           if(AvailabledaysofT == tfinal ){
                                       thresholdfinaldays.add(AvailabledaysofT);
                                       system.debug('AvailabledaysofT--'+AvailabledaysofT); 
                                          }
                                           }
                                        
                                       }  
                                }
                            }
                            system.debug('thresholdfinaldays----'+thresholdfinaldays);
                            }
                    }
                          
                        Date firstDayOfFirstWeek = monthStarts[i].toStartOfWeek();
                        
                        Date firstDayOfLastWeek = ((monthStarts[i].addMonths(1)).addDays(-1)).toStartOfWeek();
                        
                        List<Date> weekStarts = new List<Date>{firstDayOfFirstWeek};
                            Date weekStartIterator = firstDayOfFirstWeek.addDays(7);
                        while(weekStartIterator <= firstDayOfLastWeek){
                            weekStarts.add(weekStartIterator);
                            weekStartIterator = weekStartIterator.addDays(7);
                        }
                        for(Integer w=0; w<weekStarts.size() ;w++){
                            mw.weeks.add(new List<DateWrapper>());
                            for(Integer y=0; y < 7; y++){
                                DateWrapper dwrapper = new DateWrapper(weekStarts[w].addDays(y));
                                
                                dwrapper.dateStringForDisplay = formatDateForCalendar(dwrapper.d);
                                dwrapper.dayofweek = formatDateForCalendardays(dwrapper.d);
                                if(deliverDatesSet.contains(dwrapper.d)){
                                    dwrapper.availableForDelivery = true;
                                }
                                if(dwrapper.d.month() == monthStarts[i].month() && dwrapper.d.year() == monthStarts[i].year()){
                                    dwrapper.dateIsInCurrentMonth = true;
                                }
                            
                                mw.weeks[w].add(dwrapper);
                                system.debug('dwrapper----'+dwrapper);
                            }
                        }
                        
                        
                        months.add(mw);
                    }
                    if(Thresholdresponse != null){
                    thresholdfinaldays.sort();
                    system.debug('thresholdfinaldays----'+thresholdfinaldays);
                    Set<Date> TdeliverDatesSet = new Set<Date>(thresholdfinaldays);
                    system.debug('TdeliverDatesSet--'+TdeliverDatesSet);
                    					
        
                    Date TfirstMonthStart = thresholdfinaldays[0].toStartOfMonth();
                    Date TlastMonthStart = thresholdfinaldays[thresholdfinaldays.size() -1].toStartOfMonth();
                    List<Date> TmonthStarts = new List<Date>();
                    TmonthStarts.add(TfirstMonthStart);
                    if(TfirstMonthStart != TlastMonthStart){
                        Date TmonthIterator = TfirstMonthStart.addMonths(1);
                        while(TmonthIterator <= TlastMonthStart){
                            TmonthStarts.add(TmonthIterator);
                            TmonthIterator = TmonthIterator.addMonths(1);
                        }
                    }
                    
                    for(Integer i=0; i < TmonthStarts.size(); i++){
                       TMonthWrapper Tmw = new TMonthWrapper();
                        //set isfirst
                        if(i == 0){
                            Tmw.TisFirst = true;
                        }				
                        //set is last
                        if(i == TmonthStarts.size()-1){
                            Tmw.TisLast = true;
                        }
                        Tmw.Tindex = i;
                        Tmw.Tname = DateTime.newInstance(TmonthStarts[i].year(), TmonthStarts[i].month(), TmonthStarts[i].day()).format('MMM, yyyy');
                        system.debug('month and year ---'+TmonthStarts[i].year()+TmonthStarts[i].month());
                        Date TfirstDayOfFirstWeek = TmonthStarts[i].toStartOfWeek();
                        
                        Date TfirstDayOfLastWeek = ((TmonthStarts[i].addMonths(1)).addDays(-1)).toStartOfWeek();
                        
                        List<Date> TweekStarts = new List<Date>{TfirstDayOfFirstWeek};
                            Date TweekStartIterator = TfirstDayOfFirstWeek.addDays(7);
                        while(TweekStartIterator <= TfirstDayOfLastWeek){
                            TweekStarts.add(TweekStartIterator);
                            TweekStartIterator = TweekStartIterator.addDays(7);
                        }
                        for(Integer w=0; w<TweekStarts.size() ;w++){
                            Tmw.thresholdweeks.add(new List<DateWrappethresholdr>());
                            for(Integer y=0; y < 7; y++){
                                DateWrappethresholdr Tdwrapper = new DateWrappethresholdr(TweekStarts[w].addDays(y));
                                
                                Tdwrapper.TdateStringForDisplay = TformatDateForCalendar(Tdwrapper.da);
                                Tdwrapper.Tdayofweek = TformatDateForCalendardays(Tdwrapper.da);
                                if(Tdwrapper.da >= date.today()){
                                  Tdwrapper.TNopastdays = true;  
                                }
                                if(TdeliverDatesSet.contains(Tdwrapper.da)){
                                    Tdwrapper.TavailableForDelivery = true;
                                }
                                if(deliverDatesSet.contains(Tdwrapper.da)){
                                    Tdwrapper.ATCdates = true;
                                }
                                if(Tdwrapper.da.month() == TmonthStarts[i].month() && Tdwrapper.da.year() == TmonthStarts[i].year()){
                                    Tdwrapper.TdateIsInCurrentMonth = true;
                                }
                            
                                Tmw.thresholdweeks[w].add(Tdwrapper);
                                system.debug('Tdwrapper----'+Tdwrapper);
                            }
                        }
                        
                        
                        Tmonths.add(Tmw);
                    }
                    }
                    callResponse.calendar = calendar;
                    system.debug('callResponse-----'+callResponse);
                }
                else{
					callResponse.message = 'No Delivery Dates available';
                    /*List<Date> deliveryDates = new List<Date>();
                    deliveryDates.add(date.today().addDays(1));
                                        
                    deliveryDates.sort();
                    
                    DeliveryCalendar calendar = new DeliveryCalendar();
                    calendar.weekDayNames = weekDayNames();
                    
                    List<MonthWrapper> months = new List<MonthWrapper>();
                    calendar.months = months;					
                    
                    Set<Date> deliverDatesSet = new Set<Date>(deliveryDates);
                    
                    Date firstMonthStart = deliveryDates[0].toStartOfMonth();
                    Date lastMonthStart = deliveryDates[deliverydates.size() -1].toStartOfMonth();
                    List<Date> monthStarts = new List<Date>();
                    monthStarts.add(firstMonthStart);
                    if(firstMonthStart != lastMonthStart){
                        Date monthIterator = firstMonthStart.addMonths(1);
                        while(monthIterator <= lastMonthStart){
                            monthStarts.add(monthIterator);
                            monthIterator = monthIterator.addMonths(1);
                        }
                    }
                    
                    for(Integer i=0; i < monthStarts.size(); i++){
                        MonthWrapper mw = new MonthWrapper();
                        //set isfirst
                        if(i == 0){
                            mw.isFirst = true;
                        }				
                        //set is last
                        if(i == monthStarts.size()-1){
                            mw.isLast = true;
                        }
                        mw.index = i;
                        mw.name = DateTime.newInstance(monthStarts[i].year(), monthStarts[i].month(), monthStarts[i].day()).format('MMM, yyyy');
                        
                        Date firstDayOfFirstWeek = monthStarts[i].toStartOfWeek();
                        
                        Date firstDayOfLastWeek = ((monthStarts[i].addMonths(1)).addDays(-1)).toStartOfWeek();
                        
                        List<Date> weekStarts = new List<Date>{firstDayOfFirstWeek};
                            Date weekStartIterator = firstDayOfFirstWeek.addDays(7);
                        while(weekStartIterator <= firstDayOfLastWeek){
                            weekStarts.add(weekStartIterator);
                            weekStartIterator = weekStartIterator.addDays(7);
                        }
                        for(Integer w=0; w<weekStarts.size() ;w++){
                            mw.weeks.add(new List<DateWrapper>());
                            for(Integer y=0; y < 7; y++){
                                DateWrapper dwrapper = new DateWrapper(weekStarts[w].addDays(y));
                                dwrapper.dateStringForDisplay = formatDateForCalendar(dwrapper.d);
                                if(deliverDatesSet.contains(dwrapper.d)){
                                    dwrapper.availableForDelivery = true;
                                }
                                if(dwrapper.d.month() == monthStarts[i].month() && dwrapper.d.year() == monthStarts[i].year()){
                                    dwrapper.dateIsInCurrentMonth = true;
                                }
                                mw.weeks[w].add(dwrapper);
                            }
                        }
                        
                        months.add(mw);
                    }
                    callResponse.calendar = calendar;*/
                }
                
            }
            else{
                callResponse.isSuccess = false;
                callResponse.message = apiCallResponse.message;
            }			
        }
        catch(Exception ex){
            callResponse.isSuccess = false;
            callResponse.message = ex.getMessage();
        }
        return callResponse;
    }
    
    /**
* Method returns a list of strings that represent the Days of the week starting the first day of the week.  
* Day names will be short hand names like Mon, Tue etc...
*
* @return a list of strings representing the days of the weeek from day 1 to day 7
*/
    public static List<String> weekDayNames(){
        List<string> weekdayNames = new List<string>();
        Date startDate = Date.today().toStartOfWeek();
        for(Integer i=0; i<7; i++){
            Date dateInContext = startDate.addDays(i);
            weekdayNames.add(DateTime.newInstance(dateInContext.year(), dateInContext.month(), dateInContext.day()).format('E'));
            system.debug('weekdayNames'+weekdayNames);
        }
        return weekDayNames;
    }
    
    /**
* Formats a day so that it can be represented in a calendar
*
* @return a string representing a formatted date for calendar display
*/
    public static string formatDateForCalendar(Date d){		
        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
        return dt.format('M/d');
    }
    
     public static string TformatDateForCalendar(Date da){		
        DateTime tdt = DateTime.newInstance(da.year(), da.month(), da.day());
        return tdt.format('M/d');
    }
    
     public static string formatDateForCalendardays(Date d){		
        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
         return dt.format('EEEE');
    }
    
     public static string TformatDateForCalendardays(Date da){		
        DateTime tddt = DateTime.newInstance(da.year(), da.month(), da.day());
         return tddt.format('EEEE');
    }
    
    public static void updatePayloadWithOpenLineItemShipToAddress(API_ATCClient.ATCPayload payload, List<SalesOrderItem__x> lineItems){
        if(lineItems != null){
            //the address on the first line item of an open oirder can be used as the address for the order
            payload.city = lineItems[0].phdShipCity__c;
            payload.region = lineItems[0].phdShipState__c;
            payload.postalCode = lineItems[0].phdShipZip__c;
        }
    }
    
    public static void updatePayloadWithOpenLineItemShipToAddress(API_ATCClient.ATCPayload payload,String shipToAddr){
        
            //the address on the first line item of an open oirder can be used as the address for the order
            //payload.city = lineItems[0].phdShipCity__c;
            //payload.city = 'Lithia';
            if(String.isNotBlank(shipToAddr)){
                Address__c addr=[Select Id,City__c,State__c,Zip_Code__c 
                                From Address__c 
                                Where Id=:shipToAddr]; 
            payload.city=addr.City__c;
            payload.region = addr.State__c;
            //DEF-0835
            if(!String.isBlank(addr.Zip_Code__c) && addr.Zip_Code__c.indexOf('-') !=-1)
            {
                payload.postalCode =  addr.Zip_Code__c.split('-')[0];
            }
            else
            {
                payload.postalCode = addr.Zip_Code__c;
            }
            }

    }
    
    @AuraEnabled	
    public static DeliveryCalendarResponse getDeliveryCalendarDays(string preferredDeliveryDate, string orderId, string orderLineID, string accountNumber, string rdcId)
    { 
        return getDeliveryCalendarDays(preferredDeliveryDate,orderId,orderLineID, accountNumber, rdcId, null);
    }
    @AuraEnabled
    public static List<TresholdAvailableDaysWrapper> TresholdAvlbDays(){
    List<TresholdAvailableDaysWrapper> tresholddayswrap = new List<TresholdAvailableDaysWrapper>();
        list<String> trevalues = new list<String>();
   
     try{
     StoreInfoWrapper si;
     si = StoreInfo.getStoreInfo();
     string fulfiller = si.fulfillerId;
     string profitcenter = si.profitCtr;
     system.debug('fulfiller,profitcenter'+fulfiller+profitcenter);  
     String endpoint = system.label.AshleyApigeeEndpoint+fulfiller+'/salesorders/sales-orders/settings/THRES_HOLD_AVAILABLE_DAYS?profitCenter='+profitcenter;
      Http http = new http();
      Httprequest req = new HttpRequest();
      req.setHeader('apikey', system.label.AshleyApigeeApiKey);
      req.setEndpoint(endpoint);
      system.debug('tresholdenabledcall enpoint' + endpoint);
      req.setTimeOut(120000);
      req.setMethod('GET');
      HttpResponse res = http.send(req);

     
        if(res.getStatusCode()==200 && res.getBody() != null ){ 
		string responsedata = res.getBody();
         system.debug('responsedata'+responsedata);
          tresholddayswrap = (List<TresholdAvailableDaysWrapper>)System.JSON.deserialize(responsedata, List<TresholdAvailableDaysWrapper>.class);
            for(TresholdAvailableDaysWrapper drty : tresholddayswrap ){
                string tempval = drty.value;	
                trevalues.add(tempval);
            }
            system.debug('trevalues---'+trevalues);
        }else{
            
         tresholddayswrap=null;   
        }
            }catch (Exception e) {
            system.debug('Exception is ' + e);
              tresholddayswrap=null;
            }
  		
        
       return tresholddayswrap; 
    }
     @AuraEnabled
     public static Shopping_cart_line_item__c  DeliveryTypeLine(Id orderLineId){
        
       Shopping_cart_line_item__c  DeliveryTypeValue = [SELECT DeliveryType__c,Delivery_Mode__c FROM Shopping_cart_line_item__c WHERE Id =: orderLineId];
        system.debug('lstOfAccount value is'+DeliveryTypeValue);
        return DeliveryTypeValue;
     }
    
}