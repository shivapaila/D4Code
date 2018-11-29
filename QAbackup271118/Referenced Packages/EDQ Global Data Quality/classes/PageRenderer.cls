/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global virtual class PageRenderer implements EDQ.DataQualityCallbackInterface {
    global String SObjectName {
        get;
    }
    global PageRenderer(ApexPages.StandardController stdController, String sObjectName) {

    }
    global virtual Component.apex.pageblock GetPageBody() {
        return null;
    }
    global System.PageReference RedirectToStandardPageInCaseOfAnError() {
        return null;
    }
}
