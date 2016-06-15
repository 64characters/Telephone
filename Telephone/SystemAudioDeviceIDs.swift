//
//  SystemAudioDeviceIDs.swift
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

import CoreAudio

class SystemAudioDeviceIDs {
    private var audioObject: SystemAudioObject

    init() {
        let objectID = AudioObjectID(kAudioObjectSystemObject)
        let propertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
        audioObject = SystemAudioObject(objectID: objectID, propertyAddress: propertyAddress)
    }

    func all() throws -> [Int] {
        let length = try audioObject.propertyDataLength()
        return try deviceIDsWithLength(length)
    }

    private func deviceIDsWithLength(length: UInt32) throws -> [Int] {
        let count = audioObjectIDCountWithLength(length)
        let bytes = UnsafeMutablePointer<AudioObjectID>.alloc(count)
        defer { bytes.dealloc(count) }
        var usedLength = length
        try getDeviceIDsBytes(bytes, length: &usedLength)
        return deviceIDsWithBytes(bytes, length: usedLength)
    }

    private func getDeviceIDsBytes(bytes: UnsafeMutablePointer<AudioObjectID>, inout length: UInt32) throws {
        return try audioObject.getPropertyValueBytes(bytes, length: &length)
    }
}

private func deviceIDsWithBytes(bytes: UnsafeMutablePointer<AudioObjectID>, length: UInt32) -> [Int] {
    let audioObjectIDs = audioObjectIDsWithBytes(bytes, length: length)
    return audioObjectIDs.map { Int($0) }
}

private func audioObjectIDsWithBytes(bytes: UnsafeMutablePointer<AudioObjectID>, length: UInt32) -> [AudioObjectID] {
    let buffer = UnsafeMutableBufferPointer<AudioObjectID>(start: bytes, count: audioObjectIDCountWithLength(length))
    return [AudioObjectID](buffer)
}

private func audioObjectIDCountWithLength(length: UInt32) -> Int {
    return objectCount(ofType: AudioObjectID.self, inMemoryLength: Int(length))
}
