//
//  RestoredSelectionIndex.swift
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

struct RestoredSelectionIndex<T> where T: Equatable {
    let value: Int

    init(indexBefore: Int, before: Array<T>, after: Array<T>) {
        if indexBefore == -1 || after.isEmpty {
            value = 0
        } else if case .prepended(count: let count) = ArrayDifference(before: before, after: after) {
            value = indexBefore + count
        } else if indexBefore < after.endIndex {
            value = indexBefore
        } else {
            value = after.endIndex - 1
        }
    }
}
