//
//  SystemAudioDevice+Equality.swift
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

public func ==(lhs: SystemAudioDevice, rhs: SystemAudioDevice) -> Bool {
    return lhs.identifier == rhs.identifier &&
        lhs.uniqueIdentifier == rhs.uniqueIdentifier &&
        lhs.name == rhs.name &&
        lhs.inputs == rhs.inputs &&
        lhs.outputs == rhs.outputs &&
        lhs.isBuiltIn == rhs.isBuiltIn
}

public func ==(lhs: [SystemAudioDevice], rhs: [SystemAudioDevice]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    var iterator1 = lhs.makeIterator()
    var iterator2 = rhs.makeIterator()
    var isEqual = true
    while let element1 = iterator1.next(), let element2 = iterator2.next(), isEqual {
        isEqual = element1 == element2
    }
    return isEqual
}
