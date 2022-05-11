//
//  UserAgentEventsUserAgentSoundIOSelectionUseCase.swift
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

public final class UserAgentEventsUserAgentSoundIOSelectionUseCase {
    private var selection: ThrowingUseCase?

    private let useCase: ThrowingUseCase
    private let agent: UserAgent
    private let calls: Calls

    public init(useCase: ThrowingUseCase, agent: UserAgent, calls: Calls) {
        self.useCase = useCase
        self.agent = agent
        self.calls = calls
    }
}

extension UserAgentEventsUserAgentSoundIOSelectionUseCase: UseCase {
    public func execute() {
        selection = useCase
        selectSoundIOOrLogErrorIfNeeded()
    }

    private func selectSoundIOOrLogErrorIfNeeded() {
        if calls.haveActive {
            selectSoundIOOrLogError()
        }
    }

    private func selectSoundIOOrLogError() {
        do {
            try selectSoundIO()
        } catch {
            print("Could not automatically select user agent audio devices: \(error)")
        }
    }

    private func selectSoundIO() throws {
        try selection?.execute()
        selection = nil
    }
}

extension UserAgentEventsUserAgentSoundIOSelectionUseCase: UserAgentEventTarget {
    public func didFinishStarting(_ agent: UserAgent) {
        execute()
    }

    public func didFinishStopping(_ agent: UserAgent) {
        selection = nil
    }

    public func didMakeCall(_ agent: UserAgent) {
        selectSoundIOOrLogError()
    }

    public func didReceiveCall(_ agent: UserAgent) {
        selectSoundIOOrLogError()
    }

    public func didDetectNAT(_ agent: UserAgent) {}
}
