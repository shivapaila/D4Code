(function(EDQ, $) {
    'use strict';
    
    /** @type [ {typeName: [id, ...]}, ... ] */
    var duplicateIds;

    var duplicateCount, prevDuplicateCount;
    var hintPanel, hintLink;
    
    function init() {
    	duplicateCount = prevDuplicateCount = 0;
    	hintPanel = hintLink = null;
    }
    init();

    EDQ.checkDuplicates = function(reset) {
    	if (reset) {
    		init();
    	}

        var record = buildRecord();

        sforce.connection.duplicateRuleHeader = { includeRecordDetails: false }; // save some traffic
        sforce.connection.findDuplicates([ record ], {
            onSuccess: findDuplicatesSuccess,
            onFailure: function(err) {
            	console.error(err);
            }
        });
    };
    
    function findDuplicatesSuccess(results) {
        var result = results[0];
        updateDuplicates(result);
        toggleHint();
    }

	function updateDuplicates(result) {
		prevDuplicateCount = duplicateCount;

        duplicateIds = [];
        duplicateCount = 0;

        if (result.getBoolean('success')) {
            var ruleMatches = ensureArray(result.duplicateResults);
            for (var i = 0; i < ruleMatches.length && duplicateCount < EDQ._maxDuplicateCount; i++) {
                var ruleMatch = ruleMatches[i];
                var matchResults = ruleMatch.matchResults;
                if (matchResults.getBoolean('success')) {
                    var count = matchResults.getInt('size');
                    if (count) {
                    	count = Math.min(count, EDQ._maxDuplicateCount - duplicateCount);
                    	duplicateCount += count;

                        var typeName = ruleMatch.duplicateRuleEntityType;
                        var recordIds = [];

                        var records = ensureArray(matchResults.matchRecords);
                        for (var j = 0; j < count; j++) {
                            recordIds.push(records[j].record.Id);
                        }

                        var ruleMatch = {};
                        ruleMatch[typeName] = recordIds;
                        duplicateIds.push(ruleMatch);
                    }
                }
            }
        }
	}
	
	function toggleHint() {
		if (!hintPanel) {
            hintPanel = EDQ.getElementById('ltngHintPanel');
		}

        if (duplicateCount === 0) {
        	hintPanel.hide();
        } else {
            if (!hintLink) {
                hintLink = EDQ.getElementById('ltngHintLink');
                hintLink.click(showPopup);
            }

            if (duplicateCount !== prevDuplicateCount) {
                hintLink.text("We've found " + duplicateCount + " potential duplicates.");

                hintPanel.show();
                $('html, body').animate({ scrollTop: 0, scrollLeft: 0 }); // show and scroll into view
            }
        }
	}
    
    function showPopup() {
    	//sforce.debug.open();
    	//sforce.debug.trace = true;
    	
    	hintLink.off('click').on('click', function(e) { e.preventDefault() });
    	function onclose() {
    		hintLink.off('click').on('click', showPopup);
    	}

    	var args = { duplicateIdsJSON: JSON.stringify(duplicateIds) };
        var nsPrefix = EDQ.namespace ? EDQ.namespace + '.' : '';
    	sforce.apex.execute(nsPrefix + 'BaseDuplicates', 'GetDuplicates', args, {
    		onSuccess: function(result) {
                var ruleMatches = JSON.parse(result);
                EDQ.showDuplicates(ruleMatches, onclose);
    		},
    		onFailure: function(err) {
    			console.error(err);
    		}
    	}, false);

    	return false;
    }
    
    function ensureArray(value) {
        return Array.isArray(value) ? value : [ value ];
    }

    function buildRecord() {
        var record = new sforce.SObject(EDQ.recordType);
        
        if (EDQ.recordId) {
        	record.Id = EDQ.recordId;
        }
        
        var fields = EDQ._fieldElementIds; // set in DataQualityDynamicScripts
        for (var name in fields) {
            if (!fields.hasOwnProperty(name)) {
                continue;
            }

            var id = fields[name];
            var element = EDQ.getElementById(id);
            if (!element) {
                continue;
            }

            var value = element.val();
            var type = EDQ._fieldTypes[name];

            var isEmpty = value === null || value === '';
            // Values of disabled dependent picklists contain unprintable characters.
            isEmpty = isEmpty || (typeof value === 'string' && value.match(/[\x00-\x1F]/));
            
            if (!isEmpty) {
                if (type === 'DATE' || type === 'DATETIME') {
                	value = toISODate(value, type === 'DATE');
                }
            
                if (value !== null) {
                	//console.log(name + ' : ' + type + ' = ' + value);
                    record.set(name, value);
                }
            }
        }

        return record;
    }
    
    function toISODate(value, isDate) {
        value = Date.parse(value);
        if (isNaN(value)) { // invalid/unsupported date format
            value = null; // ignore the field value. 
        } else {
            if (isDate) {
                // Convert local dates to UTC to keep the same date when converting to ISO format.
                var date = new Date(value);
                value = Date.UTC(1900 + date.getYear(), date.getMonth(), date.getDate());
            } 
            value = new Date(value).toISOString(); // ISO format is supported by SOAP
        }
        return value;
    }
})(EDQ, EDQ.jQuery);

