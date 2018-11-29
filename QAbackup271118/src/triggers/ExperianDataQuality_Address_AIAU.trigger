trigger ExperianDataQuality_Address_AIAU on Address__c (before insert, before update) {
    EDQ.DataQualityService.ExecuteWebToObject(Trigger.New, 2, Trigger.IsUpdate);
}