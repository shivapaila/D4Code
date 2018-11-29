/* *******************************************************************************************************************
* Class Name   : ProductReviewAndRatingCallOutMock
* Description  : Http Call Out Mock test class for Asheley Product Reviews and Rating API .
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/20/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************///
@isTest
global class ProductReviewAndRatingCallOutMock implements HttpCalloutMock {
    private String fetchType;
    /**
    * @description <Constructor for apiType> 
    **/
    global ProductReviewAndRatingCallOutMock(String apiType){
        this.fetchType = apiType;
    }
    
    /**
    * @description <Implement the interface HttpCalloutMock's respond method to return mock response>
    * @return <return is the Mocked JSON string or throw a CalloutException>
    **/
	global HTTPResponse respond(HTTPRequest req) {
        if(fetchType == 'CalloutExceptionTest'){
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Throw CalloutException Test. Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }else{
            system.debug(req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            ProductRatingsWrapper productRating;
            ProductReviewsWrapper productReviews;
            
            if(fetchType == 'JSONExceptionTest'){
                res.setBody('Non JSON format String to make it throw JSONException when do the JSON Parse');
            }else if(fetchType == 'RatingTest'){
                productRating = prepareProductRating();
                String bodyContent = JSON.serialize(productRating);
                res.setBody(bodyContent);
            }else if(fetchType == 'ReviewsTest'){
                productReviews = prepareProductReviews();
                String bodyContent = JSON.serialize(productReviews);
                res.setBody(bodyContent);
            }
            res.setStatusCode(200);
            return res;
        }
    }


     /**
    * @description <Simulate Product Rating info>                                                       
    * @return <Asserts return is the Mocked ProductRatingsWrapper object>
    **/    
    public static ProductRatingsWrapper prepareProductRating(){
        ProductRatingStatisticWrapper prsw = new ProductRatingStatisticWrapper();
        prsw.averageOverallRating = 5.0;
        prsw.overalRatingRange = 5;
        prsw.totalReviewCount = 1;

        ProductStatisticsWrapper psw = new ProductStatisticsWrapper();
        psw.productStatistics = new ProductStatisticWrapper();
        psw.productStatistics.productId ='1200014';
        psw.productStatistics.reviewStatistics = prsw;
        
       	ProductRatingsWrapper productRating = new ProductRatingsWrapper();
        productRating.totalResults =1;
        productRating.results = new List<ProductStatisticsWrapper>{psw};
         
        return productRating;
    }
     /**
    * @description <Simulate Product Reviews info>                                                       
    * @return <Asserts return is the Mocked ProductRatingsWrapper object>
    **/    
    public static ProductReviewsWrapper prepareProductReviews(){
        ProductReviewsWrapper prsW = new ProductReviewsWrapper();
        prsW.totalResults =1;
        ProductReviewWrapper productReview = new ProductReviewWrapper();
        
        productReview.Id= '201430782';        
        productReview.ProductId= '1200014';        
        productReview.AuthorId= 'asmtlcgvuievbezjuh6nl9ptg';        
        productReview.Rating=5;
        productReview.SubmissionTime= System.now();
        productReview.ReviewText= 'So glad I bought this Ottoman.';       
        productReview.UserNickname= 'Writermama46';                 
        productReview.IsRecommended= true; 
        productReview.ModerationStatus=  'APPROVED';    

        prsW.results = new List<ProductReviewWrapper>{productReview};
        return prsW;
    }
    
}