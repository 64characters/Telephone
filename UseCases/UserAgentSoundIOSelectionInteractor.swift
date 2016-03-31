//
//  UserAgentSoundIOSelectionInteractor.swift
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

import Domain

public class UserAgentSoundIOSelectionInteractor {
    public let repository: SystemAudioDeviceRepository
    public let userAgent: UserAgent
    public let userDefaults: UserDefaults

    private var devices: SystemAudioDevices!
    private var deviceMap: SystemToUserAgentAudioDeviceMap!
    private var soundIO: SelectedSystemSoundIO!

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
        let userAgentDevices = try userAgent.audioDevices().map(domainWithUseCaseUserAgentAudioDevice)
        deviceMap = SystemToUserAgentAudioDeviceMap(systemDevices: devices.all, userAgentDevices: userAgentDevices)
    }

    private func updateSoundIO() {
        soundIO = SelectedSystemSoundIO(devices: devices, userDefaults: userDefaults)
    }

    private func selectUserAgentSoundIO() throws {
        let input = deviceMap.userAgentDeviceForSystemDevice(soundIO.input)
        let output = deviceMap.userAgentDeviceForSystemDevice(soundIO.output)
        try userAgent.selectSoundIODeviceIDs(input: input.identifier, output: output.identifier)
    }

    private func domainWithUseCaseUserAgentAudioDevice(device: UserAgentAudioDevice) -> Domain.UserAgentAudioDevice {
        return Domain.SimpleUserAgentAudioDevice(device: device)
    }
}
