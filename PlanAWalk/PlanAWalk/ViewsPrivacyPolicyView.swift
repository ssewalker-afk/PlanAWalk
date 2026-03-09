//
//  PrivacyPolicyView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/9/26.
//

import SwiftUI
import WebKit

struct PrivacyPolicyView: View {
    var body: some View {
        WebView(htmlFileName: "privacy-policy")
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebView: UIViewRepresentable {
    let htmlFileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let htmlPath = Bundle.main.path(forResource: htmlFileName, ofType: "html") else {
            let errorHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body {
                        font-family: -apple-system;
                        padding: 20px;
                        text-align: center;
                    }
                </style>
            </head>
            <body>
                <h2>Privacy Policy Not Found</h2>
                <p>Unable to load the privacy policy.</p>
            </body>
            </html>
            """
            webView.loadHTMLString(errorHTML, baseURL: nil)
            return
        }
        
        do {
            let htmlContent = try String(contentsOfFile: htmlPath, encoding: .utf8)
            webView.loadHTMLString(htmlContent, baseURL: Bundle.main.bundleURL)
        } catch {
            let errorHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body {
                        font-family: -apple-system;
                        padding: 20px;
                        text-align: center;
                    }
                </style>
            </head>
            <body>
                <h2>Error Loading Privacy Policy</h2>
                <p>\(error.localizedDescription)</p>
            </body>
            </html>
            """
            webView.loadHTMLString(errorHTML, baseURL: nil)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
