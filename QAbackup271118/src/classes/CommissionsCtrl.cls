/* *******************************************************************************************************************
* Class Name   : CommissionsCtrl
* Description  : This is lightning controller class that communicates with the Commission Component
*               
* Author       : Sriram (Perficient, Inc.)
* Created On   : 06/12/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************/
public class CommissionsCtrl {

    private final static String OPPORTUNITY_SPLIT_TYPE_REVENUE = 'Revenue';
    private final static Decimal OPPORTUNITY_SPLIT_PERCENTAGE_100 = 100;
    private final static String VALIDATION_MSG_ERROR_SPLITS_EXCEEDED = 'The split is allowed upto 4 times. Please adjust to zero for splits to exclude.';

    public class CommissionsCtrlException extends Exception {}

    @AuraEnabled 
    public static CommissionCurrentRSAUserWrapper getCurrentRSA(){
        try {
            return new CommissionCurrentRSAUserWrapper();
        } catch (Exception e) {
            ErrorLogController.createLogFuture('CommissionsCtrl', 'getCurrentRSA', 'Error retrieving current RSA : ' + e.getMessage() +  ' Stack Trace: ' + e.getStackTraceString() );         
            throw new AuraHandledException('Error retrieving current RSA : '+ e.getMessage());
        }        
    }

    @AuraEnabled
    public static List<CommissionEntry> getCommissionEntries(String personAccId) {
        try {
            Opportunity opportunity = CreateSalesOrderHelper.getOpportunity(personAccId);
            Id opportunityId = opportunity.Id;            
            List<CommissionEntry> commissionEntries = new List<CommissionEntry>();
            List<CommissionEntry> commissionEntriesExcludingCurrentRSA = new List<CommissionEntry>();
            OpportunitySplitType opportunitySplitType = getOpportunitySplitType(OPPORTUNITY_SPLIT_TYPE_REVENUE);
            for (OpportunitySplit o : [ SELECT Id, SplitPercentage, SplitOwnerId 
                                        FROM OpportunitySplit 
                                        WHERE OpportunityId = :opportunityId
                                        ORDER BY SplitPercentage DESC]){
                CommissionEntry commissionEntry = new CommissionEntry(o.Id, getUser(o.SplitOwnerId), o.SplitPercentage);
                if (o.SplitOwnerId.equals(UserInfo.getUserId())){
                    commissionEntries.add(commissionEntry);
                } else {
                    commissionEntriesExcludingCurrentRSA.add(commissionEntry);
                }
            }
            if (commissionEntries.isEmpty()){
                throw new CommissionsCtrlException('No split record found for the current RSA');
            }
            commissionEntries.addAll(commissionEntriesExcludingCurrentRSA);
            return !commissionEntries.isEmpty() ? commissionEntries : new List<CommissionEntry>{new CommissionEntry(null, getUser(UserInfo.getUserId()), OPPORTUNITY_SPLIT_PERCENTAGE_100)};
        } catch (Exception e) {
            ErrorLogController.createLogFuture('CommissionsCtrl', 'getCommissionEntries', 'Error retrieving commission entries : ' + e.getMessage() +  ' Stack Trace: ' + e.getStackTraceString() );         
           throw new AuraHandledException('Error retrieving commission entries : ' + e.getMessage());
        }            
    }
    
    @AuraEnabled
    public static List<CommissionEntry> saveCommissionEntries(String personAccId, String commissionEntriesJSON) {
        try {
            Opportunity opportunity = CreateSalesOrderHelper.getOpportunity(personAccId);
            Id opportunityId = opportunity.Id;            
            OpportunitySplitType opportunitySplitType = getOpportunitySplitType(OPPORTUNITY_SPLIT_TYPE_REVENUE);
            List<CommissionEntry> commissionEntries = (List<CommissionEntry>) JSON.deserialize(commissionEntriesJSON, List<CommissionEntry>.class);

            Map<Id, OpportunityTeamMember> opportunityTeamMembers = getOpportunityTeamMembers(opportunityId);
            List<OpportunityTeamMember> opportunityTeamMembersToInsert = new List<OpportunityTeamMember>();
            List<OpportunitySplit> opportunitySplitsToInsert = new List<OpportunitySplit>();
            List<OpportunitySplit> opportunitySplitsToDelete = new List<OpportunitySplit>();
            for (CommissionEntry commissionEntry : commissionEntries){
                // Entries to insert
                if (commissionEntry.percentage > 0){
                    if (!opportunityTeamMembers.containsKey(commissionEntry.user.Id)){
                        opportunityTeamMembersToInsert.add(new OpportunityTeamMember(
                                UserId = commissionEntry.user.Id
                                , OpportunityId = opportunityId
                                , TeamMemberRole ='Sales Rep'
                            ));
                    }
                    opportunitySplitsToInsert.add(new OpportunitySplit(
                            OpportunityId = opportunityId,
                            SplitTypeId = opportunitySplitType.Id,
                            SplitPercentage = commissionEntry.percentage,
                            SplitOwnerId = commissionEntry.user.Id
                        ));
                }
                // Entries to delete
                if (String.isNotBlank(commissionEntry.Id)){
                    opportunitySplitsToDelete.add(new OpportunitySplit(
                            Id = commissionEntry.Id
                        ));
                }
            }
            if (opportunitySplitsToInsert.size()>3){
                throw new CommissionsCtrlException(VALIDATION_MSG_ERROR_SPLITS_EXCEEDED);
            }            
            if (!opportunitySplitsToDelete.isEmpty()){
                delete opportunitySplitsToDelete;
            }
            if (!opportunityTeamMembersToInsert.isEmpty()){
                insert opportunityTeamMembersToInsert;
            }
            if (!opportunitySplitsToInsert.isEmpty()){
                insert opportunitySplitsToInsert;
            }            
            return getCommissionEntries(personAccId);
        } catch (Exception e) {
            ErrorLogController.createLogFuture('CommissionsCtrl', 'saveCommissionEntries', 'Error saving commissions : ' + e.getMessage() +  ' Stack Trace: ' + e.getStackTraceString() );         
            throw new AuraHandledException('Error saving commissions : '+ e.getMessage());
        }
    }

    private static User getUser(String userId) {
        User u = [SELECT Id, Name FROM User WHERE Id = :userId];
        return u;        
    }

    private static Map<Id, OpportunityTeamMember> getOpportunityTeamMembers(String opportunityId){
        Map<Id, OpportunityTeamMember> opportunityTeamMembers = new Map<Id, OpportunityTeamMember>();
        for (OpportunityTeamMember o : [SELECT Id, UserId, TeamMemberRole, OpportunityId 
                                        FROM OpportunityTeamMember
                                        WHERE OpportunityId = :opportunityId]){
            opportunityTeamMembers.put(o.UserId, o);
        }
        return opportunityTeamMembers;
    }

    private static OpportunitySplitType getOpportunitySplitType(String developerName){
        for (OpportunitySplitType s : [SELECT Id, DeveloperName  FROM OpportunitySplitType WHERE DeveloperName = :developerName]){
            return s;
        }
        return null;
    }

    public class CommissionEntry {
        @AuraEnabled
        public String id { get; set; }  //This identifier represents the Opportunity Split Id       
        @AuraEnabled
        public User user { get; set; }
        @AuraEnabled
        public Decimal percentage { get; set; }
        // Constructor  
        public CommissionEntry(String Id, User user, Decimal percentage){
            this.id = Id;
            this.user = user;
            this.percentage = percentage;
        }       
    }

    public class CommissionCurrentRSAUserWrapper {
        @AuraEnabled
        public User user {get; set;}

        @AuraEnabled
        public String acctNo {get; set;}

        @AuraEnabled
        public String shipTo {get; set;}

        @AuraEnabled
        public String profitCenter {get; set;}

        public CommissionCurrentRSAUserWrapper(){
            this.user = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            StoreInfoWrapper storeInfo = StoreInfo.getStoreInfo();
            this.acctNo = storeInfo.acctNo;
            this.shipTo = storeInfo.shipTo;
            this.profitCenter = storeInfo.profitCtr;            
        }
    }    
}