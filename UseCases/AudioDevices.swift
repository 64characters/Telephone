//
//  AudioDevices.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

public struct AudioDevices {
    public let inputDevices: [AudioDevice]
    public let outputDevices: [AudioDevice]

    public init(inputDevices: [AudioDevice], outputDevices: [AudioDevice]) {
        self.inputDevices = inputDevices
        self.outputDevices = outputDevices
    }
}

extension AudioDevices: Equatable {}

public func ==(lhs: AudioDevices, rhs: AudioDevices) -> Bool {
    return lhs.inputDevices == rhs.inputDevices && lhs.outputDevices == rhs.outputDevices
}

extension AudioDevices {
    init(systemAudioDevices: SystemAudioDevices) {
        let inputDevices = systemAudioDevices.inputDevices.map({ AudioDevice(systemAudioDevice: $0) })
        let outputDevices = systemAudioDevices.outputDevices.map({ AudioDevice(systemAudioDevice: $0) })
        self.init(inputDevices: inputDevices, outputDevices: outputDevices)
    }
}
