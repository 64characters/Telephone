//
//  PresentationAudioDevices.swift
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

import Domain
import Foundation

final class PresentationAudioDevices: NSObject {
    @objc let input: [PresentationAudioDevice]
    @objc let output: [PresentationAudioDevice]
    @objc var ringtoneOutput: [PresentationAudioDevice] { return output }

    init(input: [PresentationAudioDevice], output: [PresentationAudioDevice]) {
        self.input = input
        self.output = output
    }
}

extension PresentationAudioDevices {
    override func isEqual(_ object: Any?) -> Bool {
        guard let devices = object as? PresentationAudioDevices else { return false }
        return isEqual(to: devices)
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(input)
        hasher.combine(output)
        return hasher.finalize()
    }

    private func isEqual(to devices: PresentationAudioDevices) -> Bool {
        return input == devices.input && output == devices.output
    }
}
