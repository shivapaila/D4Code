public without sharing class CaseTriggerHandler {

	public static final string CASE_SUB_TYPE_DAMAGE = 'Damage';	
	public static final string CASE_ORIGIN_EMAIL = 'Email';
	public static final string CASE_STATUS_CLOSED = 'Closed';

	public static final string CASE_RECORD_TYPE_SERVICE_REQUEST_DEVELOPER_NAME = 'Service_Request';
	public static final string ASHCOMM_ORDER_MARKET_NAME = 'ASHCOMM';
	public static final Set<String> CASE_SUB_TYPES_FOR_STRIKE_COUNT_CHANGE;
	

	static{
		//initialize case sub types
		CASE_SUB_TYPES_FOR_STRIKE_COUNT_CHANGE = new Set<String>();
		for(Case_Sub_Types_for_Strike_Counter__mdt cst: [Select Case_Sub_Type__c 
														from Case_Sub_Types_for_Strike_Counter__mdt]){
			CASE_SUB_TYPES_FOR_STRIKE_COUNT_CHANGE.add(cst.Case_Sub_Type__c.toUppercase());
		}
	}


	public static void handleBeforeInsert(List<Case> newCases){
		updateCaseStrikeCounter(newCases, null);
        copyTempSalesOrderToSalesOrder(newCases);
	}

	public static void handleAfterInsert(Map<Id,Case> newCaseMap){
       // updateAutoPopulationFields(newCaseMap.values());
        updateCaseAddress(newCaseMap.values());
        updatePersonAccountStrikerCounter(newCaseMap.values(), null);
		updateSalesOrderLookup(newCaseMap.values());
	}

	public static void handleBeforeUpdate(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
		updateCaseStrikeCounter(newCaseMap.values(), oldCaseMap);

		updateSuppliedEmailAndCaseStatus(newCaseMap.values());
	}

	public static void handleAfterUpdate(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
       // updateAutoPopulationFields(newCasemap.values());
        updateCaseAddress(newCaseMap.values());
		updatePersonAccountStrikerCounter(newCaseMap.values(), oldCaseMap);
		if(!System.isFuture() && !System.isBatch()){
			updateSalesOrderLookup(newCaseMap.values());
		}
	}

	/**
	 * Increases the Strike count on a case when a case is created with one of the Sub Types/reschedule reasons that trigger a strike count update
	 * or when a case is updated and the sub type/reschedule reason is changed to one of the Sub Types/reschedule reasons that trigger a strike count update. 
	 * The Sub Types/Reschedule reasons that trigger a strike count update are stored in Custom Metadata Types.
	 *
	 * @param  cases  list of new/updated cases
	 * @param  oldCaseMap a map containing versions of updated cases before the latest update, this parameter can be null in case of an insert
	 */
	private static void updateCaseStrikeCounter(List<Case> cases, Map<Id,Case> oldCaseMap){
		for(Case c: cases){
			if(c.Sub_Type__c != null && CASE_SUB_TYPES_FOR_STRIKE_COUNT_CHANGE.contains(c.Sub_Type__c.toUppercase())){
				//new cases
				if(oldCaseMap == null){
					c.Strike__c = (c.Strike__c > 0 ? c.Strike__c : 0 ) + 1;
				}
				//updated cases
				else{
					Case oldCase = oldCaseMap.get(c.Id);
					if(c.Sub_Type__c != oldCase.Sub_Type__c){
						c.Strike__c = (c.Strike__c > 0 ? c.Strike__c : 0 ) + 1;
					}
				}
			}
		}
	}

	/**
	 * Increases the Strike count on Person Accounts associated to new/updated cases if the Cases have a strike counter which is greater than one.
	 * On Updated cases, strike counter on the Account is updated only if the strike count on the case was changed in the latest update.
	 *
	 * @param  cases  list of new/updated cases
	 * @param  oldCaseMap a map containing versions of updated cases before the latest update, this parameter can be null in case of an insert
	 */
	private static void updatePersonAccountStrikerCounter(List<Case> cases, Map<Id,Case> oldCaseMap){
		Map<Id,Integer> accountStrikeCountMap = new Map<Id,Integer>();
		for(Case c: cases){
			if(c.AccountId != null && c.Strike__c > 0){
				boolean updateAccountStrikeCount = false;
				//new cases
				if(oldCaseMap == null){
					updateAccountStrikeCount = true;
				}
				//updated cases
				else{
					Case oldCase = oldCaseMap.get(c.Id);
					if(c.Strike__c != oldCase.Strike__c){
						updateAccountStrikeCount = true;
					}
				}

				if(updateAccountStrikeCount){
					if(accountStrikeCountMap.containsKey(c.AccountId)){
						accountStrikeCountMap.put(c.AccountId, accountStrikeCountMap.get(c.AccountId)+1);
					}else{
						accountStrikeCountMap.put(c.AccountId, 1);
					}
				}
			}
		}

		//update contact strike count
		if(!accountStrikeCountMap.isEmpty()){
			Map<Id,Account> accountsToUpdate = new Map<Id,Account> ([Select Id, Strike_Counter__pc 
																	from Account 
																	where Id in:accountStrikeCountMap.keySet() 
																	and IsPersonAccount = true]);
			if(!accountsToUpdate.isEmpty()){
				for(Account a: accountsToUpdate.values()){
					a.Strike_Counter__pc = (a.Strike_Counter__pc > 0 ? a.Strike_Counter__pc : 0 ) + accountStrikeCountMap.get(a.Id);
				}

				update accountsToUpdate.values();
			}
		}

	}

	/**
	 * Initiates the process of Replacing salesforce Ids for Sales Orde lookups on Case with the External ids of the coresponding orders. Actual replacement
	 * happens in a future call as External objects can't be used in a trigger context.
	 *
	 * @param  cases  list of new cases
	 */
	private static void updateSalesOrderLookup(List<Case> cases){
		List<String> orderIds = new List<Id>();
		List<Id> caseIds = new List<Id>();

		for(Case c: cases){
			if(c.Sales_Order__c != null){
				caseIds.add(c.Id);
			}
		}

		if(!caseIds.isEmpty()){
			updateSalesOrderLookupAsync(caseIds);
		}
	}

	/**
	 * Replaces salesforce Ids for Sales Orde lookups on Case with the External ids of the coresponding orders. A future method is used
	 * because External objects can't be manupilated in Triggers. Method also populates the profit center and market fields on the case
	 * based on attributes on the order
	 *
	 * @param  caseIds  list of newly created case ids 
	 */
	@future
	private static void updateSalesOrderLookupAsync(List<Id> caseIds){
		List<Case> cases = [Select Id, Sales_Order__c from Case where Id in:caseIds];
		List<Case> casesToUpdate = new List<Case>();
        Map<Id,SalesOrder__x> caseIdSalesOrderMap = new  Map<Id,SalesOrder__x>();

		//get list of salesforder Ids 
		List<Id> orderSalesForceIds = new List<Id>();
		String salesOrderIdPrefix = SalesOrder__x.sobjecttype.getDescribe().getKeyPrefix();
		Set<Id> casesWithSalesForceSalesOrderId = new Set<Id>();
		for(Case c: cases){
			if(c.Sales_Order__c != null && (c.Sales_Order__c.length() == 15 || c.Sales_Order__c.length() == 18) && c.Sales_Order__c.startsWith(salesOrderIdPrefix)){
				orderSalesForceIds.add(c.Sales_Order__c);	
				casesWithSalesForceSalesOrderId.add(c.Id);			
			}
		}
		//get order detail info and use it to update case's  sales order lookup
		if(!orderSalesForceIds.isEmpty()){
			List<SalesOrder__x> orders = SalesOrderDAO.getOrdersByIds(orderSalesForceIds);
			for(Case c: cases){
				if(casesWithSalesForceSalesOrderId.contains(c.Id)){
				    for(SalesOrder__x so: orders){
				        if(c.Sales_Order__c == so.Id){
				            caseIdSalesOrderMap.put(c.Id, so);
				        }
				    }
				}
			}
		}

		//for any sales orders not found by salesforce id, use external id lookup
		for(case c: cases){
		    if(caseIdSalesOrderMap.containsKey(c.id) == false){
		        SalesOrder__x so = SalesOrderDAO.getOrderByExternalId(c.Sales_Order__c);
		         caseIdSalesOrderMap.put(c.Id, so);
		    }
		}

		if(!caseIdSalesOrderMap.isEmpty()){
			//build fulfiller id to Market Name Map
			Map<String,String> fulfillerIdMarketNameMap = new Map<String,String>();
			for(Fulfiller_Id_to_Market_Name_Map__mdt m: [Select Fulfiller_Id__c, Market_Name__c 
														 from Fulfiller_Id_to_Market_Name_Map__mdt]){
				fulfillerIdMarketNameMap.put(m.Fulfiller_Id__c.toUpperCase(), m.Market_Name__c);
			}

			for(Case c: cases){
				if(caseIdSalesOrderMap.containsKey(c.Id)){
				    SalesOrder__x order = caseIdSalesOrderMap.get(c.Id);
                    if(order != null){
                        c.Sales_Order__c = order.ExternalId;
                        if(order.phhStoreID__c != null && order.phhStoreLocation__c != null && order.phhProfitcenter__c != null){
                            string calculatedProfitCenter = order.phhStoreLocation__c + ' - ' + order.phhStoreID__c + ' - ' + String.valueof(order.phhProfitcenter__c);
                            c.Profit_Center__c = calculatedProfitCenter;
                        }
                        if(order.fulfillerID__c != null && fulfillerIdMarketNameMap.get(order.fulfillerID__c.toUpperCase()) != null){
                            c.Market__c = fulfillerIdMarketNameMap.get(order.fulfillerID__c.toUpperCase());
                        }
                        else if(order.phhStoreID__c != null && UpdateSalesOrderController.isAshcommOrder(order.phhStoreID__c)){
                            c.Market__c = ASHCOMM_ORDER_MARKET_NAME;
                        }
                        casesToUpdate.add(c);
                    }
				}
			}

			if(!casesToUpdate.isEmpty()){
				update casesToUpdate;
			}
		}
	}

	/*
	 Update Address
	*/
    private static void updateCaseAddress(List<Case> cases){
        List<Id> caseIds = new List<Id>();
        for(Case c: cases){
            if(c.Sales_Order__c == null && c.Legacy_Service_Request_ID__c == null){
                caseIds.add(c.Id);
                System.debug('My case -->'+caseIds);
            }
        }
        try{
            Case casee = [SELECT AccountId,Address_Line_1__c,Address_Line_2__c,Address__c,City__c,Id,Sales_Order__c 
                          FROM Case WHERE Id =:caseIds[0]];
            System.debug('My case -->'+casee);
            if(!caseIds.isEmpty()){
                updateAddress(caseIds);
            }
        }
        catch(exception e){
            System.debug('Tech Scheduling case It is');
        }
    }
    
	/*
	 Update Address
	*/
    private static void updateAddress(List<Id> caseIds){
        List<Case> cases = [SELECT AccountId,Address_Line_1__c,Address_Line_2__c,Address__c,City__c,Id,Sales_Order__c 
                            FROM Case WHERE Id =:caseIds[0]];
        system.debug('cases-->'+cases[0].Address__c);
        system.debug('cases-->'+cases[0].Address_Line_1__c);
        Boolean Addressflag =false;
        Address__c myAddress = new Address__c();
        List<Case> casesToUpdate = new List<Case>();
        for(Case c: cases){
            if(c.Sales_Order__c == null){
                if(c.Address__c == '' || c.Address__c == null){
                    try{
                        system.debug('myAddress initial-->'+c.Address__c);
                        myAddress= [SELECT AccountId__c,Address_Line_1__c,Address_Line_2__c,Address_Type__c,City__c,Country__c,CreatedDate,Id,LastModifiedDate,Preferred__c 
                                    FROM Address__c WHERE AccountId__c =: c.AccountId AND Preferred__c = true 
                                    ORDER BY LastModifiedDate DESC NULLS FIRST LIMIT 1];
                        c.Address__c = myAddress.Id;
                        Addressflag = true;
                        system.debug('myAddress final-->'+c.Address__c);
                    }
                    catch(Exception e){
                        try{
                            system.debug('myAddress initial without preferred address-->'+c.Address__c);
                            myAddress= [SELECT AccountId__c,Address_Line_1__c,Address_Line_2__c,Address_Type__c,City__c,Country__c,CreatedDate,Id,LastModifiedDate,Preferred__c 
                                        FROM Address__c WHERE AccountId__c =:c.AccountId 
                                        ORDER BY LastModifiedDate DESC NULLS FIRST LIMIT 1];
                            c.Address__c = myAddress.Id;
                            Addressflag = true;
                            system.debug('myAddress final without preferred address-->'+c.Address__c);
                        }
                        catch(Exception ex){
                            system.debug('myAddress initial without Account address-->'+c.Address__c);
                            c.Address__c = NULL;
                            Addressflag = true;
                            system.debug('myAddress final-->'+c.Address__c);
                        }
                    } 
                }
                Account myAccount = [SELECT AccountNumber,Id,PersonEmail,Phone FROM Account WHERE Id =:c.AccountId];
                system.debug('My Account-->'+ myAccount);
                if(String.isBlank(c.Case_Email__c)){
                    system.debug('Email-->'+ myAccount.PersonEmail);
                    c.Case_Email__c = myAccount.PersonEmail ;
                }
                if(String.isBlank(c.Case_Phone_Number__c) || c.Case_Phone_Number__c == 'Use main phone instead'){
                    c.Case_Phone_Number__c = myAccount.Phone;
                    system.debug('Phone-->'+ myAccount.Phone);
                }
            }
            casesToUpdate.add(c);
        }
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
    }
    
        /*
	 Update Auto-Population fields
	*/
    private static void updateAutoPopulationFields(List<Case> cases){
        List<Id> caseIds = new List<Id>();
        for(Case c: cases){
            if(c.Sales_Order__c == null && c.Legacy_Service_Request_ID__c == null){
                caseIds.add(c.Id);
                System.debug('My case -->'+caseIds);
            }
        }
        try{
            Case casee = [SELECT AccountId,Address_Line_1__c,Address_Line_2__c,Address__c,City__c,Id,Sales_Order__c 
                          FROM Case WHERE Id =:caseIds[0]];
            System.debug('My case -->'+casee);
            if(!caseIds.isEmpty()){
                updateAutoPopulation(caseIds);
            }
        }
        catch(exception e){
            System.debug('Tech Scheduling case It is');
        }
    }
	/*
	 * Auto-populate fields after insert
	*/
    private static void updateAutoPopulation(List<Id> caseIds){
        List<Case> cases = [SELECT AccountId,Case_Email__c,Case_Phone_Number__c,Id,Sales_Order__c 
                            FROM Case WHERE Id =:caseIds[0]];
        system.debug('Case Email-->'+ cases[0]);
        List<Case> casesToUpdate = new List<Case>();
        for(Case c: cases){
            if(String.isBlank(c.Sales_Order__c)){
                Account myAccount = [SELECT AccountNumber,Id,PersonEmail,Phone FROM Account WHERE Id =:c.AccountId];
                 system.debug('My Account-->'+ myAccount);
                if(String.isBlank(c.Case_Email__c)){
                    system.debug('Email-->'+ myAccount.PersonEmail);
                    c.Case_Email__c = myAccount.PersonEmail ;
                }
                if(String.isBlank(c.Case_Phone_Number__c) || c.Case_Phone_Number__c == 'Use main phone instead'){
                    c.Case_Phone_Number__c = myAccount.Phone;
                    system.debug('Phone-->'+ myAccount.Phone);
                }
                casesToUpdate.add(c);
            } 
        }
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
    }
	/**
	 * Copy Contact Email to supplied email and update case status based on custom Close Status field.
	 *
	 * @param  cases  list of updated cases
	 */
	private static void updateSuppliedEmailAndCaseStatus(List<Case> cases){
		for(Case c: cases){
			if(CASE_ORIGIN_EMAIL.equalsIgnoreCase(c.Origin) && c.SuppliedEmail == null && c.ContactEmail != null && 
				(CASE_STATUS_CLOSED.equalsIgnoreCase(c.status) || c.Close_Case_Quick_Action__c)){
				c.SuppliedEmail = c.ContactEmail;
			}

			if(c.Close_Case_Quick_Action__c){
				c.Close_Case_Quick_Action__c = false;
				c.status = c.Close_Status__c;
			}
		}
	}
    /**
	 * Copy The Temp Sales Order field to Sales Order field. This temp Sales Order field is populated as default value when a case
	 * is created from a sales order as the External Object Lookup can't be initialized.
	 *
	 * @param  cases  list of new cases
	 */
    private static void copyTempSalesOrderToSalesOrder(List<Case> cases){
        for(Case c: cases){
            if(c.Temp_Sales_Order__c != NUll){
                c.Sales_Order__c = c.Temp_Sales_Order__c;
            }
        }
    }
}