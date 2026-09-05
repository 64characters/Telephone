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
    let target: StoreEventTarget

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
        .subscriptionStoreControlStyle(.prominentPicker)
        .frame(minWidth: 450, minHeight: 650)
        .onInAppPurchaseCompletion { _, result in
            if case .success(.success(let verification)) = result, case .verified(let transaction) = verification {
                await transaction.finish()
                await target.didPurchase()
            }
        }
    }
}

#Preview {
    StoreKitStoreView(target: NullStoreEventTarget())
}

private final class NullStoreEventTarget: StoreEventTarget {
    func didPurchase() async {}
}
