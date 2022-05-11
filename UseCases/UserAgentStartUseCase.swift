//
//  UserAgentStartUseCase.swift
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

public final class UserAgentStartUseCase {
    private lazy var purchaseCheck: UseCase = {
        return self.factory.make(output: WeakPurchaseCheckUseCaseOutput(origin: self))
    }()

    private let agent: UserAgent
    private let factory: PurchaseCheckUseCaseFactory

    public init(agent: UserAgent, factory: PurchaseCheckUseCaseFactory) {
        self.agent = agent
        self.factory = factory
    }
}

extension UserAgentStartUseCase: UseCase {
    public func execute() {
        purchaseCheck.execute()
    }
}

extension UserAgentStartUseCase: PurchaseCheckUseCaseOutput {
    public func didCheckPurchase(expiration: Date) {
        agent.maxCalls = 30
        agent.start()
    }

    public func didFailCheckingPurchase() {
        agent.maxCalls = 3
        agent.start()
    }
}
