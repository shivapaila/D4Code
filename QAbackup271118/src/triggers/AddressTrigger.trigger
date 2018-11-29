/**************************************************************************************************
* Name       : AddressTrigger
***************************************************************************************************
* Author            | REQ    | Created Date    | Description
***************************************************************************************************
*Perficient         |         | 03/05/2018      | Initial Draft
**************************************************************************************************
*D4                 |         | 22/05/2018      | Make the changes for Bill to/Shi to
**************************************************************************************************/

trigger AddressTrigger on Address__c (before insert, before update, before delete, 
                                    after insert, after update, after delete, after undelete) 
{
    
     if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            AddressTriggerHandler.beforeInsertAddressType(trigger.new);
            AddressTriggerHandler.duplicateAddress(trigger.new);
        }
        else if(Trigger.isUpdate)
        {
            //if(AddressTriggerHandler.isUpdate)
            //{
                AddressTriggerHandler.beforeUpdateAddressType(trigger.new, trigger.oldMap );
                AddressTriggerHandler.duplicateAddress(trigger.new);
            //}
        }
    }

    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            AddressTriggerHandler.afterInsert(trigger.newMap);
            AddressTriggerHandler.afterInsertAddressType(trigger.new);
        }
        else if(Trigger.isUpdate)
        {
            AddressTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
            AddressTriggerHandler.afterInsertAddressType(trigger.new);
           // AddressTriggerHandler.afterInsertUpdatePreffered(trigger.new, trigger.oldMap);
        }
    }
}