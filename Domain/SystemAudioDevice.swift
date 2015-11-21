//
//  SystemAudioDevice.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

public struct SystemAudioDevice {
    public let identifier: Int
    public let uniqueIdentifier: String
    public let name: String
    public let inputCount: Int
    public let outputCount: Int
    public let builtIn: Bool
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
