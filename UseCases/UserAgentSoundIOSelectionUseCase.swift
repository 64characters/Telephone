//
//  UserAgentSoundIOSelectionUseCase.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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

public final class UserAgentSoundIOSelectionUseCase {
    private var devices: SystemAudioDevices!
    private var deviceMap: SystemToUserAgentAudioDeviceMap!
    private var soundIO: SoundIO!

    private let factory: SystemAudioDevicesFactory
    private let agent: UserAgent
    private let settings: KeyValueSettings

    public init(factory: SystemAudioDevicesFactory, agent: UserAgent, settings: KeyValueSettings) {
        self.factory = factory
        self.agent = agent
        self.settings = settings
    }
}

extension UserAgentSoundIOSelectionUseCase: ThrowingUseCase {
    public func execute() throws {
        try updateDevices()
        try updateDeviceMap()
        updateSoundIO()
        try selectUserAgentSoundIO()
    }

    private func updateDevices() throws {
        devices = try factory.make()
    }

    private func updateDeviceMap() throws {
        deviceMap = SystemToUserAgentAudioDeviceMap(
            systemDevices: devices.all,
            userAgentDevices: try agent.audioDevices().map(domainAudioDevice)
        )
    }

    private func updateSoundIO() {
        soundIO = PreferredSoundIO(devices: devices, settings: settings)
    }

    private func selectUserAgentSoundIO() throws {
        try agent.selectSoundIODeviceIDs(
            input: deviceMap.userAgentDevice(for: soundIO.input).identifier,
            output: deviceMap.userAgentDevice(for: soundIO.output).identifier
        )
    }

    private func domainAudioDevice(with device: UserAgentAudioDevice) -> Domain.UserAgentAudioDevice {
        return Domain.SimpleUserAgentAudioDevice(device: device)
    }
}
