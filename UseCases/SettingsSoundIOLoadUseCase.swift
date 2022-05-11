//
//  SettingsSoundIOLoadUseCase.swift
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

public protocol SettingsSoundIOLoadUseCaseOutput: AnyObject {
    func update(soundIO: SystemDefaultingSoundIO, devices: SystemAudioDevices)
}

public final class SettingsSoundIOLoadUseCase {
    private let factory: SystemAudioDevicesFactory
    private let settings: KeyValueSettings
    private let output: SettingsSoundIOLoadUseCaseOutput

    public init(factory: SystemAudioDevicesFactory, settings: KeyValueSettings, output: SettingsSoundIOLoadUseCaseOutput) {
        self.factory = factory
        self.settings = settings
        self.output = output
    }
}

extension SettingsSoundIOLoadUseCase: ThrowingUseCase {
    public func execute() throws {
        let devices = try factory.make()
        output.update(
            soundIO: SystemDefaultingSoundIO(SettingsSoundIO(devices: devices, settings: settings)), devices: devices
        )
    }
}
