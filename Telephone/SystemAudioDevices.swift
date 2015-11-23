//
//  SystemAudioDevices.swift
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

import Domain
import CoreAudio
import UseCases

class SystemAudioDevices: SystemAudioDeviceRepository {
    func allDevices() throws -> [SystemAudioDevice] {
        let deviceIDs = SystemAudioDeviceIDs()
        return try deviceIDs.allDeviceIDs().map(deviceWithID)
    }

    private func deviceWithID(deviceID: Int) throws -> SystemAudioDevice {
        let uniqueIdentifier = try uniqueIdentifierForDeviceWithID(deviceID)
        let name = try nameForDeviceWithID(deviceID)
        let inputCount = try inputCountForDeviceWithID(deviceID)
        let outputCount = try outputCountForDeviceWithID(deviceID)
        let builtIn = try builtInForDeviceWithID(deviceID)
        return SystemAudioDevice(identifier: deviceID, uniqueIdentifier: uniqueIdentifier, name: name, inputCount: inputCount, outputCount: outputCount, builtIn: builtIn)
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
}
