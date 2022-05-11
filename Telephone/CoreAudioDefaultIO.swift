//
//  CoreAudioDefaultIO.swift
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

final class CoreAudioDefaultIO {
    private let input: CoreAudioObject
    private let output: CoreAudioObject

    init() {
        input = makeCoreAudioObject(selector: kAudioHardwarePropertyDefaultInputDevice)
        output = makeCoreAudioObject(selector: kAudioHardwarePropertyDefaultOutputDevice)
    }

    func inputID() throws -> AudioObjectID {
        return try makeAudioObjectID(input)
    }

    func outputID() throws -> AudioObjectID {
        return try makeAudioObjectID(output)
    }
}

private func makeCoreAudioObject(selector: AudioObjectPropertySelector) -> CoreAudioObject {
    return CoreAudioObject(
        objectID: AudioObjectID(kAudioObjectSystemObject),
        propertyAddress: AudioObjectPropertyAddress(
            mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster
        )
    )
}

private func makeAudioObjectID(_ object: CoreAudioObject) throws -> AudioObjectID {
    var result = AudioObjectID(0)
    var length = UInt32(MemoryLayout.stride(ofValue: result))
    try object.copyPropertyValueBytes(to: &result, length: &length)
    return result
}
