//
//  ArrayDifference.swift
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

enum ArrayDifference<T> where T: Equatable {
    case prepended(count: Int)
    case shiftedByOne
    case other

    init(before: Array<T>, after: Array<T>) {
        if before.isEmpty || after.isEmpty {
            self = .other
        } else if after.reversed().starts(with: before.reversed()) {
            self = .prepended(count: after.count - before.count)
        } else if before[..<before.index(before: before.endIndex)] == after[after.index(after: after.startIndex)...] {
            self = .shiftedByOne
        } else {
            self = .other
        }
    }
}
