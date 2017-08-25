//
//  ObjCPurchaseCheckUseCase.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

@objc public protocol ObjCPurchaseCheckUseCaseOutput {
    func didCheckPurchase(expiration: Date)
    func didFailCheckingPurchase()
}

public final class ObjCPurchaseCheckUseCase: NSObject {
    fileprivate lazy var origin: UseCase = { return self.factory.makePurchaseCheckUseCase(output: self) }()

    private let factory: StoreUseCaseFactory
    fileprivate weak var output: ObjCPurchaseCheckUseCaseOutput?

    public init(factory: StoreUseCaseFactory, output: ObjCPurchaseCheckUseCaseOutput) {
        self.factory = factory
        self.output = output
    }
}

extension ObjCPurchaseCheckUseCase: UseCase {
    public func execute() {
        origin.execute()
    }
}

extension ObjCPurchaseCheckUseCase: PurchaseCheckUseCaseOutput {
    public func didCheckPurchase(expiration: Date) {
        output?.didCheckPurchase(expiration: expiration)
    }

    public func didFailCheckingPurchase() {
        output?.didFailCheckingPurchase()
    }
}
