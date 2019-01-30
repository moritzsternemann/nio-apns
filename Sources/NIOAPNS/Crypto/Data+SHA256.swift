//
//  Data+SHA256.swift
//  NIOAPNS
//

import Foundation
import CAPNSOpenSSL

internal extension Data {
    func sha256() -> Data {
        var ctx = SHA256_CTX()
        SHA256_Init(&ctx)

        self.enumerateBytes { buffer, _, _ in
            SHA256_Update(&ctx, buffer.baseAddress, buffer.count)
        }

        var digest = Data(count: Int(SHA256_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { mptr in
            SHA256_Final(mptr, &ctx)
        }

        return digest
    }
}
