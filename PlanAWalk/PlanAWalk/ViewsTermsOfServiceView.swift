//
//  TermsOfServiceView.swift
//  PlanAWalk
//
//  Created by Sarah Walker on 3/9/26.
//

import SwiftUI
import WebKit

struct TermsOfServiceView: View {
    var body: some View {
        WebView(htmlFileName: "TermsOfService")
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
