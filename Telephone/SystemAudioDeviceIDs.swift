//
//  SystemAudioDeviceIDs.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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

final class SystemAudioDeviceIDs {
    private var audioObject: SystemAudioObject

    init() {
        let objectID = AudioObjectID(kAudioObjectSystemObject)
        let propertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
        audioObject = SystemAudioObject(objectID: objectID, propertyAddress: propertyAddress)
    }

    func all() throws -> [Int] {
        let length = try audioObject.propertyDataLength()
        return try makeDeviceIDs(with: length)
    }

    private func makeDeviceIDs(with length: UInt32) throws -> [Int] {
        let bytes = UnsafeMutablePointer<AudioObjectID>.allocate(capacity: audioObjectIDCount(with: length))
        defer { bytes.deallocate() }
        var usedLength = length
        try copyDeviceIDsBytes(to: bytes, length: &usedLength)
        return deviceIDs(bytes: bytes, length: usedLength)
    }

    private func copyDeviceIDsBytes(to bytes: UnsafeMutablePointer<AudioObjectID>, length: inout UInt32) throws {
        return try audioObject.copyPropertyValueBytes(to: bytes, length: &length)
    }
}

private func deviceIDs(bytes: UnsafeMutablePointer<AudioObjectID>, length: UInt32) -> [Int] {
    return audioObjectIDs(bytes: bytes, length: length).map { Int($0) }
}

private func audioObjectIDs(bytes: UnsafeMutablePointer<AudioObjectID>, length: UInt32) -> [AudioObjectID] {
    return [AudioObjectID](UnsafeMutableBufferPointer<AudioObjectID>(start: bytes, count: audioObjectIDCount(with: length)))
}

private func audioObjectIDCount(with length: UInt32) -> Int {
    return objectCount(ofType: AudioObjectID.self, inMemoryLength: Int(length))
}
