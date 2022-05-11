//
//  DefaultSettingsSoundIOSoundIOItem+Equatable.swift
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

import DomainTestDoubles
import UseCases

extension SystemDefaultingSoundIO: Equatable {
    public static func == (lhs: SystemDefaultingSoundIO, rhs: SystemDefaultingSoundIO) -> Bool {
        return lhs.input == rhs.input && lhs.output == rhs.output && lhs.ringtoneOutput == rhs.ringtoneOutput
    }
}

extension SystemDefaultingSoundIO.Item: Equatable {
    public static func ==(lhs: SystemDefaultingSoundIO.Item, rhs: SystemDefaultingSoundIO.Item) -> Bool {
        switch (lhs, rhs) {
        case (.systemDefault, .systemDefault):
            return true
        case let (.device(l), .device(r)):
            return l == r
        case (.systemDefault, _),
             (.device, _):
            return false
        }
    }
}
