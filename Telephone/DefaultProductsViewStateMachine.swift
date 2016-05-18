//
//  DefaultProductsViewStateMachine.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

class DefaultProductsViewStateMachine {
    private var state: State = .NoProducts
    private let transitions: [Transition]

    init(target: ProductsViewStateMachineTarget) {
        transitions = [
            Transition(state: .NoProducts,    event: .ViewShouldReload, newState: .Fetching,      action: target.fetchProducts),
            Transition(state: .NoProducts,    event: .DidClickReload,   newState: .Fetching,      action: target.fetchProducts),
            Transition(state: .NoProducts,    event: .DidClickRestore,  newState: .Restoring,     action: target.restorePurchases),

            Transition(state: .Fetching,      event: .DidFetch,         newState: .Fetched,       action: target.showProducts),
            Transition(state: .Fetching,      event: .FetchDidFail,     newState: .FetchError,    action: target.showProductFetchError),
            Transition(state: .FetchError,    event: .ViewShouldReload, newState: .Fetching,      action: target.fetchProducts),
            Transition(state: .FetchError,    event: .DidClickReload,   newState: .Fetching,      action: target.fetchProducts),
            Transition(state: .FetchError,    event: .DidClickRestore,  newState: .Restoring,     action: target.restorePurchases),
            Transition(state: .Fetched,       event: .DidClickPurchase, newState: .Purchasing,    action: target.purchase),
            Transition(state: .Fetched,       event: .DidClickRestore,  newState: .Restoring,     action: target.restorePurchases),

            Transition(state: .Purchasing,    event: .DidPurchase,      newState: .Purchased,     action: target.showThankYou),
            Transition(state: .Purchasing,    event: .PurchaseDidFail,  newState: .PurchaseError, action: target.showPurchaseError),
            Transition(state: .PurchaseError, event: .DidClickPurchase, newState: .Purchasing,    action: target.purchase),
            Transition(state: .PurchaseError, event: .DidClickRestore,  newState: .Restoring,     action: target.restorePurchases),
            Transition(state: .Purchased,     event: .ViewShouldReload, newState: .Purchased,     action: target.showThankYou),

            Transition(state: .Restoring,     event: .DidRestore,       newState: .Purchased,     action: target.showThankYou),
            Transition(state: .Restoring,     event: .RestoreDidFail,   newState: .RestoreError,  action: target.showRestoreError),
            Transition(state: .RestoreError,  event: .DidClickRestore,  newState: .Restoring,     action: target.restorePurchases)
        ]
    }
}

extension DefaultProductsViewStateMachine: ProductsViewStateMachine {
    func handleEvent(event: ProductsViewStateMachineEvent) {
        for t in transitions {
            if t.state == state && t.event == event {
                state = t.newState
                t.action()
                break
            }
        }
    }
}

private enum State {
    case NoProducts
    case Fetching
    case Fetched
    case FetchError
    case Purchasing
    case Purchased
    case PurchaseError
    case Restoring
    case RestoreError
}

private struct Transition {
    let state: State
    let event: ProductsViewStateMachineEvent
    let newState: State
    let action: () -> Void
}
