//
//  SystemAudioDevices.swift
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

import Domain
import CoreAudio
import UseCases

final class SystemAudioDevices: SystemAudioDeviceRepository {
    func allDevices() throws -> [SystemAudioDevice] {
        return try SystemAudioDeviceIDs().all().map(deviceWithID)
    }
}

private func deviceWithID(_ deviceID: Int) throws -> SystemAudioDevice {
    return SimpleSystemAudioDevice(
        identifier: deviceID,
        uniqueIdentifier: try uniqueIdentifierForDeviceWithID(deviceID),
        name: try nameForDeviceWithID(deviceID),
        inputs: try inputCountForDeviceWithID(deviceID),
        outputs: try outputCountForDeviceWithID(deviceID),
        builtIn: try builtInForDeviceWithID(deviceID)
    )
}

private func uniqueIdentifierForDeviceWithID(_ deviceID: Int) throws -> String {
    return try stringPropertyValueForDeviceWithID(deviceID, selector: kAudioDevicePropertyDeviceUID)
}

private func nameForDeviceWithID(_ deviceID: Int) throws -> String {
    return try stringPropertyValueForDeviceWithID(deviceID, selector: kAudioObjectPropertyName)
}

private func inputCountForDeviceWithID(_ deviceID: Int) throws -> Int {
    return try channelCountWithObjectID(AudioObjectID(deviceID), scope: kAudioObjectPropertyScopeInput)
}

private func outputCountForDeviceWithID(_ deviceID: Int) throws -> Int {
    return try channelCountWithObjectID(AudioObjectID(deviceID), scope: kAudioObjectPropertyScopeOutput)
}

private func builtInForDeviceWithID(_ deviceID: Int) throws -> Bool {
    let transportType: UInt32 = try propertyValueForDeviceWithID(deviceID, selector: kAudioDevicePropertyTransportType)
    return transportType == kAudioDeviceTransportTypeBuiltIn
}

private func stringPropertyValueForDeviceWithID(_ deviceID: Int, selector: AudioObjectPropertySelector) throws -> String {
    let stringRef: CFString = try propertyValueForDeviceWithID(deviceID, selector: selector)
    return stringRef as String
}

private func integerPropertyValueForDeviceWithID(_ deviceID: Int, selector: AudioObjectPropertySelector) throws -> UInt32 {
    return try propertyValueForDeviceWithID(deviceID, selector: selector)
}

private func propertyValueForDeviceWithID<T>(_ deviceID: Int, selector: AudioObjectPropertySelector) throws -> T {
    var length = UInt32(MemoryLayout<T>.stride)
    var result = UnsafeMutablePointer<T>.allocate(capacity: 1)
    defer { result.deallocate(capacity: 1) }
    let audioObject = SystemAudioObject(objectID: AudioObjectID(deviceID), propertyAddress: propertyAddressWithSelector(selector))
    try audioObject.getPropertyValueBytes(result, length: &length)
    return result.move()
}

private func channelCountWithObjectID(_ objectID: AudioObjectID, scope: AudioObjectPropertyScope) throws -> Int {
    var audioObject = SystemAudioObject(objectID: objectID, propertyAddress: audioBufferListAddressWithScope(scope))
    var length = try audioObject.propertyDataLength()
    let count = audioBufferListCountWithLength(length)
    let bytes = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: count)
    defer { bytes.deallocate(capacity: count) }
    try audioObject.getPropertyValueBytes(bytes, length: &length)
    return channelCountWithBufferListPointer(UnsafeMutableAudioBufferListPointer(bytes))
}

private func propertyAddressWithSelector(_ selector: AudioObjectPropertySelector) -> AudioObjectPropertyAddress {
    return AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
}

private func audioBufferListAddressWithScope(_ scope: AudioObjectPropertyScope) -> AudioObjectPropertyAddress {
    return AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration, mScope: scope, mElement: 0)
}

private func audioBufferListCountWithLength(_ length: UInt32) -> Int {
    return objectCount(ofType: AudioBufferList.self, inMemoryLength: Int(length))
}

private func channelCountWithBufferListPointer(_ bufferListPointer: UnsafeMutableAudioBufferListPointer) -> Int {
    var channelCount: UInt32 = 0
    for buffer in bufferListPointer {
        channelCount += buffer.mNumberChannels
    }
    return Int(channelCount)
}
