//
//  WebBrowserArticleView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 02/01/21.
//

import Foundation
import WebKit
import SwiftUI
import AppKit

public struct WebBrowserArticleView: NSViewRepresentable {
    @Binding var highlight: ((Int) -> Void)?
    @Binding var imgToShow: NSImage?
    @Binding var citation: ((BibleVerses) -> Void)?
    let filePath: String
    let pub: Publication
    let document: Document?

    public func makeNSView(context: NSViewRepresentableContext<WebBrowserArticleView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.pub = pub
        context.coordinator.document = document
        let contentController = self.webView.configuration.userContentController
        contentController.add(context.coordinator, name: "toggleMessageHandler")
        return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebBrowserArticleView>) {
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
        var parent: WebBrowserArticleView
        var pub: Publication = Publication(ID: 0, keySymbol: "", year: 0, mepsLanguageId: 0, publicationTypeId: 0, issueTagNumber: 0, title: "")
        var document: Document?
        var images: [NSData] = []
        @Binding var imgToShow: NSImage?
        @Binding var citation: ((BibleVerses) -> Void)?

        init(parent: WebBrowserArticleView, imgToShow: Binding<NSImage?>, citation: Binding<((BibleVerses) -> Void)?>) {
            self.parent = parent
            _imgToShow = imgToShow
            _citation = citation
        }

        public func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) {
            // ...
        }

        public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) {
            // ...
        }

        public func webView(_ webView: WKWebView, didFinish: WKNavigation!) {
            if pub.isBible {
                webView.evaluateJavaScript("document.querySelector('header').remove();") { (_, _) in }
            } else {
                images = JWPubManager.getDocumentImages(pub: pub, documentNumber: document?.documentId ?? 0)
                if images.count > 0 {
                    for i in 0...(images.count - 1) {
                        let imgBase64 = images[i].base64EncodedString() // https://stackoverflow.com/a/5304034/14721889
                        let jscode = """
                                        var img = document.querySelectorAll('img')[\(i)];
                                        img.src = 'data:image/jpeg;base64,\(imgBase64)';
                                        img.classList.remove("north_center");
                                        img.setAttribute("onClick", "javascript: showImg(\(i));");
                                        img.removeAttribute('data-img-small-src');
                                    """
                        webView.evaluateJavaScript(jscode) { (result, error) in print(result ?? "", error ?? "") }
                    }
                }
            }
            webView.evaluateJavaScript("initView(\(pub.isBible));") { (result, error) in
                print(result ?? "", error ?? "")
                webView.evaluateJavaScript("generateSelectable();") { (result, error) in
                    print(result ?? "", error ?? "")
                }
            }
            LocationManager.addLocation(pub: pub, documentId: document?.documentId ?? 0)
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
            if let dict = body as? [String: Int] {
                switch dict["mode"]! {
                case 0:
                    print("addHighlight(\(dict["paragraph"]!), \(dict["startIndex"]!), \(dict["endIndex"]!));")
                    let newBlockRange = BlockRange(identifier: dict["paragraph"]!, startToken: dict["startIndex"]!, endToken: dict["endIndex"]!)
                    HighlightManager.addHighlight(color: dict["color"]!,
                                                     newBlockRange: newBlockRange,
                                                     pub: pub,
                                                     documentID: document?.documentId ?? 0)
                    restoreHighlight()
                case 1:
                    if let image = NSImage(data: images[dict["imgIndex"]!] as Data) {
                        parent.imgToShow = image
                    }
                case 2:
                    let bibledbPath = FileManager.getDocumentsDirectory().appendingPathComponent("nwt_I/contents/nwt_I.db")
                    if FileManager().fileExists(atPath: bibledbPath.path) {
                        if let bibleVerses = PubBibleCitations.getBibleVerse(pub: pub,
                                                                             documentNumber: document?.ID ?? 0,
                                                                             paragraphOrdinal: dict["parOrdinal"]!,
                                                                             verseIndex: dict["elementNumber"]!) as BibleVerses? {
                            citation?(bibleVerses)
                        }
                    }
                default:
                    print("Come ci sei arrivato qui?")
                }
            }
        }

        func restoreHighlight() {
            print("Restoring...")
            parent.webView.evaluateJavaScript("cleanBodyHighlight(); makeSelectable();") { (_, _) in
                print("Removed all! ✅")
                for highlight: Highlight in HighlightManager.getHighlight(pub: self.pub, documentID: self.document?.documentId ?? 0) {
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

    public func makeCoordinator() -> Coordinator { // https://stackoverflow.com/a/58687096/14721889
        Coordinator(parent: self, imgToShow: $imgToShow, citation: $citation)
    }
}
