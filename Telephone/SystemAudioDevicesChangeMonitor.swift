//
//  SystemAudioDevicesChangeMonitor.swift
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

class SystemAudioDevicesChangeMonitor {
    let observer: SystemAudioDevicesChangeObserver
    let queue: dispatch_queue_t

    private let objectID:AudioObjectID
    private var objectPropertyAddress: AudioObjectPropertyAddress

    init(observer: SystemAudioDevicesChangeObserver, queue: dispatch_queue_t) {
        self.observer = observer
        self.queue = queue
        objectID = AudioObjectID(kAudioObjectSystemObject)
        objectPropertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
    }

    func start() {
        let status = AudioObjectAddPropertyListenerBlock(objectID, &objectPropertyAddress, queue, propertyListenerCallback)
        if status != noErr {
            print("Could not add audio devices change listener: \(status)")
        }
    }

    func stop() {
        let status = AudioObjectRemovePropertyListenerBlock(objectID, &objectPropertyAddress, queue, propertyListenerCallback)
        if status != noErr {
            print("Could not remove audio devices change listener: \(status)")
        }
    }

    private func propertyListenerCallback(_: UInt32, _: UnsafePointer<AudioObjectPropertyAddress>) -> Void {
        dispatch_async(dispatch_get_main_queue(), notifyObserver)
    }

    private func notifyObserver() {
        assert(NSThread.isMainThread())
        observer.systemAudioDevicesDidUpdate()
    }
}
