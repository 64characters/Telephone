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

    private var selection: ThrowingInteractor = NullThroingInteractor()

    init(factory: InteractorFactory) {
        self.factory = factory
    }

    func selectUserAgentSoundIO(userAgent: UserAgent) throws {
        try selection.execute()
        selection = NullThroingInteractor()
    }
}

extension UserAgentSoundIOSelector: UserAgentEventTarget {
    func userAgentDidFinishStarting(userAgent: UserAgent) {
        selection = factory.createUserAgentSoundIOSelectionInteractor(userAgent: userAgent)
    }

    func userAgentDidFinishStopping(userAgent: UserAgent) {
        selection = NullThroingInteractor()
    }

    func userAgentDidMakeCall(userAgent: UserAgent) {
        selectIOOrLogError(userAgent)
    }

    func userAgentDidReceiveCall(userAgent: UserAgent) {
        selectIOOrLogError(userAgent)
    }

    private func selectIOOrLogError(userAgent: UserAgent) {
        do {
            try selectUserAgentSoundIO(userAgent)
        } catch {
            print("Could not automatically select user agent audio devices: \(error)")
        }
    }

    func userAgentDidDetectNAT(userAgent: UserAgent) {}
}
