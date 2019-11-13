//
//  URLSession+Multipart.swift
//  Operations
//
//  Created by Denys on 10/17/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

/*
 The main point of this extension is to provide methods to create multipart/form-data request.
 According to RFC 7578 specification [https://tools.ietf.org/html/rfc7578]:
 Content-Type should include `multipart/form-data` and `boundary`;
 The `boundary` param is a delimiter for parts of multipart request;
 Each line should end with linebrake (\r\n);
 Each part should start with `--` + `boundary` delimiter;
 Each part should contain `Content-Disposition` where parameters provided (e.g. `name`, `filename`);
 Each part should contain `Content-Type` where MIME type provided (e.g. image/jpeg, video/mp4, audio/mpeg);
 Each part should end with `--` + `boundary` + `--` delimiter.
 
 Example of body supported by SprinkleBit:
 
 --6781880645075605171
 Content-Disposition: form-data; name="image"; filename="image.jpeg"
 Content-Type: image/jpeg
 <image_data>
 
 --6781880645075605171--
 */

extension URLSession {
    
    /// Creates and executes `URLSessionUploadTask` to upload multipart data
    ///
    /// - parameter fileURL: The `URL` to save encoded multipart data on disk.
    /// - parameter request: The `URLRequest` to backend endpoint.
    /// - parameter data:    The `MultipartData` object contained:
    ///                      `file` - The Data of the file to upload;
    ///                      `name` - The String represented the key for file data (e.g. `image`);
    ///                      `filename` - The name of the file;
    ///                      `mimeType` - The MIME type of the file.
    func upload(fileURL: URL, request: RequestConvertible, data: MultipartData) throws {
        let request = try multipartRequest(request, data: data, fileURL: fileURL)
        let task = uploadTask(with: request, fromFile: fileURL)
        
        task.resume()
    }
    
    /// Creates the multipart URLRequest
    ///
    /// - parameter urlRequest: The `URLRequest` to backend endpoint.
    /// - parameter data:    The `MultipartData` object contained:
    ///                      `file` - The `Data` of the file to upload;
    ///                      `name` - The `String` represented the key for file data (e.g. `image`);
    ///                      `filename` - The name of the file;
    ///                      `mimeType` - The MIME type of the file.
    /// - parameter fileURL: The `URL` to save encoded multipart data on disk.
    ///
    /// - returns: The created `URLRequest`
    func multipartRequest(_ urlRequest: RequestConvertible,
                          data: MultipartData,
                          fileURL: URL) throws -> URLRequest {
        
        // Generate random boundary according to rules described in RFC 7578
        let boundary = randomBoundary
        
        // Create content type value for multipart request
        let contentType = Constants.Multipart.multipartContentType(with: boundary)
        
        // Create body for multipart request
        let httpBody = try multipartHttpBody(boundary: boundary, data: data)
        
        // Save body to provided `fileURL` to uploading data from disk
        // The body should be written to file to allow background uploading
        try writeHTTPBody(httpBody, to: fileURL)
        
        // Convert `RequestConvertible` to `URLRequest` to set `Content-Type` header
        var request = try urlRequest.asURLRequest()
        request.setValue(contentType, forHTTPHeaderField: Constants.contentTypeHeaderKey)
        
        return request
    }
    
    // MARK: - Private methods
    private var randomBoundary: String {
        return UUID().uuidString
    }
    
    private func writeHTTPBody(_ body: Data, to url: URL) throws {
        try body.write(to: url)
    }
    
    private func multipartHttpBody(boundary: String,
                                   data: MultipartData) throws -> Data {
        var httpBody: Data = Data()
        
        // Create multipart request body by combining:
        // Prefix with params
        // The `Data` of the file to upload
        // The postfix with boundary delimiter in the end
        httpBody.append(try multipartBodyPrefix(with: boundary, data: data))
        httpBody.append(data.file)
        httpBody.append(try multipartBodyPostfix(with: boundary))
        
        return httpBody
    }
    
    private func multipartBodyPrefix(with boundary: String, data: MultipartData) throws -> Data {
        var prefix: Data = Data()
        
        // Multipart body starts with boundary delimiter
        let boundaryLine: String = Constants.Multipart.boundaryHeaderDelimiter(with: boundary)
        let encodedBoundaryLine: Data = try encoded(boundaryLine, throws: .boundary)
        prefix.append(encodedBoundaryLine)
        
        // Encoding Content-Disposition with `name` and `filename`
        let contentDisposition: String = Constants.Multipart.multipartContentDisposition(name: data.name, filename: data.filename)
        let encodedContentDisposition: Data = try encoded(contentDisposition, throws: .contentDisposition)
        prefix.append(encodedContentDisposition)
        
        // Encoding Content-Type with `mimeType`
        let contentTypeString: String = Constants.Multipart.multipartMIMEContentType(with: data.mimeType)
        let encodedContentType: Data = try encoded(contentTypeString, throws: .contentType)
        prefix.append(encodedContentType)
        
        return prefix
    }
    
    private func multipartBodyPostfix(with boundary: String) throws -> Data {
        let postfix = Constants.Multipart.boundaryFooterDelimiter(with: boundary)
        return try encoded(postfix, throws: .boundary)
    }
    
    private func encoded(_ string: String, throws error: MultipartBodyEncodingError) throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw error
        }
        
        return data
    }
}
