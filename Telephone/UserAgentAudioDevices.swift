//
//  UserAgentAudioDevices.swift
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

import UseCases

struct UserAgentAudioDevices {
    let all: [UserAgentAudioDevice]

    init() throws {
        all = try createDevices()
    }
}

private func createDevices() throws -> [UserAgentAudioDevice] {
    let bytes = UnsafeMutablePointer<pjmedia_aud_dev_info>.alloc(kBufferSize)
    var count = UInt32(kBufferSize)
    try getDevicesBytes(bytes, count: &count)
    let result = devicesWithBytes(bytes, count: Int(count))
    bytes.dealloc(kBufferSize)
    return result
}

private func getDevicesBytes(bytes: UnsafeMutablePointer<pjmedia_aud_dev_info>, inout count: UInt32) throws {
    let status = pjsua_enum_aud_devs(bytes, &count)
    if status != 0 {
        throw TelephoneError.UserAgentAudioDeviceEnumerationError
    }
}

private func devicesWithBytes(bytes: UnsafeMutablePointer<pjmedia_aud_dev_info>, count: Int) -> [UserAgentAudioDevice] {
    let buffer = UnsafeBufferPointer<pjmedia_aud_dev_info>(start: bytes, count: count)
    return devicesWithBuffer(buffer)
}

private func devicesWithBuffer(pointer: UnsafeBufferPointer<pjmedia_aud_dev_info>) -> [UserAgentAudioDevice] {
    var index = 0
    return pointer.map { deviceInfo -> UserAgentAudioDevice in
        return UserAgentAudioDevice(identifier: index++, name: nameWithDeviceInfo(deviceInfo))
    }
}

private func nameWithDeviceInfo(device: pjmedia_aud_dev_info) -> String {
    let name = String.fromBytes(device.name)
    return name == nil ? "Unknown Device Name" : name!
}

private let kBufferSize = 32
