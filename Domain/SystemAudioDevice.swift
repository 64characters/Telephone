//
//  SystemAudioDevice.swift
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

public struct SystemAudioDevice {
    public let identifier: Int
    public let uniqueIdentifier: String
    public let name: String
    public let inputCount: Int
    public let outputCount: Int
    public let builtIn: Bool

    public init(identifier: Int, uniqueIdentifier: String, name: String, inputCount: Int, outputCount: Int, builtIn: Bool) {
        self.identifier = identifier
        self.uniqueIdentifier = uniqueIdentifier
        self.name = name
        self.inputCount = inputCount
        self.outputCount = outputCount
        self.builtIn = builtIn
    }
}

public extension SystemAudioDevice {
    public var inputDevice: Bool {
        return inputCount > 0
    }

    public var outputDevice: Bool {
        return outputCount > 0
    }

    public var builtInInputDevice: Bool {
        return builtIn && inputDevice
    }

    public var builtInOutputDevice: Bool {
        return builtIn && outputDevice
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
        lhs.inputCount == rhs.inputCount &&
        lhs.outputCount == rhs.outputCount &&
        lhs.builtIn == rhs.builtIn
}
