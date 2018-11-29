/**
* This is a controller class for DeliveryWindowLookup Lightning component that provides ability to select a new Delivery date for an order/order Item by making
* an  API call out to the ATC(Available to Client) API. 
*/
public with sharing class DesiredDeliveryWindowLookupController {
    

    
    /**
* Method gets a calendar that contains available desired delivery dates 
*/
    @AuraEnabled    
    public static DeliveryWindowLookupController.DeliveryCalendarResponse getDesiredDeliveryCalendarDays(String currentSelectedDate){ 
       
        DeliveryWindowLookupController.DeliveryCalendarResponse callResponse = new DeliveryWindowLookupController.DeliveryCalendarResponse();
        Date initialDay= date.today().addDays(1);
         Date endDay= date.today().addMonths(12);
        
        DeliveryWindowLookupController.DeliveryCalendar calendar = new DeliveryWindowLookupController.DeliveryCalendar();
        calendar.weekDayNames = DeliveryWindowLookupController.weekDayNames();
        
        List<DeliveryWindowLookupController.MonthWrapper> months = new List<DeliveryWindowLookupController.MonthWrapper>();
        calendar.months = months;                   
        
        
        Date firstMonthStart = initialDay.toStartOfMonth();
        Date lastMonthStart = endDay.toStartOfMonth();
        List<Date> monthStarts = new List<Date>();
        monthStarts.add(firstMonthStart);
        if(firstMonthStart != lastMonthStart){
            Date monthIterator = firstMonthStart.addMonths(1);
            while(monthIterator <= lastMonthStart){
                monthStarts.add(monthIterator);
                monthIterator = monthIterator.addMonths(1);
            }
        }
        String[] dateArr = new String[]{};
        if(!String.isEmpty(currentSelectedDate)){
            dateArr = currentSelectedDate.split('-');
        }
        for(Integer i=0; i < monthStarts.size(); i++){
            DeliveryWindowLookupController.MonthWrapper mw = new DeliveryWindowLookupController.MonthWrapper();
            //set isfirst
            if(i == 0){
                mw.isFirst = true;
            }               
            //set is last
            if(i == monthStarts.size()-1){
                mw.isLast = true;
            }
            if(dateArr.size()>1 && i==(Integer.valueOf(dateArr[1])-firstMonthStart.month())){
                 mw.isCurrentSeletedDateMonth = true;
            }
            mw.index = i;
            mw.name = DateTime.newInstance(monthStarts[i].year(), monthStarts[i].month(), monthStarts[i].day()).format('MMM, yyyy');
            
            Date firstDayOfFirstWeek = monthStarts[i].toStartOfWeek();
            
            Date firstDayOfLastWeek = ((monthStarts[i].addMonths(1)).addDays(-1)).toStartOfWeek();
            
            List<Date> weekStarts = new List<Date>{firstDayOfFirstWeek};
                Date weekStartIterator = firstDayOfFirstWeek.addDays(7);
            while(weekStartIterator <= firstDayOfLastWeek){
                weekStarts.add(weekStartIterator);
                weekStartIterator = weekStartIterator.addDays(7);
            }
            for(Integer w=0; w<weekStarts.size() ;w++){
                mw.weeks.add(new List<DeliveryWindowLookupController.DateWrapper>());
                for(Integer y=0; y < 7; y++){
                    DeliveryWindowLookupController.DateWrapper dwrapper = new DeliveryWindowLookupController.DateWrapper(weekStarts[w].addDays(y));
                    dwrapper.dateStringForDisplay = DeliveryWindowLookupController.formatDateForCalendar(dwrapper.d);
                    if(dwrapper.d>=initialDay){
                        dwrapper.availableForDelivery = true;
                    }                    
                    if(dwrapper.d.month() == monthStarts[i].month() && dwrapper.d.year() == monthStarts[i].year()){
                        dwrapper.dateIsInCurrentMonth = true;
                    }
                    mw.weeks[w].add(dwrapper);
                }
            }
            
            months.add(mw);
        }
        callResponse.calendar = calendar;
        callResponse.isSuccess = true;
        return callResponse;
    }
   
}