//
//  UserAgentAudioDevice.swift
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

public struct UserAgentAudioDevice {
    public let identifier: Int
    public let name: String

    public init(let identifier: Int, let name: String) {
        self.identifier = identifier
        self.name = name
    }
}

extension UserAgentAudioDevice: Equatable {}

public func ==(lhs: UserAgentAudioDevice, rhs: UserAgentAudioDevice) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.name == rhs.name
}
