//
//  WebBrowserView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 02/01/21.
//

import Foundation
import WebKit
import SwiftUI
import AppKit

public struct WebBrowserView: NSViewRepresentable {
    @Binding var highlight: Int
    public func makeNSView(context: NSViewRepresentableContext<WebBrowserView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.pubb = pubb
        context.coordinator.book = book
        context.coordinator.chapter = chapter
        let contentController = self.webView.configuration.userContentController
        contentController.add(context.coordinator, name: "toggleMessageHandler")
        return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebBrowserView>) {
        if highlight > 0 || highlight == -1 {
            context.coordinator.highlightStuff(color: highlight)
        }
    }

    private let webView: WKWebView = WKWebView()
    private let nsView: NSView = NSView()
    let pubb: String
    let book: Int
    let chapter: Int

    public func load(url: URL) {
        webView.load(URLRequest(url: url))
    }

    public mutating func load() {
        let fileDir = FileManager.getDocumentsDirectory().appendingPathComponent("\(pubb)/\(book)/\(chapter).html")
        let article = (try? String(contentsOf: fileDir, encoding: .utf8)) ?? ""
        let meta = "<meta charset='UTF-8'>"
        let style = (try? String(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent("style.css"), encoding: .utf8)) ?? ""
        let script = (try? String(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent("script.js"), encoding: .utf8)) ?? ""
        let page = "<html><head>" + meta + "<style>" + style + "</style></head><body>" + article + "</body><script>" + script + "</script></html>"
        webView.loadHTMLString(page, baseURL: nil)
    }
/*
    public func highlight(color: Color) {
        print(color)
        webView.evaluateJavaScript("""
            var txt = document.getSelection().toString();
            window.webkit.messageHandlers.newSelectionDetected.postMessage(txt);
        """) { (result, error) in
            print(result ?? "", error ?? "")
        }
    }
*/
    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebBrowserView
        var pubb = ""
        var book = 0
        var chapter = 0

        init(parent: WebBrowserView) {
            self.parent = parent
        }

        public func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) {
            // ...
        }

        public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
            // ...
        }

        public func webView(_ webView: WKWebView, didFinish: WKNavigation!) {
            webView.evaluateJavaScript("document.querySelector('header').remove()") { (result, error) in print(result ?? "", error ?? "") }
            LocationManager.addLocation(pubb: pubb, book: book, chapter: chapter)
            restoreHighlight()
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            // ...
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

        public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            let body = message.body
            if let dict = body as? Dictionary<String, Int> {
                HighlightManager.addHighlight(color: dict["color"]!,
                                             identifier: dict["paragraph"]!,
                                             startToken: dict["startIndex"]!,
                                             endToken: dict["endIndex"]!,
                                             pubb: pubb,
                                             book: book,
                                             chapter: chapter)
                restoreHighlight()
            }
        }

        func restoreHighlight() {
            print("Restoring...")
            parent.webView.evaluateJavaScript("""
                for (var i = 1; i <= 8; i++) {
                    var elems = document.getElementsByClassName('highlightingcolor' + i);
                    while(elems[0]) {
                        unwrap(elems[0]);
                    }
                }
            """) { (_, _) in
                print("Removed all! ✅")
                for highlight: Highlight in HighlightManager.getHighlight(pubb: self.pubb, book: self.book, chapter: self.chapter) {
                    print("Adding highlight \(highlight.userMark.ID)...")
                    self.parent.webView.evaluateJavaScript("""
                        clearSelection();
                        var paragraph = defSpans[\(highlight.blockRange.identifier - 1)];
                        var highlighting = document.createElement("highlighting");
                        highlighting.classList.add('highlightingcolor\(highlight.userMark.color)');
                        var started = false;
                        var tokenCount = -1;
                        var nodesToAdd = [];
                        for (var i = 0; i < paragraph.childNodes.length; i++) {
                            if (paragraph.childNodes[i].tagName == "HIGHLIGHTING") {
                                tokenCount += paragraph.childNodes[i].querySelectorAll('selectable').length;
                            }
                            if (paragraph.childNodes[i].tagName == "SELECTABLE") {
                                tokenCount++;
                            }
                            if (paragraph.childNodes[i].tagName == "SELECTABLE" && tokenCount == \(highlight.blockRange.startToken)) {
                                started = true;
                            }
                            if (started) { // Credo non ci sia bisogno di controllare se
                                           // è un selectable perché una selezione non ne
                                           // contiene mai un'altra
                                nodesToAdd.push(paragraph.childNodes[i]);
                            }
                            if (paragraph.childNodes[i].tagName == "SELECTABLE" && tokenCount == \(highlight.blockRange.endToken)) {
                                started = false;
                            }
                        }
                        for (var i = 0; i < nodesToAdd.length; i++) {
                            if (i == 0) {
                                paragraph.insertBefore(highlighting, nodesToAdd[i]);
                            }
                            highlighting.appendChild(nodesToAdd[i]);
                        }
                    """) { (_, _) in
                        print("Added highlight \(highlight.userMark.ID)! ✅")
                    }
                }
            }
        }

        func highlightStuff(color: Int) {
            print("Highlighting...")
            parent.webView.evaluateJavaScript("""
                window.getSelection().anchorNode.parentElement.classList.add('selectionStart');
                window.getSelection().focusNode.parentElement.classList.add('selectionEnd');
                var started = false;
                for (var i = 0; i < defSpans.length; i++) {
                    var paragraph = defSpans[i];
                    var selectables = paragraph.getElementsByTagName("selectable");
                    var startIndex = -1;
                    var endIndex = -1;
                    for (var j = 0; j < selectables.length; j++) {
                        var selectable = selectables[j];
                        if (selectable.classList.contains('selectionStart')) {
                            started = true;
                            startIndex = j;
                        }
                        if (selectable.classList.contains('selectionEnd')) {
                            endIndex = j;
                            started = false;
                        }
                    }
                    if (started && startIndex == -1) {
                        startIndex = 0;
                    }
                    if (started && endIndex == -1) {
                        endIndex = selectables.length - 2;
                    }
                    if (endIndex > -1 && startIndex > -1) {
                        window.webkit.messageHandlers.toggleMessageHandler.postMessage({
                            "paragraph": i + 1,
                            "startIndex": startIndex,
                            "endIndex": endIndex,
                            "color": \(color),
                        });
                        window.getSelection().empty();
                        clearSelection();
                    }
                }
                clearSelection();
            """) { (_, _) in
                print("Highlight sent! ✅")
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
