/****** v1 | Description: parse CustomerWrapper | 12/21/2017 | Lauren OMeara */
global class APIParseHelper{
    /**
    *   @description: Method to parse JSON string to CustomerWrapper
    *   @return:      Returns List of CustomerWrapper
    */
    public static List<CustomerWrapper> parseCustomerRequest(String requestString) {
        List<CustomerWrapper> customerList = new List<CustomerWrapper> ();
        JSONParser parser = JSON.createParser(requestString);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        customerList.add((CustomerWrapper)parser.readValueAs(CustomerWrapper.class));
                        parser.skipChildren();
                    }
                }
            }
        }
        return customerList;
    }    
}