//
//  SystemAudioDevicesChangeMonitor.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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
