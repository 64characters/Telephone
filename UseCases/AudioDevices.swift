//
//  AudioDevices.swift
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

public struct AudioDevices: Equatable {
    public let input: [AudioDevice]
    public let output: [AudioDevice]

    public init(input: [AudioDevice], output: [AudioDevice]) {
        self.input = input
        self.output = output
    }
}

extension AudioDevices {
    init(devices: SystemAudioDevices) {
        self.init(
            input: devices.input.map({ AudioDevice(device: $0) }),
            output: devices.output.map({ AudioDevice(device: $0) })
        )
    }
}
