//
//  SimpleSystemAudioDevice+CoreAudio.swift
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
import Domain

extension SimpleSystemAudioDevice {
    init(deviceID: AudioObjectID) throws {
        self.init(
            identifier: Int(deviceID),
            uniqueIdentifier: try makeUniqueIdentifier(deviceID: deviceID),
            name: try makeName(deviceID: deviceID),
            inputs: try makeInputCount(deviceID: deviceID),
            outputs: try makeOutputCount(deviceID: deviceID),
            isBuiltIn: try makeIsBuiltIn(deviceID: deviceID)
        )
    }
}

private func makeUniqueIdentifier(deviceID: AudioObjectID) throws -> String {
    return try stringPropertyValue(forDeviceWithID: deviceID, selector: kAudioDevicePropertyDeviceUID)
}

private func makeName(deviceID: AudioObjectID) throws -> String {
    return try stringPropertyValue(forDeviceWithID: deviceID, selector: kAudioObjectPropertyName)
}

private func makeInputCount(deviceID: AudioObjectID) throws -> Int {
    return try channelCount(with: AudioObjectID(deviceID), scope: kAudioObjectPropertyScopeInput)
}

private func makeOutputCount(deviceID: AudioObjectID) throws -> Int {
    return try channelCount(with: AudioObjectID(deviceID), scope: kAudioObjectPropertyScopeOutput)
}

private func makeIsBuiltIn(deviceID: AudioObjectID) throws -> Bool {
    let transportType: UInt32 = try propertyValue(forDeviceWithID: deviceID, selector: kAudioDevicePropertyTransportType)
    return transportType == kAudioDeviceTransportTypeBuiltIn
}

private func stringPropertyValue(forDeviceWithID deviceID: AudioObjectID, selector: AudioObjectPropertySelector) throws -> String {
    let stringRef: CFString = try propertyValue(forDeviceWithID: deviceID, selector: selector)
    return stringRef as String
}

private func propertyValue<T>(forDeviceWithID deviceID: AudioObjectID, selector: AudioObjectPropertySelector) throws -> T {
    var length = UInt32(MemoryLayout<T>.stride)
    let result = UnsafeMutablePointer<T>.allocate(capacity: 1)
    defer { result.deallocate() }
    let audioObject = CoreAudioObject(objectID: deviceID, propertyAddress: propertyAddress(selector: selector))
    try audioObject.copyPropertyValueBytes(to: result, length: &length)
    return result.move()
}

private func channelCount(with objectID: AudioObjectID, scope: AudioObjectPropertyScope) throws -> Int {
    let audioObject = CoreAudioObject(objectID: objectID, propertyAddress: audioBufferListAddress(scope: scope))
    var length = try audioObject.propertyDataLength()
    let bytes = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: audioBufferListCount(with: length))
    defer { bytes.deallocate() }
    try audioObject.copyPropertyValueBytes(to: bytes, length: &length)
    return channelCount(pointer: UnsafeMutableAudioBufferListPointer(bytes))
}

private func propertyAddress(selector: AudioObjectPropertySelector) -> AudioObjectPropertyAddress {
    return AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
}

private func audioBufferListAddress(scope: AudioObjectPropertyScope) -> AudioObjectPropertyAddress {
    return AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration, mScope: scope, mElement: 0)
}

private func audioBufferListCount(with length: UInt32) -> Int {
    return objectCount(ofType: AudioBufferList.self, inMemoryLength: Int(length))
}

private func channelCount(pointer: UnsafeMutableAudioBufferListPointer) -> Int {
    return pointer.reduce(0) { $0 + Int($1.mNumberChannels) }
}
