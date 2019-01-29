//
//  APNSSigningKey.swift
//  NIOAPNS
//

import Foundation
import OpenSSL

internal class APNSSigningKey {
    private let opaqueKey: OpaquePointer
    
    init(url: URL, passphrase: String? = nil) throws {
        let bio = url.withUnsafeFileSystemRepresentation { BIO_new_file($0, "r") }
        guard bio != nil else {
            throw APNSError.invalidPrivateKey("Could not open file")
        }
        
        let read: (UnsafeMutablePointer?) -> OpaquePointer? = {
            PEM_read_bio_ECPrivateKey(bio!, nil, nil, $0)
        }
        
        let pointer: OpaquePointer?
        if var utf8 = passphrase?.utf8CString {
            pointer = utf8.withUnsafeMutableBufferPointer { read($0.baseAddress) }
        } else {
            pointer = read(nil)
        }
        
        BIO_free(bio!)
        
        guard pointer != nil else {
            throw APNSError.invalidPrivateKey("No key found")
        }
        
        self.opaqueKey = pointer!
    }
    
    deinit {
        EC_KEY_free(self.opaqueKey)
    }
    
    func sign(digest: Data) throws -> Data {
        let sig = digest.withUnsafeBytes { ECDSA_do_sign($0, Int32(digest.count), self.opaqueKey) }
        defer { ECDSA_SIG_free(sig) }
        
        var derEncodedSignature: UnsafeMutablePointer<UInt8>? = nil
        let derLength = i2d_ECDSA_SIG(sig, &derEncodedSignature)
        
        guard let derCopy = derEncodedSignature, derLength > 0 else {
            throw APNSError.signingFailed
        }
        
        var derBytes = [UInt8](repeating: 0, count: Int(derLength))
        
        for b in 0..<Int(derLength) {
            derBytes[b] = derCopy[b]
        }

        return Data(derBytes)
    }
    
    func verify(digest: Data, signature: Data) -> Bool {
        var signature = signature
        let sig = signature.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> UnsafeMutablePointer<ECDSA_SIG> in
            var copy = Optional.some(ptr)
            return d2i_ECDSA_SIG(nil, &copy, signature.count)
        }
        defer { ECDSA_SIG_free(sig) }
        
        let result = digest.withUnsafeBytes { ptr in
            ECDSA_do_verify(ptr, Int32(digest.count), sig, self.opaqueKey)
        }
        
        return result == 1
    }
}
