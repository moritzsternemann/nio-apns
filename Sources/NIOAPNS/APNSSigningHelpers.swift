//
//  APNSSigningHelpers.swift
//  NIOAPNS
//
//  Created by Kyle Browning on 1/10/19.
//

import Foundation
import CNIOOpenSSL

func sha256(message: Data) -> Data {
    var ctx = SHA256_CTX()
    SHA256_Init(&ctx)
    
    message.enumerateBytes { buffer, _, _ in
        SHA256_Update(&ctx, buffer.baseAddress, buffer.count)
    }
    
    var digest = Data(count: Int(SHA256_DIGEST_LENGTH))
    _ = digest.withUnsafeMutableBytes { mptr in
        SHA256_Final(mptr, &ctx)
    }
    
    return digest
}

public class SigningKey {
    private let opaqueKey: OpaquePointer
    
    public init?(url: URL, passphrase: String? = nil) {
        let bio = url.withUnsafeFileSystemRepresentation { fsr in BIO_new_file(fsr, "r") }
        guard bio != nil else {
            return nil
        }
        
        let read: (UnsafeMutableRawPointer?) -> OpaquePointer? = { u in PEM_read_bio_ECPrivateKey(bio!, nil, nil, u) }
        
        let pointer: OpaquePointer?
        if var utf8 = passphrase?.utf8CString {
            pointer = utf8.withUnsafeMutableBufferPointer { mptr in read(mptr.baseAddress) }
        } else {
            pointer = read(nil)
        }
        
        BIO_free(bio!)
        
        if let pointer = pointer {
            self.opaqueKey = pointer
        } else {
            return nil
        }
    }
    
    deinit {
        EC_KEY_free(opaqueKey)
    }
    
    public func sign(digest: Data) throws -> Data  {
        let sig = digest.withUnsafeBytes { ptr in ECDSA_do_sign(ptr, Int32(digest.count), opaqueKey) }
        defer { ECDSA_SIG_free(sig) }
        
        var derEncodedSignature: UnsafeMutablePointer<UInt8>? = nil
        let derLength = i2d_ECDSA_SIG(sig, &derEncodedSignature)
        
        guard let derCopy = derEncodedSignature, derLength > 0 else {
            throw APNSError.couldNotSign
        }
        
        var derBytes = [UInt8](repeating: 0, count: Int(derLength))
        
        for b in 0..<Int(derLength) {
            derBytes[b] = derCopy[b]
        }
        return Data(derBytes)
    }
    
    public func verify(digest: Data, signature: Data) -> Bool {
        var signature = signature
        let sig = signature.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> UnsafeMutablePointer<ECDSA_SIG> in
            var copy = Optional.some(ptr)
            return d2i_ECDSA_SIG(nil, &copy, signature.count)
        }
        
        defer { ECDSA_SIG_free(sig) }
        
        let result = digest.withUnsafeBytes { ptr in
            return ECDSA_do_verify(ptr, Int32(digest.count), sig, opaqueKey)
        }
        
        return result == 1
    }
}
