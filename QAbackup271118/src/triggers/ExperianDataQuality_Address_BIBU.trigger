trigger ExperianDataQuality_Address_BIBU on Address__c (before insert, before update) {
    EDQ.DataQualityService.SetValidationStatus(Trigger.new, Trigger.old, Trigger.IsInsert, 2);
}