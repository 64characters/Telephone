//
//  UserAgentSoundIOSelectionUseCase.swift
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

import Domain

public final class UserAgentSoundIOSelectionUseCase {
    fileprivate let repository: SystemAudioDeviceRepository
    fileprivate let userAgent: UserAgent
    fileprivate let settings: KeyValueSettings
    fileprivate var devices: SystemAudioDevices!
    fileprivate var deviceMap: SystemToUserAgentAudioDeviceMap!
    fileprivate var soundIO: SoundIO!

    public init(repository: SystemAudioDeviceRepository, userAgent: UserAgent, settings: KeyValueSettings) {
        self.repository = repository
        self.userAgent = userAgent
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
        devices = SystemAudioDevices(devices: try repository.allDevices())
    }

    private func updateDeviceMap() throws {
        deviceMap = SystemToUserAgentAudioDeviceMap(
            systemDevices: devices.all,
            userAgentDevices: try userAgent.audioDevices().map(domainAudioDevice)
        )
    }

    private func updateSoundIO() {
        soundIO = PreferredSoundIO(devices: devices, settings: settings)
    }

    private func selectUserAgentSoundIO() throws {
        try userAgent.selectSoundIODeviceIDs(
            input: deviceMap.userAgentDevice(for: soundIO.input).identifier,
            output: deviceMap.userAgentDevice(for: soundIO.output).identifier
        )
    }

    private func domainAudioDevice(with device: UserAgentAudioDevice) -> Domain.UserAgentAudioDevice {
        return Domain.SimpleUserAgentAudioDevice(device: device)
    }
}
