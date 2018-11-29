/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DataQualityService {
    global DataQualityService() {

    }
    webService static void ExecuteAsync(String recordId, String sObjectName) {

    }
    webService static void ExecuteAsync2(String recordId, String sObjectName, Boolean validateAddress, Boolean validateEmail, Boolean validatePhone) {

    }
    @Future(callout=true)
    global static void ExecuteAsync(Set<String> recordIds, String sObjectName, Boolean isEdit) {

    }
    global static void ExecuteWebToObject(List<SObject> sObjects, Integer maximumSObjectCount, Boolean isUpdate) {

    }
    global static List<EDQ.BaseTouchpoint> FilterTouchpointsForWhichVerificationIsRequired(List<EDQ.BaseTouchpoint> interactiveTouchpoints, Map<String,Object> currentObjectValues, Map<String,Object> oldObjectValues, Boolean isEdit) {
        return null;
    }
    global static Map<String,String> GetFieldLabelsForAllInputAndOutputMappingFieldNames(Map<String,Object> fields, List<EDQ.BaseTouchpoint> touchpoints, String sObjectName) {
        return null;
    }
    global static List<EDQ.BaseTouchpoint> GetInteractiveTouchpoints(String sObjectId, Boolean isEdit) {
        return null;
    }
    global static Boolean HasInputMappingValueChanged(Map<String,Object> newSObjectFields, Map<String,Object> oldSObjectFields, EDQ.BaseTouchpoint touchpoint) {
        return null;
    }
    global static void SetValidationStatus(List<SObject> newSObjects, List<SObject> oldSObjects, Boolean isInsert, Integer maximumSObjectCount) {

    }
}
