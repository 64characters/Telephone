//
//  UserAgentSpy.swift
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

import Domain
import UseCases

public final class UserAgentSpy {
    public var isStarted = false
    public var maxCalls = 0

    public var didCallStart = false

    public private(set) var didCallAudioDevices = false
    public var audioDevicesResult = [UserAgentAudioDevice]()

    public private(set) var didCallUpdateAudioDevices = false
    public private(set) var soundIOSelectionCallCount = 0
    public var didSelectSoundIO: Bool { return soundIOSelectionCallCount > 0 }

    public private(set) var invokedInputDeviceID: Int?
    public private(set) var invokedOutputDeviceID: Int?

    public init() {}
}

extension UserAgentSpy: UserAgent {
    public func start() {
        didCallStart = true
    }

    public func audioDevices() throws -> [UserAgentAudioDevice] {
        didCallAudioDevices = true
        return audioDevicesResult
    }

    public func updateAudioDevices() {
        didCallUpdateAudioDevices = true
    }

    public func selectSoundIODeviceIDs(input: Int, output: Int) throws {
        soundIOSelectionCallCount += 1
        invokedInputDeviceID = input
        invokedOutputDeviceID = output
    }
}
