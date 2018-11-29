@isTest
global class ApexRestCalloutForTech implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ScheduledDate":"04/22/2018","OpenDate":"2018-04-11T23:26:16.000Z","FollowUpDate":"2018-04-21","ReopenDate":"2018-04-11T23:26:16.000Z","ReasonCode":"25","Address2":"","CustomerPhone1":"6785556769","CustomerPhone2":"6785551743","CustomerEmail":"anacdv@gmail.com","EstimatedTimeForStop":"1.","RequestActiveFlag":"Y","CreatedTime":" ","LastTime":"2018-04-11T23:26:16.000Z","LastuserId":" ","AssigneeCode":"11","ReasonCodeText":"test","AssigneeName":"test","RequestStatus":"4","RequestStatusText":"Customer Query","IsTechResource":" ","RequestPriorityText":"High","RequestPriority":"6","VendId":"AFFINITY","RequestSalesOrderNumber":"","Address1":"1025 WINDSOR WAY","ProfitCenterCode":28,"CityName":"GRIFFIN","StateCode":"GA","ZipCode":"30224","CreatedUserId":"0","ServiceTechId":"27","TechName":"Dummy Date, zIn Home Damage Tech","VendName":"","VpcName":"","PcKey":"","CustomerPhone3":"","CustomerId":"006786146769"}');
        response.setStatusCode(200);
        return response; 
    }
}