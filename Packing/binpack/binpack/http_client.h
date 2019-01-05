# pragma once 

#include <cpprest/http_client.h>
#include <cpprest/http_msg.h>
#include <cpprest/filestream.h>

using namespace utility;                    // Common utilities like string conversions
using namespace web;                        // Common features like URIs.
using namespace web::http;                  // Common HTTP functionality
using namespace web::http::client;          // HTTP client features
using namespace concurrency::streams;       // Asynchronous streams

// Client for sending mock POST requests
class HttpClient {
public:
	utility::string_t target_url; 
	utility::string_t http_method;
	utility::string_t data_type;

	HttpClient(utility::string_t _target_url, utility::string_t _http_method, utility::string_t _data_type) {
		target_url = _target_url; 
		http_method = _http_method;
		data_type = _data_type;
	}

	void sendRequest() {
		auto fileStream = std::make_shared<ostream>();

		// Open stream to output file.
		pplx::task<void> requestTask = fstream::open_ostream(U("C:\\Users\\james\\OneDrive\\Desktop\\My_Stuff\\Senior (2018-2019)\\Courses\\Capstone\\boxer-packer\\Packing\\binpack\\binpack\\mock_client_results.txt")).then([=](ostream outFile) {
			*fileStream = outFile;

			// Create http_client to send the request.
			http_client client(target_url);

			// Dummy JSON data to attach to POST request
			json::value postData;
			postData[L"name"] = json::value::string(L"Joe Smith");
			postData[L"sport"] = json::value::string(L"Baseball");

			// Create HTTP request
			http_request client_req = http_request();

			if (http_method == U("POST")) {
				std::cout << "POST REQUEST\n";
				client_req.set_method(methods::POST);
				client_req.set_body(postData.serialize(), data_type);
				return client.request(client_req);
			}
		})

		// Handle response headers arriving.
		.then([=](http_response response) {
			std::cout << "Received response status code:" << response.status_code() << std::endl;
			if (response.status_code() == status_codes::OK) {
				auto body = response.extract_string();
				std::cout << body.get().c_str();
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