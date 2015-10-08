//
//  SystemAudioDeviceIDs.swift
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

import CoreAudio

class SystemAudioDeviceIDs {

    private var deviceIDs = [Int]()
    private var audioObject: SystemAudioObject

    init() {
        let objectID = AudioObjectID(kAudioObjectSystemObject)
        let propertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
        audioObject = SystemAudioObject(objectID: objectID, propertyAddress: propertyAddress)
    }

    func update() throws {
        let length = try audioObject.propertyDataLength()
        deviceIDs = try deviceIDsWithLength(length)
    }

    var allDeviceIDs: [Int] {
        return deviceIDs
    }

    subscript(index: Int) -> Int {
        return deviceIDs[index]
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

    private func deviceIDsWithBytes(bytes: UnsafeMutablePointer<AudioObjectID>, length: UInt32) -> [Int] {
        let audioObjectIDs = audioObjectIDsWithBytes(bytes, length: length)
        return audioObjectIDs.map { Int($0) }
    }

    private func audioObjectIDsWithBytes(bytes: UnsafeMutablePointer<AudioObjectID>, length: UInt32) -> [AudioObjectID] {
        let buffer = UnsafeMutableBufferPointer<AudioObjectID>(start: bytes, count: audioObjectIDCountWithLength(length))
        return [AudioObjectID](buffer)
    }

    private func audioObjectIDCountWithLength(length: UInt32) -> Int {
        return Int(length) / strideof(AudioObjectID)
    }
}
