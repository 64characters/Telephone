//
//  UserAgentSoundIOSelector.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov
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
    let interactorFactory: InteractorFactory

    init(interactorFactory: InteractorFactory) {
        self.interactorFactory = interactorFactory
    }

    func selectUserAgentSoundIO(userAgent: UserAgent) throws {
        let interactor = interactorFactory.createUserAgentSoundIOSelectionInteractorWithUserAgent(userAgent)
        try interactor.execute()
    }
}

extension UserAgentSoundIOSelector: UserAgentObserver {
    func userAgentDidFinishStarting(userAgent: UserAgent) {
        do {
            try selectUserAgentSoundIO(userAgent)
        } catch {
            print("Could not automatically select user agent audio devices: \(error)")
        }
    }

    func userAgentDidFinishStopping(userAgent: UserAgent) {}
    func userAgentDidDetectNAT(userAgent: UserAgent) {}
}
