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

function initView(isBible) {
	document.querySelectorAll('video').forEach(e => e.remove());
	
	if (!isBible) {
		var paragraphsNodeList = document.querySelectorAll('[data-pid]');
		var paragraphs = Array.prototype.slice.call(paragraphsNodeList, 0);
		// paragraphs.sort(function(a, b) {
		// 	return +a.getAttribute("data-pid") - +b.getAttribute("data-pid");
		// })
		for (var i = 0; i < paragraphs.length; i++) {
			var paragraph = paragraphs[i];
			var parNumber = Number(paragraph.getAttribute('data-pid'));
			var bibleCitations = paragraph.querySelectorAll('a.b');
			for (var j = 0; j < bibleCitations.length; j++) {
				var bibleCitation = bibleCitations[j];
				bibleCitation.setAttribute("onClick", "javascript: openBibleCitation(" + parNumber + ", " + j + ");");
			}
		}
	}
}

function generateSelectable() {
	// https://stackoverflow.com/a/50135988/14721889
	// https://stackoverflow.com/a/66380709/14721889
	// let body = document.querySelector("body");
	// body.innerHTML = body.innerHTML.replace(/(?<!(<\/?[^>]*|&[^;]*))([^\s<]+)/g, '$1<selectable class="word">$2</selectable>')
	// SPOILER: Su Safari non funziona...

	var newBody = "";
	let script = document.querySelector('script');
	let body = document.querySelector("body");
	body.removeChild(script);
	let replacedHTML = body.innerHTML.replaceAll("><", "> <").replaceAll("&nbsp;", " ");
	var splittedBody = replacedHTML.split(/[<>]+/);
	while (splittedBody[splittedBody.length - 1].trim() == "") {
		splittedBody.pop();
	}
	for (let index = 0; index < splittedBody.length; index++) {
		var newContent = splittedBody[index];
		noPrev = newBody.endsWith('<sup>') || newBody.endsWith('class="cl vx vp"><strong>') || newBody.endsWith('class="vl vx vp">')  || newBody.endsWith('class="cl vx vp"> <strong>');
		if ((index % 2 == 0) && ((newContent.trim().length > 1) || newContent.trim() == ';' /* Per adesso so solo di questo */) && !noPrev) {
			newContent = newContent.replace(/[\b\wàèìòùÀÈÌÒÙáéíóúýÁÉÍÓÚÝâêîôûÂÊÎÔÛãñõÃÑÕäëïöüÿÄËÏÖÜŸçÇßØøÅåÆæœ’:-]*[^:\-.,;!?“”()‘’\s]+/g, '<selectable class="word">$&</selectable>');
			newContent = newContent.replace(/[:|\-|’](?=[\s|.|,])/g, '<selectable class="punctuation">$&</selectable>');
			newContent = newContent.replace(/[.|,|;|!|?|“|”|(|)|‘]/g, '<selectable class="punctuation">$&</selectable>');
		}
		newBody += newContent + (index % 2 == 0 ? "<" : ">");
	}
	body.innerHTML = newBody;
	body.appendChild(script);
	makeSelectable();
};

function makeSelectable() {
	var spans = document.querySelectorAll('selectable');
	// here starts the logic
	// var isSelecting = false;
	for (var i=0, l=spans.length; i<l; i++) { // https://stackoverflow.com/a/44847561/14721889
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
}

function cleanSelection() {
	var elems1 = document.querySelectorAll('.selectionStart');
	for (var i=0; i<elems1.length; i++) {
		elems1[i].classList.remove('selectionStart');
	}
	var elems2 = document.querySelectorAll('.selectionEnd');
	for (var i=0; i<elems2.length; i++) {
		elems2[i].classList.remove('selectionEnd');
	}
}

function addHighlight(color, isBible) {
	var paragraphsNodeList;
	if (isBible) {
		paragraphsNodeList = document.querySelectorAll('span');
	} else  {
		paragraphsNodeList = document.querySelectorAll('[data-pid]');
	}
	var paragraphs = Array.prototype.slice.call(paragraphsNodeList, 0);
	if (!isBible) {
		paragraphs.sort(function(a, b) {
			return +a.getAttribute("data-pid") - +b.getAttribute("data-pid");
		})
	}
	window.getSelection().anchorNode.parentElement.classList.add('selectionStart');
	window.getSelection().focusNode.parentElement.classList.add('selectionEnd');
	var started = false;
	var lastPar = 0;
	var lastParN = 0;
	for (var i = 0; i < paragraphs.length; i++) { // Controllo tutti i paragrafi
		var paragraph = paragraphs[i];
		var par = isBible ? Number(paragraph.id.split('-')[2]) : Number(paragraph.getAttribute('data-pid'));
		if (par != lastPar) {
			lastParN = 0;
		}
		console.log(paragraph);
		var selectables = paragraph.getElementsByTagName("selectable");
		var startIndex = -1;
		var endIndex = -1;
		if (started && startIndex == -1) {
			startIndex = 0;
		}
		for (var j = 0; j < selectables.length; j++) { // Controllo tutti i selectables
			var selectable = selectables[j];
			var realJ = lastPar == par ? j + lastParN : j;
			if (selectable.classList.contains('selectionStart')) {
				startIndex = realJ;
				started = true;
				console.log(selectable.innerText);
			}
			if (selectable.classList.contains('selectionEnd')) {
				endIndex = realJ;
				started = false;
				console.log(selectable.innerText);
			}
		}
		if (started && endIndex == -1) {
			endIndex = selectables.length - 2;
		}
		console.log(startIndex, endIndex);
		if (endIndex > -1 && startIndex > -1) {
			window.webkit.messageHandlers.toggleMessageHandler.postMessage({
				"mode": 0,
				"paragraph": par,
				"startIndex": startIndex,
				"endIndex": endIndex,
				"color": color,
			});
		}
		lastPar = par;
		lastParN += selectables.length;
	}
	window.getSelection().empty();
	cleanSelection();
}

function restoreHighlight(identifier, startToken, endToken, color, isBible) {
	var paragraphsNodeList;
	if (isBible) {
		paragraphsNodeList = document.querySelectorAll('span');
	} else  {
		paragraphsNodeList = document.querySelectorAll('[data-pid]');
	}
	var paragraphs = Array.prototype.slice.call(paragraphsNodeList, 0);
	if (!isBible) {
		paragraphs.sort(function(a, b) {
			return +a.getAttribute("data-pid") - +b.getAttribute("data-pid");
		})
	}
	console.log(startToken, endToken)
	var lastPar = 0;
	var lastParN = 0;
	for (var i = 0; i < paragraphs.length; i++) { // Controllo tutti i paragrafi
		var paragraph = paragraphs[i];
		var par = isBible ? Number(paragraph.id.split('-')[2]) : Number(paragraph.getAttribute('data-pid'));
		if (par != lastPar) {
			lastParN = 0;
		}
		if (par != identifier) { continue; }
		console.log(paragraph);
		var selectables = paragraph.getElementsByTagName("selectable");
		var highlightning = false;
		for (let j = 0; j < selectables.length; j++) {
			selectable = selectables[j];
			var realJ = lastPar == par ? j + lastParN : j;
			if (realJ == startToken) {
				highlightning = true;
			}
			if (highlightning) {
				console.log(selectable);
				var highlighting = document.createElement("highlighting");
				highlighting.classList.add('highlightingcolor' + color);
				selectable.parentNode.insertBefore(highlighting, selectable);
				highlighting.appendChild(selectable);
			}
			if (realJ == endToken) {
				highlightning = false;
			}
		}
		var paragraphContent = paragraph.innerHTML;
		console.log(paragraphContent);
		paragraphContent = paragraphContent.replaceAll('</highlighting> <highlighting class="highlightingcolor' + color + '">', ' ');
		paragraphContent = paragraphContent.replaceAll('</highlighting><highlighting class="highlightingcolor' + color + '">', '');
		paragraph.innerHTML = paragraphContent;
		lastPar = par;
		lastParN += selectables.length;
	}
	makeSelectable();
}

function cleanBodyHighlight() {
	var bodyContent = document.querySelector('body').innerHTML;
	for (let i = 0; i <= 8; i++) {
		bodyContent = bodyContent.replaceAll('<highlighting class="highlightingcolor' + i + '">', '');
	}
	bodyContent = bodyContent.replaceAll('</highlighting>', '');
	document.querySelector('body').innerHTML = bodyContent;
}

function showImg(i) {
	window.webkit.messageHandlers.toggleMessageHandler.postMessage({
		"mode": 1,
		"imgIndex": Number(i),
	});
}

function openBibleCitation(parOrdinal, elementNumber) {
	window.webkit.messageHandlers.toggleMessageHandler.postMessage({
		"mode": 2,
		"parOrdinal": Number(parOrdinal),
		"elementNumber": Number(elementNumber),
	});
}