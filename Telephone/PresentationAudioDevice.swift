//
//  PresentationAudioDevice.swift
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
import UseCases

final class PresentationAudioDevice: NSObject {
    @objc var isSystemDefault: Bool
    @objc var name: String

    init(isSystemDefault: Bool, name: String) {
        self.isSystemDefault = isSystemDefault
        self.name = name
    }
}

extension PresentationAudioDevice {
    convenience init(device: SystemAudioDevice) {
        self.init(isSystemDefault: false, name: device.name)
    }
}

extension PresentationAudioDevice {
    convenience init(item: SystemDefaultingSoundIO.Item, systemDefaultDeviceName: String) {
        switch item {
        case .systemDefault:
            self.init(isSystemDefault: true, name: systemDefaultDeviceName)
        case .device(let name):
            self.init(isSystemDefault: false, name: name)
        }
    }
}

extension PresentationAudioDevice {
    override func isEqual(_ object: Any?) -> Bool {
        guard let device = object as? PresentationAudioDevice else { return false }
        return isEqual(to: device)
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(isSystemDefault)
        hasher.combine(name)
        return hasher.finalize()
    }

    private func isEqual(to device: PresentationAudioDevice) -> Bool {
        return isSystemDefault == device.isSystemDefault && name == device.name
    }
}
