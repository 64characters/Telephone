//
//  CoreAudioDefaultSystemSoundIOChangeEventSource.swift
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

final class CoreAudioDefaultSystemSoundIOChangeEventSource {
    private let input: CoreAudioChangeEventSource
    private let output: CoreAudioChangeEventSource

    init(target: DefaultSystemSoundIOChangeEventTarget, queue: DispatchQueue) {
        input = makeEventSource(selector: kAudioHardwarePropertyDefaultInputDevice, target: target, queue: queue)
        output = makeEventSource(selector: kAudioHardwarePropertyDefaultOutputDevice, target: target, queue: queue)
    }
}

private func makeEventSource(selector: AudioObjectPropertySelector,
                             target: DefaultSystemSoundIOChangeEventTarget,
                             queue: DispatchQueue) -> CoreAudioChangeEventSource {
    return  CoreAudioChangeEventSource(
        objectID: AudioObjectID(kAudioObjectSystemObject),
        address: AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster
        ),
        queue: queue,
        callback: { (_, _) in DispatchQueue.main.async(execute: target.defaultSystemSoundIODidUpdate) }
    )
}
