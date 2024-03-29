/// This approach is suitable for client applications that don't need long-lived access to resources
/// or when the resource server doesn't support or want to issue refresh tokens.
/// ex.: Federated Login or access to regulated and/or compliance requirement-related data.
/// See Also:
/// - [Authorization Flow](https://developers.google.com/identity/protocols/oauth2/web-server#httprest_3)
import Vapor

public protocol AuthorizationGrant: ImperialGrantable { }

extension AuthorizationGrant {
  func flow(req: Request, requestBody: ImperialToken) async throws {
    let defaultgrantType = "authorization_code"
    let grantType = requestBody.grantType ?? defaultgrantType
    
    guard
      let _ = requestBody.clientID,
      let _ = requestBody.clientSecret,
      let _ = requestBody.code,
      let _ = requestBody.redirectURI,
      grantType == defaultgrantType
    else { throw Abort(.internalServerError) }
    
    var components = URLComponents()
    components.scheme = self.scheme
    components.host = self.host
    components.path = self.path
    components.queryItems = [
      requestBody.clientIDItem,
      requestBody.clientSecretItem,
      requestBody.codeItem,
      requestBody.grantTypeItem,
      requestBody.redirectURIItem ]
    
    guard let url = components.url else { throw Abort(.notFound) }
    let urlString = url.absoluteString
    let uri = URI(string: urlString)
    let response = try await req.client.post(uri, beforeSend: { req in
      req.headers.contentType = .urlEncodedForm
      try req.content.encode(responseBody)
    }).encodeResponse(for: req)
    
    guard let responsebodyData = response.body.data else { throw Abort(.notFound) }
    let tokenBody = try JSONDecoder().decode(ImperialToken.self, from: responsebodyData)
    try await handler(req, tokenBody)
  }
}



//
//public struct AuthorizationGrant: ImperialGrantAuthorization {
//  public var scheme: String
//  public var host: String
//  public var path: String
//  public var responseBody: ImperialToken
//  public var handler: (@Sendable (Vapor.Request, ImperialToken) async throws -> Void)?
// 
//  public init(
//    scheme: String,
//    host: String,
//    path: String,
//    responseBody: ImperialToken,
//    handler: (@Sendable (Vapor.Request, ImperialToken) async throws -> Void)? = nil
//  ) {
//    self.scheme = scheme
//    self.host = host
//    self.path = path
//    self.handler = handler
//  }
//  
//  public init(
//    scheme: String,
//    host: String,
//    path: String,
//    clientID: String,
//    clientSecret: String,
//    code: String,
//    grantType: String?,
//    redirectURI: String,
//    callback: (@Sendable (Vapor.Request, ImperialToken) async throws -> Void)? = nil
//  ) {
//    let authorizationtokenBody = ImperialToken(
//      clientID: clientID, 
//      clientSecret: clientSecret,
//      code: code,
//      grantType: grantType,
//      redirectURI: redirectURI)
//    self.init(
//      scheme: scheme,
//      host: host,
//      path: path,
//      responseBody: authorizationtokenBody,
//      handler: callback
//    )
//  }
//  
//  public struct RequestBody: Sendable, Codable {
//    public var clientID: String
//    public var clientSecret: String
//    public var code: String
//    public var grantType: String?
//    public var redirectURI: String
//        
//    private enum CodingKeys: String, CodingKey {
//      case clientID = "client_id"
//      case clientSecret = "client_secret"
//      case code = "code"
//      case grantType = "grant_type"
//      case redirectURI = "redirect_uri"
//    }
//    
//    init(
//      clientID: String,
//      clientSecret: String,
//      code: String,
//      grantType: String?,
//      redirectURI: String
//    ) {
//      self.clientID = clientID
//      self.clientSecret = clientSecret
//      self.code = code
//      self.grantType = grantType
//      self.redirectURI = redirectURI
//    }
//  }
  
  
//  public mutating func flow(req: Request, body: ImperialToken) async throws {
//    let defaultgrantType = "authorization_code"
//    let grantType = body.grantType ?? defaultgrantType
//    
//    guard
//      let _ = body.clientID,
//      let _ = body.clientSecret,
//      let _ = body.code,
//      let _ = body.redirectURI,
//      grantType == defaultgrantType
//    else { throw Abort(.internalServerError) }
//    
//    var components = URLComponents()
//    components.scheme = self.scheme
//    components.host = self.host
//    components.path = self.path
//    components.queryItems = [
//      self.body.clientIDItem,
//      self.body.clientSecretItem,
//      self.body.codeItem,
//      self.body.grantTypeItem,
//      self.body.redirectURIItem ]
//    
//    guard let url = components.url else { throw Abort(.notFound) }
//    let urlString = url.absoluteString
//    let uri = URI(string: urlString)
//    let accesstokenResponse = try await req.client.post(uri, beforeSend: { req in
//      req.headers.contentType = .urlEncodedForm
//      try req.content.encode(body)
//    }).encodeResponse(for: req)
//    
//    guard let accesstokenresponsebodyData = accesstokenResponse.body.data else { throw Abort(.notFound) }
//    let accesstokenBody = try JSONDecoder().decode(ImperialToken.self, from: accesstokenresponsebodyData)
//    try await handler(req: req, body: accesstokenBody)
//  }
//}

