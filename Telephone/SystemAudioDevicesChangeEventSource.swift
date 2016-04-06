//
//  SystemAudioDevicesChangeEventSource.swift
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

class SystemAudioDevicesChangeEventSource {
    let target: SystemAudioDevicesChangeEventTarget
    let queue: dispatch_queue_t

    private let objectID:AudioObjectID
    private var objectPropertyAddress: AudioObjectPropertyAddress

    init(target: SystemAudioDevicesChangeEventTarget, queue: dispatch_queue_t) {
        self.target = target
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
        dispatch_async(dispatch_get_main_queue(), notifyTarget)
    }

    private func notifyTarget() {
        assert(NSThread.isMainThread())
        target.systemAudioDevicesDidUpdate()
    }
}
