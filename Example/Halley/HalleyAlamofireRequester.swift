//
//  HalleyAlamofireRequester.swift
//  Halley_Example
//
//  Created by Filip Gulan on 15.01.2022..
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Halley
import Alamofire

class HALAlamofireRequester: RequesterInterface {

    func requestResource(
        at url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> RequestContainerInterface {

        print("[REQUEST]: \(url.absoluteString)")
        let headers = HTTPHeaders(
            [
                "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI0MmVlZDFiNy1jMDcyLTRkZGQtOGFiNS01NDM2ZTg2ZDA1YjAiLCJpc3MiOiJkZXYuYmFja2VuZC5rYS5waGlsaXBzLmNvbSIsInVzZXJuYW1lIjoiNDJlZWQxYjctYzA3Mi00ZGRkLThhYjUtNTQzNmU4NmQwNWIwIiwiZXhwIjoxNjQ3NTIyMzU3LCJ0eXBlIjoiY29uc3VtZXIiLCJhdWQiOm51bGwsInN1YiI6IjQyZWVkMWI3LWMwNzItNGRkZC04YWI1LTU0MzZlODZkMDViMCJ9.OhTPZP7eU_Jkl2cGK7nxnFmI8SWZWccgM2gxwpDkKwl9P9UslHN2rg1Hkm5LY3yyHrhBdzyUtuKFtiLR6jbp-QBVTcA7DjwqOYuxCpT-lWPMN7wNrvaRfPldUu3UlOpKMKN4jbGw0VcdJRiRPMUbaozyyvhzTvfhrWcna6P2sXiBl4dk2uz9eaqliHuU6dpozw1UIIw6_LFlak9kIB1g27CkK0Yf14TD17ibUF6KB6zUmyUoDJv370qOtEtvzIyYIWBTcDghVuRnuZd4MabmKWchPVaMO36j9-KuOOVqZIkuCHcfznRkB6The3Z29UHm0xGWYXQPro8jcPh1v63AuA",
                "Accept-Language": "de-DE",
                "accept": "application/vnd.oneka.v2.0+json"
            ]
        )
        let request = AF
            .request(
                url,
                method: .get,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .responseData { response in
                completion(response.result.mapError { $0 as Error })
            }
        request.resume()
        return HALAlamofireRequestContainer(dataRequest: request)
    }
}

struct HALAlamofireRequestContainer: RequestContainerInterface {

    let dataRequest: DataRequest

    func cancelRequest() {
        print("[CANCEL] dataRequest cancel")
        dataRequest.cancel()
    }
}
