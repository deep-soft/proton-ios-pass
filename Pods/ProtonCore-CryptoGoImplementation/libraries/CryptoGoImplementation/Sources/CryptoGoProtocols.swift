//
//  CryptoGoProtocols.swift
//  ProtonCore-CryptoGoImplementation - Created on 24/05/2023.
//
//  Copyright (c) 2023 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation
import GoLibs
import ProtonCore_CryptoGoInterface

extension ProtonCore_CryptoGoInterface.CryptoReaderProtocol {
    var toGoLibsType: GoLibs.CryptoReaderProtocol {
        if let goLibsReader = self as? GoLibs.CryptoReaderProtocol {
            return goLibsReader
        } else {
            return AnyGoLibsCryptoReader(cryptoReader: self)
        }
    }
}

final class AnyGoLibsCryptoReader: NSObject, GoLibs.CryptoReaderProtocol {

    let readClosure: (Data?, UnsafeMutablePointer<Int>?) throws -> Void

    init<T>(cryptoReader: T) where T: ProtonCore_CryptoGoInterface.CryptoReaderProtocol {
        self.readClosure = { b, n in try cryptoReader.read(b, n: n) }
    }

    func read(_ b: Data?, n: UnsafeMutablePointer<Int>?) throws {
        try readClosure(b, n)
    }
}

extension ProtonCore_CryptoGoInterface.CryptoWriterProtocol {
    var toGoLibsType: GoLibs.CryptoWriterProtocol {
        if let goLibsWriter = self as? GoLibs.CryptoWriterProtocol {
            return goLibsWriter
        } else {
            return AnyGoLibsCryptoWriter(cryptoWriter: self)
        }
    }
}

final class AnyGoLibsCryptoWriter: NSObject, GoLibs.CryptoWriterProtocol {

    private let writeClosure: (Data?, UnsafeMutablePointer<Int>?) throws -> Void

    init<T>(cryptoWriter: T) where T: ProtonCore_CryptoGoInterface.CryptoWriterProtocol {
        self.writeClosure = { b, n in try cryptoWriter.write(b, n: n) }
    }

    func write(_ b: Data?, n: UnsafeMutablePointer<Int>?) throws {
        try writeClosure(b, n)
    }
}

extension GoLibs.CryptoWriteCloserProtocol {
    var toCryptoGoType: ProtonCore_CryptoGoInterface.CryptoWriteCloserProtocol {
        if let goLibsWriter = self as? ProtonCore_CryptoGoInterface.CryptoWriteCloserProtocol {
            return goLibsWriter
        } else {
            return AnyCryptoGoWriteCloser(cryptoWriteCloser: self)
        }
    }
}

final class AnyCryptoGoWriteCloser: NSObject, ProtonCore_CryptoGoInterface.CryptoWriteCloserProtocol {
    private let closeClosure: () throws -> ()
    private let writeClosure: (Data?, UnsafeMutablePointer<Int>?) throws -> ()

    init<T>(cryptoWriteCloser: T) where T: GoLibs.CryptoWriteCloserProtocol {
        self.closeClosure = { try cryptoWriteCloser.close() }
        self.writeClosure = { b, n in try cryptoWriteCloser.write(b, n: n) }
    }

    func close() throws {
        try closeClosure()
    }

    func write(_ b: Data?, n: UnsafeMutablePointer<Int>?) throws {
        try writeClosure(b, n)
    }
}

extension ProtonCore_CryptoGoInterface.CryptoWriteCloserProtocol {
    var toGoLibsType: GoLibs.CryptoWriteCloserProtocol {
        if let goLibsWriter = self as? GoLibs.CryptoWriteCloserProtocol {
            return goLibsWriter
        } else {
            return AnyGoLibsWriteCloser(cryptoWriteCloser: self)
        }
    }
}

final class AnyGoLibsWriteCloser: NSObject, GoLibs.CryptoWriteCloserProtocol {
    private let closeClosure: () throws -> ()
    private let writeClosure: (Data?, UnsafeMutablePointer<Int>?) throws -> ()

    init<T>(cryptoWriteCloser: T) where T: ProtonCore_CryptoGoInterface.CryptoWriteCloserProtocol {
        self.closeClosure = { try cryptoWriteCloser.close() }
        self.writeClosure = { b, n in try cryptoWriteCloser.write(b, n: n) }
    }

    func close() throws {
        try closeClosure()
    }

    func write(_ b: Data?, n: UnsafeMutablePointer<Int>?) throws {
        try writeClosure(b, n)
    }
}

extension ProtonCore_CryptoGoInterface.HelperMobileReaderProtocol {
    var toGoLibsType: GoLibs.HelperMobileReaderProtocol {
        if let goLibsHelperMobileReader = self as? GoLibs.HelperMobileReaderProtocol {
            return goLibsHelperMobileReader
        } else {
            return AnyGoLibsHelperMobileReader(helperMobileReader: self)
        }
    }
}

final class AnyGoLibsHelperMobileReader: NSObject, GoLibs.HelperMobileReaderProtocol {
    private let readClosure: (Int) throws -> GoLibs.HelperMobileReadResult

    init<T>(helperMobileReader: T) where T: ProtonCore_CryptoGoInterface.HelperMobileReaderProtocol {
        self.readClosure = { max in try helperMobileReader.read(max).toGoLibsType }
    }

    func read(_ max: Int) throws -> GoLibs.HelperMobileReadResult {
        try readClosure(max)
    }
}


