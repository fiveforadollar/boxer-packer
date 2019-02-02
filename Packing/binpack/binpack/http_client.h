# pragma once 

#include <cpprest/http_client.h>
#include <cpprest/http_msg.h>
#include <cpprest/filestream.h>

using namespace utility;                    // Common utilities like string conversions
using namespace web;                        // Common features like URIs.
using namespace web::http;                  // Common HTTP functionality
using namespace web::http::client;          // HTTP client features
using namespace concurrency::streams;       // Asynchronous streams

/* Client for sending mock HTTP requests
   Currently supports:
	- POST
*/
class HttpClient {
public:
	utility::string_t targetUrl; 
	utility::string_t outputPath;

	HttpClient(utility::string_t _targetUrl, utility::string_t _outputPath) {
		targetUrl = _targetUrl;
		outputPath = _outputPath;
	}

	void sendRequest(std::string httpMethod, utility::string_t dataType, json::value postData) {
		auto fileStream = std::make_shared<ostream>();

		// Open stream to output file.
		pplx::task<void> requestTask = fstream::open_ostream(outputPath).then([=](ostream outFile) {
			*fileStream = outFile;

			// Create http_client to send the request.
			http_client client(targetUrl);

			// Create HTTP request
			http_request client_req = http_request();
			std::cout << "Sending " << httpMethod << " request!\n";

			if (httpMethod == "POST") {
				client_req.set_method(methods::POST);
				client_req.set_body(postData.serialize(), dataType);
				ucout << utility::string_t(U("Sending request to target: ")) << targetUrl << std::endl;
				ucout << utility::string_t(U("Data being sent: ")) << postData << std::endl;
				return client.request(client_req);
			}
		})

		// Handle response headers arriving.
		.then([=](http_response response) {
			std::cout << "Received response status code: " << response.status_code() << std::endl;
			if (response.status_code() == status_codes::OK) {
				auto body = response.extract_string();
	//			std::cout << body.get().c_str();
			}

			// Write response body into the file.
			return response.body().read_to_end(fileStream->streambuf());
		})

		// Close the file stream.
		.then([=](size_t) {
			return fileStream->close();
		});

		// Wait for all the outstanding I/O to complete and handle any exceptions
		try {
			requestTask.wait();
		}
		catch (const std::exception &e) {
			printf("Error exception:%s\n", e.what());
		}
	}
};