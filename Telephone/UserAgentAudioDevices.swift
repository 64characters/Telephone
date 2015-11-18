//
//  UserAgentAudioDevices.swift
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

struct UserAgentAudioDevices {
    let allDevices: [UserAgentAudioDevice]

    init() throws {
        allDevices = try createDevices()
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
