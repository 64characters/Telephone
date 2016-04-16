//
//  DelayingUserAgentSoundIOSelectionInteractor.swift
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

public class DelayingUserAgentSoundIOSelectionInteractor {
    public let interactor: ThrowingInteractor
    public let userAgent: UserAgent

    private var selection: ThrowingInteractor = NullThrowingInteractor()

    public init(interactor: ThrowingInteractor, userAgent: UserAgent) {
        self.interactor = interactor
        self.userAgent = userAgent
    }
}

extension DelayingUserAgentSoundIOSelectionInteractor: Interactor {
    public func execute() {
        selection = interactor
        selectSoundIOOrLogErrorIfNeeded()
    }

    private func selectSoundIOOrLogErrorIfNeeded() {
        if userAgent.hasActiveCalls {
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
        try selection.execute()
        selection = NullThrowingInteractor()
    }
}

extension DelayingUserAgentSoundIOSelectionInteractor: UserAgentEventTarget {
    public func userAgentDidFinishStarting(userAgent: UserAgent) {
        execute()
    }

    public func userAgentDidFinishStopping(userAgent: UserAgent) {
        selection = NullThrowingInteractor()
    }

    public func userAgentDidMakeCall(userAgent: UserAgent) {
        selectSoundIOOrLogError()
    }

    public func userAgentDidReceiveCall(userAgent: UserAgent) {
        selectSoundIOOrLogError()
    }

    public func userAgentDidDetectNAT(userAgent: UserAgent) {}
}

extension DelayingUserAgentSoundIOSelectionInteractor: SystemAudioDevicesChangeEventTarget {
    public func systemAudioDevicesDidUpdate() {
        execute()
    }
}
