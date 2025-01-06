//
// GenerateFileTempUrl.swift
// Proton Pass - Created on 23/12/2024.
// Copyright (c) 2024 Proton Technologies AG
//
// This file is part of Proton Pass.
//
// Proton Pass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Pass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Pass. If not, see https://www.gnu.org/licenses/.
//

import Entities
import Foundation

public protocol GenerateFileTempUrlUseCase: Sendable {
    func execute(userId: String,
                 item: any ItemIdentifiable,
                 file: ItemFile) throws -> URL
}

public extension GenerateFileTempUrlUseCase {
    func callAsFunction(userId: String,
                        item: any ItemIdentifiable,
                        file: ItemFile) throws -> URL {
        try execute(userId: userId, item: item, file: file)
    }
}

public final class GenerateFileTempUrl: GenerateFileTempUrlUseCase {
    public init() {}

    public func execute(userId: String,
                        item: any ItemIdentifiable,
                        file: ItemFile) throws -> URL {
        // When initializing FileHandle using FileHandle(forWritingTo:), file name with spaces
        // fails the initialization hence break the whole download process.
        // So we replace spaces by hyphens to bypass this system bug.
        guard let name = file.name?.replacingOccurrences(of: " ", with: "_") else {
            throw PassError.fileAttachment(.failedToDownloadMissingFileName(file.fileID))
        }
        return FileManager.default.temporaryDirectory
            .appending(path: userId)
            .appending(path: item.shareId)
            .appending(path: item.itemId)
            .appending(path: file.fileID)
            .appending(path: "\(file.modifyTime)")
            .appendingPathComponent(name, conformingTo: .data)
    }
}
