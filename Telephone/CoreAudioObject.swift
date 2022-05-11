//
//  SystemAudioObject.swift
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

final class CoreAudioObject {
    private let objectID: AudioObjectID
    private var propertyAddress: AudioObjectPropertyAddress

    init(objectID: AudioObjectID, propertyAddress: AudioObjectPropertyAddress) {
        self.objectID = objectID
        self.propertyAddress = propertyAddress
    }

    func propertyDataLength() throws -> UInt32 {
        var length: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(objectID, &propertyAddress, 0, nil, &length)
        if status != noErr {
            throw TelephoneError.systemAudioDevicePropertyDataSizeGetError(systemErrorCode: Int(status))
        }
        return length
    }

    func copyPropertyValueBytes(to bytes: UnsafeMutableRawPointer, length: inout UInt32) throws {
        let status = AudioObjectGetPropertyData(objectID, &propertyAddress, 0, nil, &length, bytes)
        if status != noErr {
            throw TelephoneError.systemAudioDevicePropertyDataGetError(systemErrorCode: Int(status))
        }
    }
}

func objectCount<T>(ofType type: T.Type, inMemoryLength length: Int) -> Int {
    return Int(ceil(Double(length) / Double(MemoryLayout<T>.stride)))
}
