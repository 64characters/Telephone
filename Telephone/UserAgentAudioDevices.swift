//
//  UserAgentAudioDevices.swift
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
import UseCases

struct UserAgentAudioDevices {
    let all: [UserAgentAudioDevice]

    init() throws {
        all = try makeDevices()
    }
}

private func makeDevices() throws -> [UserAgentAudioDevice] {
    let bytes = UnsafeMutablePointer<pjmedia_aud_dev_info>.allocate(capacity: bufferSize)
    var count = UInt32(bufferSize)
    try copyDevicesBytes(to: bytes, count: &count)
    let result = devices(with: bytes, count: Int(count))
    bytes.deallocate()
    return result
}

private func copyDevicesBytes(to bytes: UnsafeMutablePointer<pjmedia_aud_dev_info>, count: inout UInt32) throws {
    if pjsua_enum_aud_devs(bytes, &count) != 0 {
        throw UserAgentError.audioDeviceEnumerationError
    }
}

private func devices(with bytes: UnsafeMutablePointer<pjmedia_aud_dev_info>, count: Int) -> [UserAgentAudioDevice] {
    return devices(with: UnsafeBufferPointer<pjmedia_aud_dev_info>(start: bytes, count: count))
}

private func devices(with pointer: UnsafeBufferPointer<pjmedia_aud_dev_info>) -> [UserAgentAudioDevice] {
    return pointer.enumerated().map { SimpleUserAgentAudioDevice(device: $0.element, identifier: $0.offset) }
}

private let bufferSize = 32
