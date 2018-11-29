global class UpdateUnassignedContactsScheduler implements Schedulable {
    
    // Execute at regular intervals
    global void execute(SchedulableContext ctx){
          UpdateUnassignedContactsBatch batch = new UpdateUnassignedContactsBatch();
          Database.executebatch(batch, 200);
    }
}