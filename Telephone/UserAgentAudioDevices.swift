//
//  UserAgentAudioDevices.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

import UseCases

struct UserAgentAudioDevices {
    let all: [UserAgentAudioDevice]

    init() throws {
        all = try createDevices()
    }
}

private func createDevices() throws -> [UserAgentAudioDevice] {
    let bytes = UnsafeMutablePointer<pjmedia_aud_dev_info>.allocate(capacity: bufferSize)
    var count = UInt32(bufferSize)
    try copyDevicesBytes(to: bytes, count: &count)
    let result = devices(with: bytes, count: Int(count))
    bytes.deallocate(capacity: bufferSize)
    return result
}

private func copyDevicesBytes(to bytes: UnsafeMutablePointer<pjmedia_aud_dev_info>, count: inout UInt32) throws {
    let status = pjsua_enum_aud_devs(bytes, &count)
    if status != 0 {
        throw UserAgentError.audioDeviceEnumerationError
    }
}

private func devices(with bytes: UnsafeMutablePointer<pjmedia_aud_dev_info>, count: Int) -> [UserAgentAudioDevice] {
    let buffer = UnsafeBufferPointer<pjmedia_aud_dev_info>(start: bytes, count: count)
    return devices(with: buffer)
}

private func devices(with pointer: UnsafeBufferPointer<pjmedia_aud_dev_info>) -> [UserAgentAudioDevice] {
    var index = 0
    return pointer.map { device -> UserAgentAudioDevice in
        let result = UserAgentAudioDevice(device: device, identifier: index)
        index += 1
        return result
    }
}

private let bufferSize = 32
