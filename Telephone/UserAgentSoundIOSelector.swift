//
//  UserAgentSoundIOSelector.swift
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

import UseCases

class UserAgentSoundIOSelector {
    let factory: InteractorFactory

    private var selection: ThrowingInteractor = NullThrowingInteractor()

    init(factory: InteractorFactory) {
        self.factory = factory
    }

    private func selectSoundIO(userAgent: UserAgent) throws {
        try selection.execute()
        selection = NullThrowingInteractor()
    }

    private func selectIOOrLogError(userAgent: UserAgent) {
        do {
            try selectSoundIO(userAgent)
        } catch {
            print("Could not automatically select user agent audio devices: \(error)")
        }
    }
}

extension UserAgentSoundIOSelector: UserAgentEventTarget {
    func userAgentDidFinishStarting(userAgent: UserAgent) {
        selection = factory.createUserAgentSoundIOSelectionInteractor(userAgent: userAgent)
    }

    func userAgentDidFinishStopping(userAgent: UserAgent) {
        selection = NullThrowingInteractor()
    }

    func userAgentDidMakeCall(userAgent: UserAgent) {
        selectIOOrLogError(userAgent)
    }

    func userAgentDidReceiveCall(userAgent: UserAgent) {
        selectIOOrLogError(userAgent)
    }

    func userAgentDidDetectNAT(userAgent: UserAgent) {}
}
