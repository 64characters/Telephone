//
//  UserAgentSoundIOSelectionInteractor.swift
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

public class UserAgentSoundIOSelectionInteractor {
    public let repository: SystemAudioDeviceRepository
    public let userAgent: UserAgent
    public let userDefaults: UserDefaults

    private var devices: SystemAudioDevices!
    private var deviceMap: SystemToUserAgentAudioDeviceMap!
    private var soundIO: SoundIO!

    public init(repository: SystemAudioDeviceRepository, userAgent: UserAgent, userDefaults: UserDefaults) {
        self.repository = repository
        self.userAgent = userAgent
        self.userDefaults = userDefaults
    }
}

extension UserAgentSoundIOSelectionInteractor: ThrowingInteractor {
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
            userAgentDevices: try userAgent.audioDevices().map(domainWithUseCaseUserAgentAudioDevice)
        )
    }

    private func updateSoundIO() {
        soundIO = PreferredSoundIO(devices: devices, userDefaults: userDefaults)
    }

    private func selectUserAgentSoundIO() throws {
        try userAgent.selectSoundIODeviceIDs(
            input: deviceMap.userAgentDeviceForSystemDevice(soundIO.input).identifier,
            output: deviceMap.userAgentDeviceForSystemDevice(soundIO.output).identifier
        )
    }

    private func domainWithUseCaseUserAgentAudioDevice(device: UserAgentAudioDevice) -> Domain.UserAgentAudioDevice {
        return Domain.SimpleUserAgentAudioDevice(device: device)
    }
}
