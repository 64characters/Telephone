//
//  RingtonePlaybackUseCaseSpy.swift
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

import UseCases

public final class RingtonePlaybackUseCaseSpy: NSObject {
    public private(set) var isPlaying = false
    public private(set) var didCallStart = false
    public private(set) var didCallStop = false
}

extension RingtonePlaybackUseCaseSpy: RingtonePlaybackUseCase {
    public func start() throws {
        didCallStart = true
        isPlaying = true
    }

    public func stop() {
        didCallStop = true
        isPlaying = false
    }
}
