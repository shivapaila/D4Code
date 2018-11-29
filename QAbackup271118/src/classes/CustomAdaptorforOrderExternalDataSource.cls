/***
Class: CustomSFConnectAdaptor
Description: Custom Adaptor for Order Manager external source
Date: 11/28/2017
Author: Rucha (Perficient)

v2 | Updates for global id | Rucha (Perficient) | 3/9/2018
***/

global with sharing class CustomAdaptorforOrderExternalDataSource extends DataSource.Connection{
    private static final String CARA_ORDER_ODATA_NAMED_CREDENTIAL_SANDBOX = 'Cara_Order_Odata_Sandbox';
    private static final String CARA_ORDER_ODATA_NAMED_CREDENTIAL_PROD = 'Cara_Order_Odata_Prod';
    private Static Boolean isNoValue;

    global CustomAdaptorforOrderExternalDataSource(DataSource.ConnectionParams connectionParams) {
        isNoValue = false;
    }
    
    //Can be used for syncing with tables and fields of external data source
    //However using this method will need tables name and field names to be updated in this method. IF a new field
    //is added this method will need to be updated. Hence this method will not be used and fields will be manually created 
    //on the external object
    override global List<DataSource.Table> sync() {
        List<DataSource.Table> tables = new List<DataSource.Table>();        
        return tables;
    }

    //This method is called everytime an external object record is viewed either from the related list 
    //or list views or queried through code
    override global DataSource.TableResult query(DataSource.QueryContext c) {
        String tableName = c.tableSelection.tableSelected;
        system.debug('tableName------'+tableName+'-------'+c);
        String str = getFilterValue(c,tableName);
        DataSource.TableResult dstr;

        try{
            dstr = DataSource.TableResult.get(c, getRows(str,tableName));
        }
        catch(Exception e){
            if(e.getMessage().containsIgnoreCase(Label.EOInvalidContactId)){
                dstr = DataSource.TableResult.error(Label.EONoOrdersForACustomerError);
            }
            else{
                dstr = DataSource.TableResult.error(Label.EOGeneralExceptionMessage + e.getMessage());
            }
        }
        return dstr;
    }

    //This method is called during global search
    override global List<DataSource.TableResult> search(DataSource.SearchContext context) {
        List<DataSource.TableResult> results = new List<DataSource.TableResult>();
        String str = 'phhSalesOrder eq \'' + context.searchPhrase + '\'';

        try{
            system.debug('tableSelection--c--'+context.tableSelections);
            for (DataSource.TableSelection tableSelection : context.tableSelections) {
                system.debug('tableSelection----'+tableSelection);
                results.add(DataSource.TableResult.get(tableSelection,getRows(str,'GlobalSalesOrderHeaders')));
            }
        }
        catch(Exception e){
            DataSource.TableResult.error('No sales orders found for ' + context.searchPhrase);
        }
        system.debug('results-----'+results.size());
        return results;
    }

    // Helper method to get record values from the external system
    private List<Map<String, Object>> getRows (String filterValue, String tableName) {
        // Get row field values for the table from the external system via a callout.
        HttpResponse response = makeGetCallout(filterValue,tableName);
        // Parse the JSON response and populate the rows.
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(        
        response.getBody());
        Map<String, Object> error = (Map<String, Object>)m.get('error');        
        if (error != null) {
            throwException('Error in retrieving orders: ' + string.valueOf(error.get('message')));
        }
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        
        if(!isNoValue)
        {
            List<Object> jsonRows = (List<Object>)m.get('value');
            
            if (jsonRows == null) {
                rows.add(foundRow(m,tableName));
            } 
            else {
                for (Object jsonRow : jsonRows) {
                    Map<String,Object> row = (Map<String,Object>)jsonRow;
                    rows.add(foundRow(row,tableName));
                }
            }
        }
        else if(isNoValue)
        {
            List<Object> jsonRows = (List<Object>)m.get('value');
            system.debug('jsonRows-----'+jsonRows);
            if (jsonRows == null) {
                rows.add(foundRow(m,tableName));
            } 
            else {
                for (Object jsonOIRow : jsonRows) {
                    String jsOI = JSON.serialize(jsonOIRow);
                    Map<String, Object> mOI = (Map<String, Object>)JSON.deserializeUntyped(jsOI);
                    List<Object> jsOIRows = (List<Object>)mOI.get('orderLineItem');
                    for (Object jsnOIRow : jsOIRows) {
                        Map<String,Object> row = (Map<String,Object>)jsnOIRow;
                        
                        rows.add(foundRow(row,tableName));
                    }
                }
            }
        }
        system.debug('rows--size---'+rows.size());
        return rows;
    }
    // Make a GET callout
     private static HttpResponse makeGetCallout(String filterValue, String tableName) {
        // Instantiate a new http object
        Http h = new Http();
        system.debug('GlobalSalesOrderHeaders------'+tableName);
        //Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        String apiEndPoint;
        if(Utilities_SalesAndService.isSandbox){
            apiEndPoint = 'callout:'+ CARA_ORDER_ODATA_NAMED_CREDENTIAL_SANDBOX;
        }
        else{
            apiEndPoint = 'callout:'+ CARA_ORDER_ODATA_NAMED_CREDENTIAL_PROD;
        }
        
         String url;
        if(tableName == 'GlobalSalesOrderHeaders')
        {
            url = apiEndPoint + '/odata/' +tableName + '?$filter=' + EncodingUtil.urlEncode(filterValue, 'UTF-8');
            system.debug('here...' + url);
        }
        else if(filterValue.contains('phhContactID')&& filterValue.contains('phhContactID') && tableName == 'SalesOrderHeaders')
        {
            url = apiEndPoint + '/odata/' +tableName + '?$filter=' + EncodingUtil.urlEncode(filterValue, 'UTF-8');
            system.debug('here...' + url);
        }
        else if(tableName.equals('SalesOrderLineItems'))
        {
            url = apiEndPoint + '/odata/SalesOrderLineItems?$filter=' + EncodingUtil.urlEncode(filterValue, 'UTF-8');
            system.debug('hereinsecondsection...' + url);
        }
        else
        {
            url = apiEndPoint + '/odata/SalesOrder?$filter=' + EncodingUtil.urlEncode(filterValue, 'UTF-8');
            system.debug('hereinsecondsection...' + url);
        }
            system.debug('debugforurl..' + url);
       //String url = apiEndPoint + '/odata/' +tableName + '?$filter=' + EncodingUtil.urlEncode(filterValue, 'UTF-8');
        url = url.replace('+','%20');
        system.debug('url: ' + url);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(90000);
        HttpResponse response = h.send(req);
         system.debug('responseforapi'+ response);
         system.debug('responsebody'+ response.getBody());
        return response;
     }

     // Populate a row based on values from the external system.
     private Map<String,Object> foundRow(Map<String,Object> foundRow, String tableName) {        
        Map<String,Object> row = new Map<String,Object>();
        String extId;
        //system.debug('foundRow------'+foundRow);
        //Formulate external id so that it can be passed as parameters in subsequent API calls
        if(tableName.equals('SalesOrderHeaders') ||
            tableName.equals('GlobalSalesOrderHeaders')){

            //extId = getValueForKey(string.valueOf(foundRow.get('ID'))) + ':' +
              extId =   getValueForKey(string.valueOf(foundRow.get('phhSalesOrder'))) + ':' +
                        getValueForKey(string.valueOf(foundRow.get('phhContactID')));//+ ':' +
                        //getValueForKey(string.valueOf(foundRow.get('phhOrderCurrentStatus')));
        }
        else if(tableName.equals('SalesOrderLineItems')){
            if(!isNoValue)
            {
                //extId = '200457940:001q000000raI3DAAU';
                   extId = getValueForKey(string.valueOf(foundRow.get('phdSalesOrder'))) + ':' + 
                           getValueForKey(string.valueOf(foundRow.get('phdContactID')))+ ':' +
                           //getValueForKey(string.valueOf(foundRow.get('phdOrderCurrentStatus')))+ ':' +
                           getValueForKey(string.valueOf(foundRow.get('phdItemSeq')));
            }
            else if(isNoValue)
                extId = getValueForKey(string.valueOf(foundRow.get('phdSalesOrder'))) + ':' + 
                        getValueForKey(string.valueOf(foundRow.get('phdContactID')))+ ':' +
                        //getValueForKey(string.valueOf(foundRow.get('phdOrderCurrentStatus')))+ ':' +
                        getValueForKey(string.valueOf(foundRow.get('phdItemSeq')));
        }
                
        row.put('ExternalId', extId);
        for(String fieldName : foundRow.keySet()){
            //system.debug('fieldName---g---'+fieldName);
            if(foundRow.get(fieldName) != null){
                if(fieldName.containsIgnoreCase('Date') ||
                    fieldName.containsIgnoreCase('phdWarrantyExpiredOn')){
                    String fieldValue = getDateInFormatToConvert(String.valueOf(foundRow.get(fieldName)));
                    try{
                        row.put(fieldName,DateTime.valueOf(fieldValue));
                    }
                    catch(Exception dte){
                        try{
                            row.put(fieldName,Date.valueOf(fieldValue));
                        }
                        catch(Exception e){
                            system.debug('Error in converting date or datetime value from external object: ' + e.getMessage() + ' : ' + e.getStackTraceString());
                            throwException('Error in converting date or datetime value from external object: ' + e.getMessage() + ' : ' + e.getStackTraceString());
                        }
                    }
                }
                else if(fieldName.equalsIgnoreCase('phhNPS')){
                    //system.debug('fieldName---n---'+fieldName);
                    row.put(fieldName, getFormattedNPSInfo(JSON.serialize(foundRow.get(fieldName))));
                }
                else{
                    //system.debug('foundRow---e---'+foundRow.get(fieldName));
                    row.put(fieldName,foundRow.get(fieldName));
                }
            }
        }
        system.debug('row---found---'+row);     
        return row;
    }

    //This method will formulate the filters to be passed in the API call
    private String getFilterValue(DataSource.QueryContext c,String tableName){
        
        String filterValue;
      
        String colVal = String.valueOf(c.tableSelection.filter.columnValue);
        String colName = String.valueOf(c.tableSelection.filter.columnName);

        if(colVal == null){
            colVal = String.valueOf(c.tableSelection.filter.subfilters.get(0).columnValue);
            colName = String.valueOf(c.tableSelection.filter.subfilters.get(0).columnName);
        }

        //If condition is true if the SO is being viewed in the related tab of the contact
        //else is true when a single SO is being viewed

        if(tableName.equals('SalesOrderLineItems')){
            List<String> extId = colVal.split(':');
            system.debug('extId-------'+extId.get(0));
            system.debug('extId-------'+extId.get(1));
            if('phdSalesOrder'.equalsIgnoreCase(colName) ){
                 //isNoValue = true;
                 //filterValue = 'phhContactID eq \'' + '001q000000raI3DAAU'  + '\'' + 
                  //              ' and phhSalesOrder eq \'' + '200457940' + '\''; 
                   filterValue = 'phdContactID eq \'' + getParameterValue(extId.get(1))  + '\'' + 
                                ' and phdSalesOrder eq \'' + getParameterValue(extId.get(0)) + '\'';
                    //filterValue = 'ID eq \'' + getParameterValue(extId.get(0)) + '\'';
                system.debug('filterValue---1----'+filterValue);
            }
            else{
                
                if(extId.get(1) != null && extId.get(1) != 'NoValue')
                {
                    //filterValue = 'phdContactID eq \'' + getParameterValue(extId.get(1)) + '\'' + 
                    //    ' and phdSalesOrder eq ' + getParameterValue(extId.get(0)) ;
                    filterValue = 'phdContactID eq \'' + getParameterValue(extId.get(1))  + '\'' + 
                                ' and phdSalesOrder eq \'' + getParameterValue(extId.get(0)) + '\'';
                    system.debug('filterValue---2----'+extId.get(1));
                }
                else
                {
                    //isNoValue = true;
                    filterValue = 'phdSalesOrder eq \'' + getParameterValue(extId.get(0)) + '\'';
                    system.debug('filterValue---3----'+extId.get(1));
                }
            }
        }
        else{
             List<String> extId = colVal.split(':');
                        
            if(extId.size() == 1){
                     filterValue = 'phhContactID eq \'' + extId.get(0) + '\'';
                    system.debug('filterValue---c----'+filterValue);
            }
            else
            {
                
                if(extId.get(1) != 'NoValue')
                {
                    filterValue = 'phhContactID eq \'' + getParameterValue(extId.get(1))  + '\'' + 
                                ' and phhSalesOrder eq \'' + getParameterValue(extId.get(0)) + '\'';
                     system.debug('filterValue---g----'+filterValue);
                }
                else
                {
                    filterValue = 'phhSalesOrder eq \'' + getParameterValue(extId.get(0)) + '\'';
                    
                }
            }
        }

        return filterValue;
    }

    private String getDateInFormatToConvert(String dt){
        List<String> dateAndTime = dt.split('T');
        return dateAndTime.get(0) + ' ' + dateAndTime.get(1).substring(0,dateAndTime.get(1).lastIndexOf('Z'));
    }

    private Object getValueForKey(Object inputValue){
        system.debug('inputValue------'+inputValue);
        if(inputValue == null || inputValue == ''){
            return 'NoValue';
        }
        else{
            return inputValue;
        }
    }

    private Object getParameterValue(Object parameter){
        if(parameter == 'NoValue'){
            return '';
        }
        else{
            return parameter;
        }

    }

    public class NPSWrapper{
        public string npsScore {get;set;}
        public string npsSurveyStatus {get;set;}
        public string npsComment1 {get;set;}
        public string npsComment2 {get;set;}
        public string npsCorrectiveAction {get;set;}
        public string npsPreventiveAction {get;set;}
        
        public string getStringRepresentation(){
            string formattedNps = '';
            formattedNps += 'Score = ' + (npsScore != null ? npsScore : ' ')+',';
            formattedNps += 'Comment 1 = ' + (npsComment1 != null ? npsComment1 : ' ')+',';
            formattedNps += 'Comment 2 = ' + (npsComment2 != null ? npsComment2 : ' ')+',';
            formattedNps += 'Corrective Action = ' + (npsCorrectiveAction != null ? npsCorrectiveAction : ' ')+',';
            formattedNps += 'Preventative Action = ' + (npsPreventiveAction != null ? npsPreventiveAction : ' ')+',';
            formattedNps += 'Survey Status = ' + (npsSurveyStatus != null ? npsSurveyStatus : ' ');
            return formattedNps;
        }
    }

    private string getFormattedNPSInfo(string npsJSON){
        string formattedNPSInfo = npsJSON;
        try{
            List<NPSWrapper> npsScores = (List<NPSWrapper>)JSON.deserialize(npsJSON, List<NPSWrapper>.class);
            List<String> npsScoreStrings = new List<String>();
            for(NPSWrapper n: npsScores){
                npsScoreStrings.add(n.getStringRepresentation());
            }
            formattedNPSInfo = String.join(npsScoreStrings, ' *** ');
        }
        catch(Exception ex){
            System.debug('Failed to format NPS: ' + ex.getMessage());
        }
        return formattedNPSInfo;
    }
}