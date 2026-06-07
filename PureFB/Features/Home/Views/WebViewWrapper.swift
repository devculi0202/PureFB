//
//  WebViewWrapper.swift
//  PureFB
//
//  Created by Duy Le on 7/6/26.
//  📍 Location: Core/UIComponents/
//  🎯 Purpose: Reusable WKWebView wrapper for SwiftUI
//

import SwiftUI
import WebKit

/// SwiftUI wrapper for WKWebView
/// ✅ Single source of truth - không duplicate ở file khác
struct WebViewWrapper: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed - webView is managed externally
    }
}

// MARK: - Preview Support
#if DEBUG
struct WebViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        WebViewWrapper(webView: WKWebView())
            .ignoresSafeArea()
    }
}
#endif
