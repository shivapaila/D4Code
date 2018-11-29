@isTest
private class UpdateSalesOrderController_Test {
    
    @isTest 
    static void testGetOrderWithAshcomm() {
        //set some test data
        SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];

        SalesOrderItem__x testLineItem = TestDataFactory.initializeSalesOrderLineItems(1)[0];

        SalesOrderDAO.mockedSalesOrders.add(testSalesOrder);
        SalesOrderDAO.mockedSalesOrderLineItems.add(testLineItem);
        UpdateSalesOrderController.SalesOrderWrapper response = UpdateSalesOrderController.getOrderData('00x000000000000');     

        System.assert(response.isAshcommOrder, 'Order should have been Identified as ashcomm');
        
    }   

    @isTest 
    static void testGetOrderWithNonAshcommUndeliveredOrder() {
        //set some test data
        SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
        testSalesOrder.phhStoreID__c = '345550-646';
        testSalesOrder.phhSaleType__c = 'U';

        SalesOrderItem__x testLineItem = TestDataFactory.initializeSalesOrderLineItems(1)[0];               
                                                                                    

        SalesOrderDAO.mockedSalesOrders.add(testSalesOrder);
        SalesOrderDAO.mockedSalesOrderLineItems.add(testLineItem);
        UpdateSalesOrderController.SalesOrderWrapper response = UpdateSalesOrderController.getOrderData('00x000000000000');     

        System.assert(response.isAshcommOrder == false, 'Order should not have been Identified as ashcomm');
        System.assert(response.isEditable == true, 'Order should  have been Identified as editable');
        
    }   


    @isTest 
    static void testOrderUpdateWithAllAttributeGroupsUpdated() {
        //set some test data
        SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
        testSalesOrder.phhStoreID__c = '345550-646';
        testSalesOrder.phhSaleType__c = 'U';
        testSalesOrder.phhDesiredDate__c = Date.today();
        testSalesOrder.phhDatePromised__c = Date.today();
        testSalesOrder.phhProfitcenter__c = 5;
        testSalesOrder.phhSalesOrder__c = '009090';
        testSalesOrder.phhHot__c = false;
        testSalesOrder.fulfillerID__c = '000090-189';
        testSalesOrder.phhOrder_Notes__c = 'some notes';    
        testSalesOrder.phhCustomerName__c = 'test customer';    
        

        SalesOrderItem__x testLineItem = TestDataFactory.initializeSalesOrderLineItems(1)[0];
        testLineItem.phdDeliveryType__c = 'Homex';
        testLineItem.phdShipAddress1__c = '123 test street';
        testLineItem.phdShipAddress2__c = '';
        testLineItem.phdShipCity__c = 'Dallas';
        testLineItem.phdShipState__c = 'TX';
        testLineItem.phdShipZip__c = '76778';

        SalesOrderDAO.mockedSalesOrders.add(testSalesOrder);
        SalesOrderDAO.mockedSalesOrderLineItems.add(testLineItem);

        Id rescheduleReasonCodeId;
        for(Reschedule_Reason_Map__mdt rrm: [Select Id, Increments_Strike_Counter__c from Reschedule_Reason_Map__mdt]){
            if(rescheduleReasonCodeId == null){
                rescheduleReasonCodeId = rrm.Id;
            }
            else if(rrm.Increments_Strike_Counter__c){
                rescheduleReasonCodeId = rrm.Id;
            }
        }

        UpdateSalesOrderController.SalesOrderWrapper orderFromUpdate = new UpdateSalesOrderController.SalesOrderWrapper();
        orderFromUpdate.currentDeliverydate = Date.Today().addDays(5);
        orderFromUpdate.hot = true;
        orderFromUpdate.asap = false;
        orderFromUpdate.shipToStreet1  = '435 test street';
        orderFromUpdate.shipToStreet2 = 'APT 100';
        orderFromUpdate.shipToCity = 'Dallas';
        orderFromUpdate.shipToState = 'TX';
        orderFromUpdate.shipToPostalcode = '76778';
        orderFromUpdate.deliveryComments = 'some other notes';
        orderFromUpdate.rescheduleReasonCodeId = rescheduleReasonCodeId;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', 'sampleResponse',new Map<String, String>())); 
        UpdateSalesOrderController.UpdateSalesOrderResponse response = UpdateSalesOrderController.updateSalesOrder(JSON.serialize(orderFromUpdate));

        Test.stopTest();

        System.assert(response.hasErrors == false);

    }
    
    @isTest 
    static void testOrderUpdateWithAllAttributeGroupsUpdatedOne() {
        //set some test data
        SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
        testSalesOrder.phhStoreID__c = '345550-646';
        testSalesOrder.phhSaleType__c = 'U';
        testSalesOrder.phhDesiredDate__c = Date.today();
        testSalesOrder.phhDatePromised__c = Date.today();
        testSalesOrder.phhProfitcenter__c = 5;
        testSalesOrder.phhSalesOrder__c = '009090';
        testSalesOrder.phhHot__c = false;
        testSalesOrder.fulfillerID__c = '000090-189';
        testSalesOrder.phhOrder_Notes__c = 'some notes';    
        testSalesOrder.phhCustomerName__c = 'test customer';    
        

        SalesOrderItem__x testLineItem = TestDataFactory.initializeSalesOrderLineItems(1)[0];
        testLineItem.phdDeliveryType__c = 'Homex';
        testLineItem.phdShipAddress1__c = '123 test street';
        testLineItem.phdShipAddress2__c = '';
        testLineItem.phdShipCity__c = 'Dallas';
        testLineItem.phdShipState__c = 'TX';
        testLineItem.phdShipZip__c = '76778';

        SalesOrderDAO.mockedSalesOrders.add(testSalesOrder);
        SalesOrderDAO.mockedSalesOrderLineItems.add(testLineItem);

        Id rescheduleReasonCodeId;
        for(Reschedule_Reason_Map__mdt rrm: [Select Id, Increments_Strike_Counter__c from Reschedule_Reason_Map__mdt]){
            if(rescheduleReasonCodeId == null){
                rescheduleReasonCodeId = rrm.Id;
            }
            else if(rrm.Increments_Strike_Counter__c){
                rescheduleReasonCodeId = rrm.Id;
            }
        }

        UpdateSalesOrderController.SalesOrderWrapper orderFromUpdate = new UpdateSalesOrderController.SalesOrderWrapper();
        orderFromUpdate.currentDeliverydate = Date.Today().addDays(5);
        orderFromUpdate.asap = true;
        orderFromUpdate.shipToStreet1  = '435 test street';
        orderFromUpdate.shipToStreet2 = 'APT 100';
        orderFromUpdate.shipToCity = 'Dallas';
        orderFromUpdate.shipToState = 'TX';
        orderFromUpdate.shipToPostalcode = '76778';
        orderFromUpdate.deliveryComments = 'some other notes';
        orderFromUpdate.rescheduleReasonCodeId = rescheduleReasonCodeId;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', 'sampleResponse',new Map<String, String>())); 
        UpdateSalesOrderController.UpdateSalesOrderResponse response = UpdateSalesOrderController.updateSalesOrder(JSON.serialize(orderFromUpdate));

        Test.stopTest();

        System.assert(response.hasErrors == false);

    }
    
}