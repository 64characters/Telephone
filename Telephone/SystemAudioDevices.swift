//
//  SystemAudioDevices.swift
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

import Domain
import CoreAudio
import UseCases

final class SystemAudioDevices: SystemAudioDeviceRepository {
    func allDevices() throws -> [SystemAudioDevice] {
        return try SystemAudioDeviceIDs().all().map(device)
    }
}

private func device(withID deviceID: Int) throws -> SystemAudioDevice {
    return SimpleSystemAudioDevice(
        identifier: deviceID,
        uniqueIdentifier: try uniqueIdentifier(forDeviceWithID: deviceID),
        name: try name(forDeviceWithID: deviceID),
        inputs: try inputCount(forDeviceWithID: deviceID),
        outputs: try outputCount(forDeviceWithID: deviceID),
        isBuiltIn: try isBuiltIn(forDeviceWithID: deviceID)
    )
}

private func uniqueIdentifier(forDeviceWithID deviceID: Int) throws -> String {
    return try stringPropertyValue(forDeviceWithID: deviceID, selector: kAudioDevicePropertyDeviceUID)
}

private func name(forDeviceWithID deviceID: Int) throws -> String {
    return try stringPropertyValue(forDeviceWithID: deviceID, selector: kAudioObjectPropertyName)
}

private func inputCount(forDeviceWithID deviceID: Int) throws -> Int {
    return try channelCount(with: AudioObjectID(deviceID), scope: kAudioObjectPropertyScopeInput)
}

private func outputCount(forDeviceWithID deviceID: Int) throws -> Int {
    return try channelCount(with: AudioObjectID(deviceID), scope: kAudioObjectPropertyScopeOutput)
}

private func isBuiltIn(forDeviceWithID deviceID: Int) throws -> Bool {
    let transportType: UInt32 = try propertyValue(forDeviceWithID: deviceID, selector: kAudioDevicePropertyTransportType)
    return transportType == kAudioDeviceTransportTypeBuiltIn
}

private func stringPropertyValue(forDeviceWithID deviceID: Int, selector: AudioObjectPropertySelector) throws -> String {
    let stringRef: CFString = try propertyValue(forDeviceWithID: deviceID, selector: selector)
    return stringRef as String
}

private func propertyValue<T>(forDeviceWithID deviceID: Int, selector: AudioObjectPropertySelector) throws -> T {
    var length = UInt32(MemoryLayout<T>.stride)
    var result = UnsafeMutablePointer<T>.allocate(capacity: 1)
    defer { result.deallocate() }
    let audioObject = SystemAudioObject(objectID: AudioObjectID(deviceID), propertyAddress: propertyAddress(selector: selector))
    try audioObject.copyPropertyValueBytes(to: result, length: &length)
    return result.move()
}

private func channelCount(with objectID: AudioObjectID, scope: AudioObjectPropertyScope) throws -> Int {
    var audioObject = SystemAudioObject(objectID: objectID, propertyAddress: audioBufferListAddress(scope: scope))
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
