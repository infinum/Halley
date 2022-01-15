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
                "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjNzg5NzRjZS1jODE4LTQwODItYThhOS1mYjkwYzE3MDM1NzkiLCJpc3MiOiJkZXYuYmFja2VuZC5rYS5waGlsaXBzLmNvbSIsInVzZXJuYW1lIjoiYzc4OTc0Y2UtYzgxOC00MDgyLWE4YTktZmI5MGMxNzAzNTc5IiwiZXhwIjoxNjQyMzM0NjgyLCJ0eXBlIjoiY29uc3VtZXIiLCJhdWQiOm51bGwsInN1YiI6ImM3ODk3NGNlLWM4MTgtNDA4Mi1hOGE5LWZiOTBjMTcwMzU3OSJ9.wrP9-M3zjbFRrebgF3eXrdnmUGK2c0f2AsNNABhd3nl1YojpPeljEr3kn3dLZiSFIiFy4rlYeCtAl5U_BIJVLJ_DVuZwbkymBflw85ZJPblzkMwiepar51qvVwhdkMPj_71kXJJGv9T9Nc7F2nfnDIKL1pE-tLBECrtNUd-mPryVBpC-wsja4Fanj460-UMkCHPmTnl4tgGPCwULsY5OlleFFW-6-u-DMxdBVtUQ85jxW8jhXKZjCp6TKzgbEo1vrtjiKsRS9-tCv0mY4vilIZRUBUWSgua_D5BF51PNzpANlaRl5ABOMJ35TV8VRiqK7cxFysciMrfC3CeIiukkiQ",
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
