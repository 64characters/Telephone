//
//  NSSoundToSoundAdapterFactory.swift
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

final class NSSoundToSoundAdapterFactory {
    func createSound(configuration: SoundConfiguration, target: SoundEventTarget) throws -> Sound {
        if let sound = NSSound(named: configuration.name) {
            update(sound, withDeviceID: configuration.deviceUID)
            return NSSoundToSoundAdapter(sound: sound, target: target)
        } else {
            throw TelephoneError.soundCreationError
        }
    }
}

private func update(_ sound: NSSound, withDeviceID deviceID: String) {
    if !deviceID.isEmpty {
        sound.playbackDeviceIdentifier = deviceID
    }
}
