//
//  UserAgentSpy.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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

import Foundation
import UseCases

public class UserAgentSpy: NSObject {
    public private(set) var didCallAudioDevices = false
    public var audioDevicesResult = [UserAgentAudioDevice]()

    public private(set) var didCallUpdateAudioDevices = false

    public private(set) var didCallSelectInputAndOutputDevices = false
    public private(set) var selectedInputDeviceID: Int?
    public private(set) var selectedOutputDeviceID: Int?
}

extension UserAgentSpy: UserAgent {
    @objc(isStarted) public var started: Bool {
        return false
    }

    public func audioDevices() throws -> [UserAgentAudioDevice] {
        didCallAudioDevices = true
        return audioDevicesResult
    }

    public func updateAudioDevices() {
        didCallUpdateAudioDevices = true
    }

    public func selectSoundInputDevice(inputDeviceID: Int, outputDevice outputDeviceID: Int) throws {
        didCallSelectInputAndOutputDevices = true
        selectedInputDeviceID = inputDeviceID
        selectedOutputDeviceID = outputDeviceID
    }
}
