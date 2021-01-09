function generateSelectable(target) {
    var oldHTML = target.innerHTML;
        
    if (oldHTML.indexOf('&nbsp;') == 0) {
        oldHTML = oldHTML.slice('&nbsp;'.length);
    }

    var split1 = oldHTML.split("<");
    var split2 = [];
    for (var x = 0; x < split1.length; x++) {
        split2.push(split1[x].split(">")[0]);
        split2.push(split1[x].split(">")[1]);
    }
    var start = 3;
    if (oldHTML[0] != '<') {
        start = 0;
    }
    var split2Filtered = split2.filter(Boolean);
    if (split2Filtered[1] == 'strong') {
        start = 5;
    }
    var xToSkip = 0;
    for (var x = start; x < split2Filtered.length; x++) {
        var old = split2Filtered[x];
        if (old.startsWith('a href=') ||
            split2Filtered[x].startsWith('a data-fnid') ||
            split2Filtered[x].startsWith('strong')) {
            xToSkip++;
        }
        if (xToSkip == 0) {
            var new1 = old.replace(/[\b\wàèìòùÀÈÌÒÙáéíóúýÁÉÍÓÚÝâêîôûÂÊÎÔÛãñõÃÑÕäëïöüÿÄËÏÖÜŸçÇßØøÅåÆæœ’]+/g, '<selectable class="word">$&</selectable>');
            var new2 = new1.replace(/[.|,|;|:|!|?|“|”]/g, '<selectable class="punctuation">$&</selectable>');
            split2Filtered[x] = new2;
        }
        if (old.startsWith('/a') ||
            split2Filtered[x].startsWith('/strong')) {
            xToSkip--;
        }
    }
    var newHTML = ""
    for (var x = 0; x < split2Filtered.length; x++) {
        if (split2Filtered[x].startsWith('a href=') ||
            split2Filtered[x].startsWith('a data-fnid') ||
            split2Filtered[x].startsWith('/a') ||
            split2Filtered[x].startsWith('strong') ||
            split2Filtered[x].startsWith('/strong')) {
            newHTML += "<" + split2Filtered[x] + ">";
        } else {
            newHTML += split2Filtered[x];
        }
    }

	target.innerHTML = newHTML;
	var spans = target.querySelectorAll('selectable');

	// here starts the logic
	var isSelecting = false;
	for (var i=0, l=spans.length; i<l; i++) {
		(function span_handlers(span, pos) {
			// when the user starts holding the mouse button
			span.onmousedown = function() {
				span.onmouseenter();
			};
			// the main logic, we check if we need to set or not this span as selected:
			span.onmouseenter = function() {
				window.getSelection().coverAll();
			};
			// when the user hold up the mouse button:
			span.onmouseup = function() {
				window.getSelection().coverAll();
			};
		})(spans[i], i);
	}
};
// Usage:
var defSpans = document.querySelectorAll('span');
for (var i = 0; i < defSpans.length; i++) {
    var element = defSpans[i];
    generateSelectable(element);
}
Selection.prototype.coverAll = function() {
    var ranges = [];
    for(var i=0; i<this.rangeCount; i++) {
        var range = this.getRangeAt(i);
        while(range.startContainer.nodeType == 3 || range.startContainer.childNodes.length == 1)
            range.setStartBefore(range.startContainer);
        while(range.endContainer.nodeType == 3 || range.endContainer.childNodes.length == 1)
            range.setEndAfter(range.endContainer);
        ranges.push(range);
    }
    this.removeAllRanges();
    for(var i=0; i<ranges.length; i++) {
        this.addRange(ranges[i]);
    }
    return;
};

function unwrap(wrapper) {
    // place childNodes in document fragment
    var docFrag = document.createDocumentFragment();
    while (wrapper.firstChild) {
        var child = wrapper.removeChild(wrapper.firstChild);
        docFrag.appendChild(child);
    }
    // replace wrapper with document fragment
    wrapper.parentNode.replaceChild(docFrag, wrapper);
}

function clearSelection() {
    var elems1 = document.querySelectorAll('.selectionStart');
    for (var i=0; i<elems1.length; i++) {
        elems1[i].classList.remove('selectionStart');
    }
    var elems2 = document.querySelectorAll('.selectionEnd');
    for (var i=0; i<elems2.length; i++) {
        elems2[i].classList.remove('selectionEnd');
    }
}
