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
                "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjN2Y1NTI1MC1lY2NlLTRkNTItODBkNS0zMDI5ZjYzOTc2YTMiLCJpc3MiOiJkZXYuYmFja2VuZC5rYS5waGlsaXBzLmNvbSIsInVzZXJuYW1lIjoiYzdmNTUyNTAtZWNjZS00ZDUyLTgwZDUtMzAyOWY2Mzk3NmEzIiwiZXhwIjoxNjQ2NDEyOTE5LCJ0eXBlIjoiY29uc3VtZXIiLCJhdWQiOm51bGwsInN1YiI6ImM3ZjU1MjUwLWVjY2UtNGQ1Mi04MGQ1LTMwMjlmNjM5NzZhMyJ9.WYAeSxO3xBBtj_H3oRaVFYoBj1ykTh6yIUR9NoccBo00Q2t2ybsayVcJnou940vk7x5yGbaiCJ1Cbs3sr9GZmLgCOlI-BS1YFycNbQopeqZWoDSDWkyNs5hSFpT0MX1kRsWkFQAHqJWG4-7PBSdcyBq2egW2TFJoOTP13-YGxPoKGkxpTurLth4AcGkaA0HS5wdv06FRAIh17uAnV6LLUtIcgH0hP3RViqZjEjEhAxEuEk0QYaC-ACN3EYTtly4XtlvlPTCMvfxBXfxgNdu-3Ysl89L0JSjN75mlAZdUnKxR98UizbcKOSeXktrYANcm90jbqf2uJk32OQpcUpPB5Q",
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
