//
//  UserAgentSoundIOSelectionInteractor.swift
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

import Domain

public class UserAgentSoundIOSelectionInteractor {
    public let systemAudioDeviceRepository: SystemAudioDeviceRepository
    public let userAgent: UserAgent
    public let userDefaults: UserDefaults

    private var systemAudioDevices: SystemAudioDevices!
    private var deviceMap: SystemToUserAgentAudioDeviceMap!
    private var selectedSystemSoundIO: SelectedSystemSoundIO!

    public init(systemAudioDeviceRepository: SystemAudioDeviceRepository, userAgent: UserAgent, userDefaults: UserDefaults) {
        self.systemAudioDeviceRepository = systemAudioDeviceRepository
        self.userAgent = userAgent
        self.userDefaults = userDefaults
    }
}

extension UserAgentSoundIOSelectionInteractor: ThrowingInteractor {
    public func execute() throws {
        try updateSystemAudioDevices()
        try updateDeviceMap()
        try updateSelectedSystemSoundIO()
        try selectUserAgentSoundIO()
    }

    private func updateSystemAudioDevices() throws {
        systemAudioDevices = SystemAudioDevices(devices: try systemAudioDeviceRepository.allDevices())
    }

    private func updateDeviceMap() throws {
        let userAgentDevices = try userAgent.audioDevices().map(domainWithUseCaseUserAgentAudioDevice)
        deviceMap = SystemToUserAgentAudioDeviceMap(systemDevices: systemAudioDevices.allDevices, userAgentDevices: userAgentDevices)
    }

    private func updateSelectedSystemSoundIO() throws {
        selectedSystemSoundIO = try SelectedSystemSoundIO(systemAudioDevices: systemAudioDevices, userDefaults: userDefaults)
    }

    private func selectUserAgentSoundIO() throws {
        let input = try deviceMap.userAgentDeviceForSystemDevice(selectedSystemSoundIO.soundInput)
        let output = try deviceMap.userAgentDeviceForSystemDevice(selectedSystemSoundIO.soundOutput)
        try userAgent.selectSoundInputDevice(input.identifier, outputDevice: output.identifier)
    }

    private func domainWithUseCaseUserAgentAudioDevice(device: UserAgentAudioDevice) -> Domain.UserAgentAudioDevice {
        return Domain.UserAgentAudioDevice(device: device)
    }
}
