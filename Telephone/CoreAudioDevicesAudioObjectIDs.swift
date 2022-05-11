//
//  CoreAudioDeviceIDs.swift
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

import CoreAudio

final class CoreAudioDevicesAudioObjectIDs {
    private let object: CoreAudioObject

    init() {
        object = CoreAudioObject(
            objectID: AudioObjectID(kAudioObjectSystemObject),
            propertyAddress: AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDevices,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMaster
            )
        )
    }

    func all() throws -> [AudioObjectID] {
        return try makeDeviceIDs(length: try object.propertyDataLength())
    }

    private func makeDeviceIDs(length: UInt32) throws -> [AudioObjectID] {
        let bytes = UnsafeMutablePointer<AudioObjectID>.allocate(capacity: audioObjectIDCount(length: length))
        defer { bytes.deallocate() }
        var usedLength = length
        try copyDeviceIDsBytes(to: bytes, length: &usedLength)
        return audioObjectIDs(bytes: bytes, length: usedLength)
    }

    private func copyDeviceIDsBytes(to bytes: UnsafeMutablePointer<AudioObjectID>, length: inout UInt32) throws {
        return try object.copyPropertyValueBytes(to: bytes, length: &length)
    }
}

private func audioObjectIDs(bytes: UnsafeMutablePointer<AudioObjectID>, length: UInt32) -> [AudioObjectID] {
    return [AudioObjectID](UnsafeMutableBufferPointer<AudioObjectID>(start: bytes, count: audioObjectIDCount(length: length)))
}

private func audioObjectIDCount(length: UInt32) -> Int {
    return objectCount(ofType: AudioObjectID.self, inMemoryLength: Int(length))
}
