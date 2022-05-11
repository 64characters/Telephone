//
//  CoreAudioChangeEventSource.swift
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

final class CoreAudioChangeEventSource {
    private let objectID:AudioObjectID
    private var address: AudioObjectPropertyAddress
    private let queue: DispatchQueue
    private let callback: AudioObjectPropertyListenerBlock

    init(objectID:AudioObjectID, address: AudioObjectPropertyAddress, queue: DispatchQueue, callback: @escaping AudioObjectPropertyListenerBlock) {
        self.objectID = objectID
        self.address = address
        self.queue = queue
        self.callback = callback
        start()
    }

    deinit {
        stop()
    }
}

private extension CoreAudioChangeEventSource {
    func start() {
        let status = AudioObjectAddPropertyListenerBlock(objectID, &address, queue, callback)
        if status != noErr {
            print("Could not add Core Audio change listener: \(status)")
        }
    }

    func stop() {
        let status = AudioObjectRemovePropertyListenerBlock(objectID, &address, queue, callback)
        if status != noErr {
            print("Could not remove Core Audio change listener: \(status)")
        }
    }
}
