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
                "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI0MmVlZDFiNy1jMDcyLTRkZGQtOGFiNS01NDM2ZTg2ZDA1YjAiLCJpc3MiOiJkZXYuYmFja2VuZC5rYS5waGlsaXBzLmNvbSIsInVzZXJuYW1lIjoiNDJlZWQxYjctYzA3Mi00ZGRkLThhYjUtNTQzNmU4NmQwNWIwIiwiZXhwIjoxNjQ3MjgwMTkyLCJ0eXBlIjoiY29uc3VtZXIiLCJhdWQiOm51bGwsInN1YiI6IjQyZWVkMWI3LWMwNzItNGRkZC04YWI1LTU0MzZlODZkMDViMCJ9.iIjyFOQxfjoIp1182-5rGipTKeU9-TAXK62Tqwrns3IQGB5POFr8t0xuqQbZyL5kUT3KIDXQVwKY5cEV5kbG6cUru9_FTkhFViAx-ozdvIQVT0jWBvrcElf-Pw-Hdxi8uMWcSx6oqdFqkojgPPxMjhCtDEsBrRaTwSq5S8N06Z3OBY3k5mINdoBTcVwTYDjHqlg-juc32K7OyMUS8mlk6205zDwYXBAwcge_1GNO-edzyesxFSpk9WIHlqoVIs4pidtqnvTbYjJiogX5V4Vf_t5VA7HkzaQD4_M3ctIsXmJs7UXbnB76bs2QoJpCvJyR2EAc1OF19vMfdfpTUdEjSQ",
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
