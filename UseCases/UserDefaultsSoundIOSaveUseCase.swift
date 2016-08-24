//
//  UserDefaultsSoundIOSaveUseCase.swift
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

public final class UserDefaultsSoundIOSaveUseCase {
    private let soundIO: PresentationSoundIO
    private let defaults: StringUserDefaults

    public init(soundIO: PresentationSoundIO, defaults: StringUserDefaults) {
        self.soundIO = soundIO
        self.defaults = defaults
    }
}

extension UserDefaultsSoundIOSaveUseCase: UseCase {
    public func execute() {
        saveInputIfNeeded()
        saveOutputIfNeeded()
        saveRingtoneOutputIfNeeded()
    }

    private func saveInputIfNeeded() {
        if !soundIO.input.isEmpty {
            defaults[kSoundInput] = soundIO.input
        }
    }

    private func saveOutputIfNeeded() {
        if !soundIO.output.isEmpty {
            defaults[kSoundOutput] = soundIO.output
        }
    }

    private func saveRingtoneOutputIfNeeded() {
        if !soundIO.ringtoneOutput.isEmpty {
            defaults[kRingtoneOutput] = soundIO.ringtoneOutput
        }
    }
}
