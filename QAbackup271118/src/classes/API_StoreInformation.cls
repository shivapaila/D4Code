/****** v1 | Description: Store information endpoint | 12/1/2017 | L OMeara 
*******    | DEF-0452: Logic to populate fulfiller ID| 03/12/2018| Sorna (Perficient)
*/
@RestResource(urlMapping='/Account/StoreInformation/*')
global with sharing class API_StoreInformation {
    static final String ACCOUNT_TYPE_STORE = 'Store';
    static final String XML_NS = 'http://www.demandware.com/xml/impex/store/2007-04-30';
    static final String STORE_ID_ATTRIB = 'store-id';
    static final String NAME_TAG = 'name';
    static final String ADDR_TAG = 'address1';
    static final String CITY_TAG = 'city';
    static final String POST_TAG = 'postal-code';
    static final String STATE_TAG = 'state-code';
    static final String COUNTRY_TAG = 'country-code';
    static final String PHONE_TAG = 'phone';
    static final String HOURS_TAG = 'store-hours';
    static final String CUST_ATTRS_TAG = 'custom-attributes';
    static final String ATTR_ID_ATTRIB = 'attribute-id';
    static final String RDC_ATTRIB = 'isRdc';
    static final String CUST_SVC_HRS_ATTRIB = 'customerServiceHours';
    static final String CUST_SVC_PHONE_ATTRIB = 'customerServicePhone';
    static final String FULFILLER_NAME_ATTRIB = 'fulfillerDisplayName';
    static final String TRUE_VAL = 'true';

  	/* REST XML endpoint that receives a list of store information and inserts or updates the records */
	@HttpPost
    global static String addUpdateStoreInfo() {
        Savepoint sp = Database.setSavepoint();
        String result = 'success';

        try {
            // get record type id for store
        	Id AccountTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACCOUNT_TYPE_STORE).getRecordTypeId();

            List<Account> accountList = new List<Account>();
            // DEF-0452
            Map<String, List<FulfillerWrapper>> storeNameToID = new Map<String, List<FulfillerWrapper>>();
            
            // grab request
            RestRequest request = RestContext.request;
            Dom.Document doc = new Dom.Document();
            doc.load(request.requestBody.toString());
    
            Dom.XMLNode stores = doc.getRootElement();
            for(Dom.XMLNode store : stores.getChildElements()) {
                // extract hours for processing
                String hours = store.getChildElement(HOURS_TAG, XML_NS).getText();
                String scrubbedHours = hours.replaceAll('(<br/>)+', '');
                if (scrubbedHours.length() > 255)
                    scrubbedHours = scrubbedHours.subString(0,255);
                // get address values
                Dom.XMLNode street = store.getChildElement(ADDR_TAG, XML_NS); 
                Dom.XMLNode city = store.getChildElement(CITY_TAG, XML_NS);
                Dom.XMLNode state = store.getChildElement(STATE_TAG, XML_NS);
                Dom.XMLNode country = store.getChildElement(COUNTRY_TAG, XML_NS); 
                Dom.XMLNode postalCode = store.getChildElement(POST_TAG, XML_NS);
                // DEF-0452
                String storeName = store.getChildElement(NAME_TAG, XML_NS).getText();
                if(storeName != null && storeName != '')
                {
                    if(storeNameToID.containsKey(storeName.toLowerCase()))
                    {
                        storeNameToID.get(storeName.toLowerCase()).add(new FulfillerWrapper(
                                                    storeName,
                                                    store.getAttribute(STORE_ID_ATTRIB, null),
                                                    city!=null ? city.getText() : '',
                                                    state!=null ? state.getText() : ''
                                                    ));
                    }
                    else
                    {
                        storeNameToID.put(storeName.toLowerCase(), new List<FulfillerWrapper>{new FulfillerWrapper(
                                                    storeName,
                                                    store.getAttribute(STORE_ID_ATTRIB, null),
                                                    city!=null ? city.getText() : '',
                                                    state!=null ? state.getText() : ''
                                                    )});
                    }
                }
                // parse the main xml attributes into account record
                Account acctToAdd = new Account(
					RecordtypeId = AccountTypeStore, 
                    Store_Id__c = store.getAttribute(STORE_ID_ATTRIB, null), 
                    Name = storeName, // DEF-0452
                    Phone = store.getChildElement(PHONE_TAG, XML_NS).getText(), 
                    Store_Hours__c = scrubbedHours,
                    ShippingStreet = street!=null ? street.getText() : '', 
                    ShippingCity = city!=null ? city.getText() : '',  
                    ShippingState = state!=null? state.getText() : '', 
                    ShippingCountry = country!=null ? country.getText() : '',  
                    ShippingPostalCode = postalCode!=null ? postalCode.getText() : '',
                    BillingStreet = street!=null ? street.getText() : '', 
                    BillingCity = city!=null ? city.getText() : '',  
                    BillingState = state!=null ? state.getText() : '',
                    BillingCountry = country!=null ? country.getText() : '', 
                    BillingPostalCode = postalCode!=null ? postalCode.getText() : ''
                ); 
                
                // parse the optional child attributes
				Dom.XMLNode children = store.getChildElement(CUST_ATTRS_TAG, XML_NS);
                for(Dom.XMLNode child : children.getChildElements()) {
                    String attribType = child.getAttribute(ATTR_ID_ATTRIB, null); 
                    String value = child.getText();
                    
                    if (value != '') {
                        if ((attribType == RDC_ATTRIB) && (value == TRUE_VAL)) {
                            acctToAdd.Is_Regional_Distribution_Center__c = true;
                        } else if (attribType == CUST_SVC_HRS_ATTRIB) {
                            acctToAdd.Customer_Service_Hours__c  = value;
                        } else if (attribType == CUST_SVC_PHONE_ATTRIB) {
                            acctToAdd.Customer_Service_Phone__c  = value;
                        } else if (attribType == FULFILLER_NAME_ATTRIB) {
                            acctToAdd.Fulfiller_Display_Name__c  = value;
                        }  
                    }
                }
                
                accountList.add(acctToAdd);
            }
            // DEF-0452
            populateFulfillerID(storeNameToID, accountList);

            // upsert the accounts
            if (accountList.size() > 0) {
                upsert accountList Store_Id__c;
            }
        } catch (Exception e) {
            // error handling & reporting
            Database.rollback(sp);

            system.debug(e.getMessage() + ' ' + e.getStackTraceString());

            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'API_StoreInformation', 
                    'addUpdateStoreInfo', 
                    'Store Feed, create account entry Exception: ' + e.getMessage() + 
                    ' Stack Trace: ' + e.getStackTraceString()
				)
			);
            
            RestContext.response.statusCode = 500;
            result = e.getMessage();
        }     
        
		return result;        
    }
    // DEF-0452
    private static void populateFulfillerID(Map<String, List<FulfillerWrapper>> storeNameToID, List<Account> accountList)
    {
        for(Account acc : accountList)
        {
            acc.FulFiller_ID__c = null;
            if(acc.Fulfiller_Display_Name__c != null && acc.Fulfiller_Display_Name__c != '')
            {
                //acc.Fulfiller_ID__c = storeNameToID.get(acc.Fulfiller_Display_Name__c.toLowerCase());
                if(storeNameToID.containsKey(acc.Fulfiller_Display_Name__c.toLowerCase()))
                {
                    List<FulfillerWrapper> fulfillerStores = storeNameToID.get(acc.Fulfiller_Display_Name__c.toLowerCase());
                    // if there is just one match for fulfiller name, assign its fulfiller id
                    if(fulfillerStores.size() == 1)
                    {
                        acc.Fulfiller_ID__c = fulfillerStores[0].fulfillerId;
                    }
                    else if(fulfillerStores.size() > 1)
                    {
                        // if multiple match for fulfiller name, find a match for state and city
                        // if there is no match for state and city, find a match for state
                        for(FulfillerWrapper store : fulfillerStores)
                        {
                            // 
                            if((acc.BillingState != null && acc.BillingState.toLowerCase() == store.State)
                                && (acc.BillingCity != null && acc.BillingCity.toLowerCase() == store.City))
                            {
                                acc.Fulfiller_ID__c = store.fulfillerId;
                                break;
                            }
                            else if((acc.BillingState != null && acc.BillingState.toLowerCase() == store.State))
                            {
                                acc.Fulfiller_ID__c = store.fulfillerId;
                            }
                        }
                    }
                }
            }
        }
    }
    // DEF-0452
    public class FulfillerWrapper
    {
        public string fulfillerName;
        public string fulfillerId;
        public string city;
        public string state;
        public FulfillerWrapper(string nameStr, string idStr, string cityStr, string stateStr)
        {
            fulfillerName = nameStr;
            fulfillerId = idStr;
            city = cityStr != null ? cityStr.toLowerCase() : '';
            state = stateStr != null ? stateStr.toLowerCase() : '';
        }
    }
}