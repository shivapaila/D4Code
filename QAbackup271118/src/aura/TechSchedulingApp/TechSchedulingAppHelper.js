({
    valueChanged : function(cmp, ev) {
        var times=0;
        var current=cmp.get('v.value');
        var final=cmp.get('v.inputVal');
        var increment=1;
        if (final<current) {
            increment=-1;
        }
        var self=this;
        var timeoutRef = window.setInterval($A.getCallback(function() {
            if (cmp.isValid()) {
                var value=cmp.get('v.value');
                value+=increment;
                if (value==final) {
                    window.clearInterval(cmp.get('v.timeoutRef'));
                    cmp.set('v.timeoutRef', null);
                }
                cmp.set('v.value', value);
            }
        }), 120000);
        cmp.set('v.timeoutRef', timeoutRef);
    }
})