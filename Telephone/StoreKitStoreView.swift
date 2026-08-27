//
//  StoreKitStoreView.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

import StoreKit
import SwiftUI

struct StoreKitStoreView: View {
    var body: some View {
        SubscriptionStoreView(productIDs: ["com.tlphn.Telephone.iap.month", "com.tlphn.Telephone.iap.year"]) {
            VStack {
                Text("Telephone Pro")
                    .font(.largeTitle)
                    .bold()
                Text("Unlock the full call history, 30 simultaneous calls, and support ongoing app development.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .storeButton(.visible, for: .restorePurchases)
        .storeButton(.visible, for: .policies)
        .storeButton(.hidden, for: .cancellation)
        .subscriptionStorePolicyDestination(
            url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, for: .termsOfService
        )
        .subscriptionStorePolicyDestination(url: URL(string: "https://www.64characters.com/privacy/")!, for: .privacyPolicy)
        .subscriptionStoreControlStyle(.prominentPicker)
        .frame(maxHeight: 600)
    }
}

#Preview {
    StoreKitStoreView()
        .frame(height: 500)
}
