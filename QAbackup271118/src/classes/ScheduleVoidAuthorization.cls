/**************************************************************************************************
* Name       : ScheduleVoidAuthorization
* Purpose    : scheduler class for VoidOrphanPayments
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Sridhar            | 1.0        | 3/8/2018        | Initial Draft
**************************************************************************************************/
global class ScheduleVoidAuthorization implements Schedulable {
   global void execute(SchedulableContext SC) {
      VoidOrphanPayments voidPayment = new VoidOrphanPayments();
      Database.executeBatch(voidPayment,10);
   }
}