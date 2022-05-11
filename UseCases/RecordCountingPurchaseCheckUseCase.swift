//
//  RecordCountingPurchaseCheckUseCase.swift
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

@objc public protocol RecordCountingPurchaseCheckUseCaseOutput {
    func didCheckPurchase()
    func didFailCheckingPurchase(recordCount count: Int)
}

public final class RecordCountingPurchaseCheckUseCase {
    private lazy var origin: UseCase = {
        return self.factory.make(output: WeakPurchaseCheckUseCaseOutput(origin: self))
    }()
    private var count = 0

    private let factory: PurchaseCheckUseCaseFactory
    private let output: RecordCountingPurchaseCheckUseCaseOutput

    public init(factory: PurchaseCheckUseCaseFactory, output: RecordCountingPurchaseCheckUseCaseOutput) {
        self.factory = factory
        self.output = output
    }
}

extension RecordCountingPurchaseCheckUseCase: CallHistoryRecordGetAllUseCaseOutput {
    public func update(records: [CallHistoryRecord]) {
        count = records.count
        origin.execute()
    }
}

extension RecordCountingPurchaseCheckUseCase: PurchaseCheckUseCaseOutput {
    public func didCheckPurchase(expiration: Date) {
        output.didCheckPurchase()
    }

    public func didFailCheckingPurchase() {
        output.didFailCheckingPurchase(recordCount: count)
    }
}
