//
//  String+Creating.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

extension String {
    static func fromBytes<T>(buffer: T) -> String? {
        return stringWitBytes(buffer)
    }
}

private func stringWitBytes<T>(var bytes: T) -> String? {
    return withUnsafePointer(&bytes, stringWithPointer)
}

private func stringWithPointer<T>(pointer: UnsafePointer<T>) -> String? {
    return String(UTF8String: int8PointerWithPointer(pointer))
}

private func int8PointerWithPointer<T>(pointer: UnsafePointer<T>) -> UnsafePointer<Int8> {
    return unsafeBitCast(pointer, UnsafePointer<Int8>.self)
}
