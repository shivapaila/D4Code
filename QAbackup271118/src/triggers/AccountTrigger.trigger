/**************************************************************************************************
* Name       : AccountTrigger
***************************************************************************************************
* Author            | REQ    | Created Date    | Description
***************************************************************************************************
*Perficient         |         | 03/05/2018      | Initial Draft
**************************************************************************************************/

trigger AccountTrigger on Account (before insert, before update, before delete, 
                                    after insert, after update, after delete, after undelete) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.isUpdate)
        {
            AccountTriggerHandler.afterUpdate(trigger.oldMap, trigger.newMap);
        }
    }
}