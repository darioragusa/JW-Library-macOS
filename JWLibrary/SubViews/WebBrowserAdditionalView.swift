//
//  WebBrowserAdditionalView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 27/08/21.
//

import Foundation
import WebKit
import SwiftUI
import AppKit

public struct WebBrowserAdditionalView: NSViewRepresentable {
    @Binding var citation: ((BibleVerses) -> Void)?
    let emptyPage = "<html><head></head><style>body{font-family:-apple-system;padding:4px;text-align:center}:root{color-scheme:light dark;}</style><body>Non ci sono contenuti aggiuntivi</body></html>"

    public func makeNSView(context: NSViewRepresentableContext<WebBrowserAdditionalView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.loadHTMLString(emptyPage, baseURL: nil)
        let contentController = self.webView.configuration.userContentController
        contentController.add(context.coordinator, name: "toggleMessageHandler")
        return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebBrowserAdditionalView>) {
        // Non so neanche io come ho fatto a far arrivare questa variabile qui ma ha funzionato a primo tentativo quindi si festeggia! 🥳
        unload()
        DispatchQueue.main.async { [self] in
            self.citation = { bibleVerses in
                context.coordinator.citation = bibleVerses
                load(bibleVerses: bibleVerses)
            }
        }
    }

    private let webView: WKWebView = WKWebView()
    private let nsView: NSView = NSView()

    public func load(url: URL) {
        webView.load(URLRequest(url: url))
    }

    func load(bibleVerses: BibleVerses) {
        let filePath = "nwt_I/\(bibleVerses.bookNumber)/\(bibleVerses.chapterNumber).html"
        let article = (try? String(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent(filePath), encoding: .utf8)) ?? ""
        let minstyle = """
            body {
                font-family: -apple-system;
                padding: 4px;
            }
            :root {
              color-scheme: light dark;
            }
            a {
                vertical-align: top;
                font-size: 0.75em;
                color: -webkit-text;
                text-decoration: none;
            }
        """
        let page = "<html><head><meta charset='UTF-8'><style>" + minstyle + "</style></head><body>" + article + "</body></html>"
        webView.loadHTMLString(page, baseURL: nil)
    }
    public func unload() {
        webView.loadHTMLString(emptyPage, baseURL: nil)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebBrowserAdditionalView
        var citation: BibleVerses = BibleVerses(bookNumber: 0, chapterNumber: 0, versesIds: [])

        init(parent: WebBrowserAdditionalView) {
            self.parent = parent
        }

        public func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) {
            // ...
        }

        public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
            // ...
        }

        public func webView(_ webView: WKWebView, didFinish: WKNavigation!) {
            if citation.bookNumber > 0 {
                let code = """
                    let sw = document.querySelectorAll('p.sw').length;
                    let min = \(citation.versesIds.min() ?? 0) - sw;
                    let max = \(citation.versesIds.max() ?? 0) - sw;
                    let verses = []
                    for (var i = min; i <= max; i++) {
                        let verse = document.querySelectorAll('[id^="v\(citation.bookNumber)-\(citation.chapterNumber)-' + i + '-"]');
                        for (var j = 0; j < verse.length; j++) {
                            verses.push(verse[j]);
                        }
                    }
                    document.body.innerHTML = "";
                    for (var i = 0; i < verses.length; i++) {
                        document.body.appendChild(verses[i]);
                        document.body.innerHTML += '<br>';
                    }
                """
                webView.evaluateJavaScript(code) { (_, _) in
                    // Un po' di pulizia
                    let cleancode = """
                        document.querySelectorAll('a.b').forEach(element => element.remove());
                        document.querySelectorAll('a.fn').forEach(element => element.remove());
                    """
                    webView.evaluateJavaScript(cleancode) { (_, _) in }
                }
            }
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
            // ...
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
