//
// AnotherFakeAPI.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
import Vapor
#if canImport(AnyCodable)
import AnyCodable
#endif

open class AnotherFakeAPI {

    /**
     To test special tags
     PATCH /another-fake/dummy
     To test special tags and operation ID starting with number
     - parameter uuidTest: (header) to test uuid example value 
     - parameter body: (body) client model 
     - returns: `EventLoopFuture` of `ClientResponse` 
     */
    open class func call123testSpecialTagsRaw(uuidTest: UUID, body: Client, headers: HTTPHeaders = PetstoreClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<ClientResponse> {
        let localVariablePath = "/another-fake/dummy"
        let localVariableURLString = PetstoreClientAPI.shared.basePath + localVariablePath

        guard let localVariableApiClient = PetstoreClientAPI.shared.apiClient else {
            fatalError("PetstoreClientAPI.shared.apiClient is not set.")
        }

        return localVariableApiClient.send(.PATCH, headers: headers, to: URI(string: localVariableURLString)) { localVariableRequest in
            try Configuration.apiWrapper(&localVariableRequest)
            
            localVariableRequest.headers.add(name: "uuid_test", value: uuidTest.description)
            
            
            try localVariableRequest.content.encode(body, using: PetstoreClientAPI.shared.contentConfiguration.requireEncoder(for: Client.defaultContentType))
            
            try beforeSend(&localVariableRequest)
        }
    }

    public enum Call123testSpecialTags {
        case http200(value: Client, raw: ClientResponse)
        case http0(raw: ClientResponse)
    }

    /**
     To test special tags
     PATCH /another-fake/dummy
     To test special tags and operation ID starting with number
     - parameter uuidTest: (header) to test uuid example value 
     - parameter body: (body) client model 
     - returns: `EventLoopFuture` of `Call123testSpecialTags` 
     */
    open class func call123testSpecialTags(uuidTest: UUID, body: Client, headers: HTTPHeaders = PetstoreClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<Call123testSpecialTags> {
        return call123testSpecialTagsRaw(uuidTest: uuidTest, body: body, headers: headers, beforeSend: beforeSend).flatMapThrowing { response -> Call123testSpecialTags in
            switch response.status.code {
            case 200:
                return .http200(value: try response.content.decode(Client.self, using: PetstoreClientAPI.shared.contentConfiguration.requireDecoder(for: Client.defaultContentType)), raw: response)
            default:
                return .http0(raw: response)
            }
        }
    }
}
