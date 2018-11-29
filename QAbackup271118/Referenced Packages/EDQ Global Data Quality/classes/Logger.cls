/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class Logger {
    global static EDQ.Logger Instance {
        get;
    }
    global Logger() {

    }
    global abstract void Flush();
    global Boolean IsDebugLoggingEnabled() {
        return null;
    }
    global abstract void LogDebugMessage(String param0);
    global virtual void LogErrorMessage(String message) {

    }
    global abstract void LogException(Exception param0, String param1, Boolean param2);
    global abstract void LogRequest(String param0);
    global abstract void LogResponse(String param0);
}
