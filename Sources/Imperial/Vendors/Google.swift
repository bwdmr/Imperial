/// - See Also:
/// [Access Flow](https://developers.google.com/identity/protocols/oauth2/javascript-implicit-flow#oauth-2.0-endpoints)
/// [Authorization Flow](https://developers.google.com/identity/protocols/oauth2/web-server#httprest_1)
import Vapor


extension ImperialID {
  public static let google = ImperialID("google")
}


extension ImperialFactory {
  public var google: ImperialService {
    guard let result = make(.google) as? (any ImperialService) else {
      fatalError("Google Registry is not configured") }
    return result
  }
}




public struct GoogleService: ImperialService {
  static public var authorizationURL = { URLComponents()
    self.url.scheme = "https"
    self.url.host = "oauth"
  }
 
  static public func googleserviceURL() throws -> URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "oauth2.googleapis.com"
    urlComponents.path = "/token"
    
    guard let url = urlComponents.url else { throw Abort(.notFound) }
    return url
  }
  
   
  public var req: Vapor.Request
  public var url: URL
  public var grantor: Grantor
  
  public init(req: Vapor.Request, url: URL) {
    
    let grantor = CacheGrantable(
      authorizeURL: <#T##URL#>,
      refreshURL: <#T##URL#>,
      revokeURL: <#T##URL#>)
    
    self.req = req
    self.url = url
    self.grantor = grantor
  }
  
  
//  init(
//    req: Request,
//    url: URL,
//    clientID: String,
//    clientSecret: String,
//    grantType: String? = nil,
//    redirectURI: String,
//    responseType: String,
//    scope: [String],
//    callback: (@Sendable (Request, ImperialToken) async throws -> Void)?
// ) throws {
//   let googleserviceURL = try GoogleService.googleserviceURL()
//   
//   let callback = { @Sendable (req: Request, body: ImperialToken) async throws in
//     print("function") }
//    
//   try self.init(
//    req: req,
//    url: googleserviceURL,
//    clientID: clientID,
//    clientSecret: clientSecret,
//    grantType: grantType,
//    redirectURI: redirectURI,
//    responseType: responseType,
//    scope: scope,
//    callback: callback)
//  }
}
