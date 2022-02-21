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
                "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjYjMzZjZkYi0xOTMyLTRlYTgtODU3ZC1jMmFhM2I0ZmMzMmUiLCJpc3MiOiJkZXYuYmFja2VuZC5rYS5waGlsaXBzLmNvbSIsInVzZXJuYW1lIjoiY2IzM2Y2ZGItMTkzMi00ZWE4LTg1N2QtYzJhYTNiNGZjMzJlIiwiZXhwIjoxNjQ2MDY2ODg5LCJ0eXBlIjoiY29uc3VtZXIiLCJhdWQiOm51bGwsInN1YiI6ImNiMzNmNmRiLTE5MzItNGVhOC04NTdkLWMyYWEzYjRmYzMyZSJ9.egzI66hEZki15_IAT17_FAtaUTgTSFP1iH01Nu6_rvurhA7ONn2UGqgJRdVjJTnRqn7vQRJSUXUQU5HOSZlnCQNRjKdD6sctBqbS4dbViU0FwvtXPiKOD0iGWBpHM8fF3jw-y2maOt5rmP-7JNYb5m0s5Isu1H8RL_t8V864TkxCB7zIU1cW2nfnLlKgNgnGyE1zS3SKHrbsmI00NP6dT7SZsn3WPszyG2xEgEpdnr7xOy7-3-Wv5S8P3th4is8Q8kXxlcXwRi2hgKZh5ZL5IWEsFXFmLDcZp4myIhs8duLC1YXxA5L-g_u_XR6_D9KLjvPvzBLrem_NTsmLIaJsUw",
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
