//
//  SystemAudioDevice+Equality.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
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
        lhs.builtIn == rhs.builtIn
}

public func ==(lhs: [SystemAudioDevice], rhs: [SystemAudioDevice]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    var generator1 = lhs.generate()
    var generator2 = rhs.generate()
    var equal = true
    while let element1 = generator1.next(), element2 = generator2.next() where equal {
        equal = element1 == element2
    }
    return equal
}
