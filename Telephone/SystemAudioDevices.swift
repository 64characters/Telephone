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

class SystemAudioDevices: SystemAudioDeviceRepository {
    func allDevices() throws -> [SystemAudioDevice] {
        return try SystemAudioDeviceIDs().all().map(deviceWithID)
    }
}

private func deviceWithID(deviceID: Int) throws -> SystemAudioDevice {
    return SimpleSystemAudioDevice(
        identifier: deviceID,
        uniqueIdentifier: try uniqueIdentifierForDeviceWithID(deviceID),
        name: try nameForDeviceWithID(deviceID),
        inputs: try inputCountForDeviceWithID(deviceID),
        outputs: try outputCountForDeviceWithID(deviceID),
        builtIn: try builtInForDeviceWithID(deviceID)
    )
}

private func uniqueIdentifierForDeviceWithID(deviceID: Int) throws -> String {
    return try stringPropertyValueForDeviceWithID(deviceID, selector: kAudioDevicePropertyDeviceUID)
}

private func nameForDeviceWithID(deviceID: Int) throws -> String {
    return try stringPropertyValueForDeviceWithID(deviceID, selector: kAudioObjectPropertyName)
}

private func inputCountForDeviceWithID(deviceID: Int) throws -> Int {
    return try channelCountWithObjectID(AudioObjectID(deviceID), scope: kAudioObjectPropertyScopeInput)
}

private func outputCountForDeviceWithID(deviceID: Int) throws -> Int {
    return try channelCountWithObjectID(AudioObjectID(deviceID), scope: kAudioObjectPropertyScopeOutput)
}

private func builtInForDeviceWithID(deviceID: Int) throws -> Bool {
    let transportType: UInt32 = try propertyValueForDeviceWithID(deviceID, selector: kAudioDevicePropertyTransportType)
    return transportType == kAudioDeviceTransportTypeBuiltIn
}

private func stringPropertyValueForDeviceWithID(deviceID: Int, selector: AudioObjectPropertySelector) throws -> String {
    let stringRef: CFStringRef = try propertyValueForDeviceWithID(deviceID, selector: selector)
    return stringRef as String
}

private func integerPropertyValueForDeviceWithID(deviceID: Int, selector: AudioObjectPropertySelector) throws -> UInt32 {
    return try propertyValueForDeviceWithID(deviceID, selector: selector)
}

private func propertyValueForDeviceWithID<T>(deviceID: Int, selector: AudioObjectPropertySelector) throws -> T {
    var length = UInt32(strideof(T))
    var result = UnsafeMutablePointer<T>.alloc(1)
    defer { result.dealloc(1) }
    let audioObject = SystemAudioObject(objectID: AudioObjectID(deviceID), propertyAddress: propertyAddressWithSelector(selector))
    try audioObject.getPropertyValueBytes(result, length: &length)
    return result.move()
}

private func channelCountWithObjectID(objectID: AudioObjectID, scope: AudioObjectPropertyScope) throws -> Int {
    var audioObject = SystemAudioObject(objectID: objectID, propertyAddress: audioBufferListAddressWithScope(scope))
    var length = try audioObject.propertyDataLength()
    let count = audioBufferListCountWithLength(length)
    let bytes = UnsafeMutablePointer<AudioBufferList>.alloc(count)
    defer { bytes.dealloc(count) }
    try audioObject.getPropertyValueBytes(bytes, length: &length)
    return channelCountWithBufferListPointer(UnsafeMutableAudioBufferListPointer(bytes))
}

private func propertyAddressWithSelector(selector: AudioObjectPropertySelector) -> AudioObjectPropertyAddress {
    return AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
}

private func audioBufferListAddressWithScope(scope: AudioObjectPropertyScope) -> AudioObjectPropertyAddress {
    return AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration, mScope: scope, mElement: 0)
}

private func audioBufferListCountWithLength(length: UInt32) -> Int {
    return Int(length) / strideof(AudioBufferList)
}

private func channelCountWithBufferListPointer(bufferListPointer: UnsafeMutableAudioBufferListPointer) -> Int {
    var channelCount: UInt32 = 0
    for buffer in bufferListPointer {
        channelCount += buffer.mNumberChannels
    }
    return Int(channelCount)
}
