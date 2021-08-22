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
    @Binding var highlight: ((Int) -> Void)?

    public func makeNSView(context: NSViewRepresentableContext<WebBrowserView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.pub = pub
        context.coordinator.documentNumber = document?.documentId ?? 0
        let contentController = self.webView.configuration.userContentController
        contentController.add(context.coordinator, name: "toggleMessageHandler")
        return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebBrowserView>) {
        DispatchQueue.main.async { [self] in // https://stackoverflow.com/a/64105515/14721889
            self.highlight = { i in
                if i > 0 || i == -1 {
                    context.coordinator.highlightStuff(color: i)
                }
            }
        }
    }

    private let webView: WKWebView = WKWebView()
    private let nsView: NSView = NSView()
    let filePath: String
    let pub: Publication
    let document: Document?

    public func load(url: URL) {
        webView.load(URLRequest(url: url))
    }

    public mutating func load() {
        let article = (try? String(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent(filePath), encoding: .utf8)) ?? ""
        let meta = "<meta charset='UTF-8'>"
        let style = (try? String(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent("style.css"), encoding: .utf8)) ?? ""
        let script = (try? String(contentsOf: FileManager.getDocumentsDirectory().appendingPathComponent("script.js"), encoding: .utf8)) ?? ""
        let page = "<html><head>" + meta + "<style>" + style + "</style></head><body>" + article + "<script type=\"text/javascript\">" + script + "</script></body></html>"
        webView.loadHTMLString(page, baseURL: nil)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebBrowserView
        var pub: Publication = Publication(ID: 0, keySymbol: "", year: 0, mepsLanguageId: 0, publicationTypeId: 0, issueTagNumber: 0, title: "")
        var documentNumber: Int?

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
            if pub.isBible {
                webView.evaluateJavaScript("document.querySelector('header').remove();") { (result, error) in print(result ?? "", error ?? "") }
            } else {
                let images = JWPubManager.getDocumentImages(pub: pub, documentNumber: documentNumber!)
                if images.count > 0 {
                    for i in 0...(images.count - 1) {
                        let imgBase64 = images[i].base64EncodedString()
                        let query = """
                                        var img = document.querySelectorAll('img')[\(i)];
                                        img.src = 'data:image/jpeg;base64,\(imgBase64)';
                                        img.removeAttribute('data-img-small-src');
                                    """
                        print(query)
                        webView.evaluateJavaScript(query) { (result, error) in print(result ?? "", error ?? "") }
                    }
                }
            }
            LocationManager.addLocation(pub: pub, documentId: documentNumber)
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
                print("addHighlight(\(dict["paragraph"]!), \(dict["startIndex"]!), \(dict["endIndex"]!));")
                let newBlockRange = BlockRange(identifier: dict["paragraph"]!, startToken: dict["startIndex"]!, endToken: dict["endIndex"]!)
                HighlightManager.addHighlight(color: dict["color"]!,
                                             newBlockRange: newBlockRange,
                                             pub: pub,
                                             documentID: documentNumber)
                restoreHighlight()
            }
        }

        func restoreHighlight() {
            print("Restoring...")
            parent.webView.evaluateJavaScript("cleanBodyHighlight(); makeSelectable();") { (_, _) in
                print("Removed all! ✅")
                for highlight: Highlight in HighlightManager.getHighlight(pub: self.pub, documentID: self.documentNumber) {
                    print("Adding highlight \(highlight.userMark.ID)...")
                    print("restoreHighlight(\(highlight.blockRange.identifier), \(highlight.blockRange.startToken), \(highlight.blockRange.endToken), \(highlight.userMark.color), \(self.pub.isBible));")
                    if highlight.blockRange.identifier != -1 && highlight.blockRange.startToken != -1 && highlight.blockRange.endToken != -1 {
                        self.parent.webView.evaluateJavaScript("restoreHighlight(\(highlight.blockRange.identifier), \(highlight.blockRange.startToken), \(highlight.blockRange.endToken), \(highlight.userMark.color), \(self.pub.isBible));") { (_, _) in
                            print("Added highlight \(highlight.userMark.ID)! ✅")
                        }
                    }
                }
            }
        }

        func highlightStuff(color: Int) {
            print("Highlighting...")
            parent.webView.evaluateJavaScript("addHighlight(\(color), \(pub.isBible));") { (_, _) in
                print("Highlight sent! ✅")
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
