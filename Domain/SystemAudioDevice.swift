//
//  SystemAudioDevice.swift
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

public struct SystemAudioDevice {
    public let identifier: Int
    public let uniqueIdentifier: String
    public let name: String
    public let inputs: Int
    public let outputs: Int
    public let builtIn: Bool

    public init(identifier: Int, uniqueIdentifier: String, name: String, inputs: Int, outputs: Int, builtIn: Bool) {
        self.identifier = identifier
        self.uniqueIdentifier = uniqueIdentifier
        self.name = name
        self.inputs = inputs
        self.outputs = outputs
        self.builtIn = builtIn
    }
}

public extension SystemAudioDevice {
    public var hasInputs: Bool {
        return inputs > 0
    }

    public var hasOutputs: Bool {
        return outputs > 0
    }

    public var builtInInput: Bool {
        return builtIn && hasInputs
    }

    public var builtInOutput: Bool {
        return builtIn && hasOutputs
    }
}

extension SystemAudioDevice: Hashable {
    public var hashValue: Int {
        return identifier
    }
}

extension SystemAudioDevice: Equatable {}

public func ==(lhs: SystemAudioDevice, rhs: SystemAudioDevice) -> Bool {
    return lhs.identifier == rhs.identifier &&
        lhs.uniqueIdentifier == rhs.uniqueIdentifier &&
        lhs.name == rhs.name &&
        lhs.inputs == rhs.inputs &&
        lhs.outputs == rhs.outputs &&
        lhs.builtIn == rhs.builtIn
}
