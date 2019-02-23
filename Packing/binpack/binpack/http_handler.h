#pragma once
#include <string.h>
#include <iostream>
#include "cpprest/json.h"
#include "cpprest/http_listener.h"
#include "cpprest/uri.h"
#include "cpprest/asyncrt_utils.h"
#include "cpprest/json.h"
#include "cpprest/filestream.h"
#include "cpprest/containerstream.h"
#include "cpprest/producerconsumerstream.h" 
#include "binpack.h"

using namespace utility;                    // Common utilities like string conversions
using namespace web;                        // Common features like URIs.
using namespace web::http;                  // Common HTTP functionality
using namespace web::http::client;          // HTTP client features
using namespace concurrency::streams;       // Asynchronous streams
using namespace web::http::experimental::listener;
using namespace web::json;


class HttpHandler {
public:
	utility::string_t port;
	utility::string_t url;
	http_listener * listener;

	HttpHandler(utility::string_t _url, utility::string_t _port) {
		port = _port;
		url = _url;
	
		utility::string_t address = url;
		address.append(port);
		uri_builder uri(address);
		auto addr = uri.to_uri().to_string();
		listener = new http_listener(addr);

		listener->support(methods::GET, std::bind(&HttpHandler::handle_GET, this, std::placeholders::_1));
		listener->support(methods::POST, std::bind(&HttpHandler::handle_POST, this, std::placeholders::_1));

	}

	pplx::task<void>open() { return listener->open(); }
	pplx::task<void>close() { return listener->close(); }

	void handle_GET(http_request message) {
		ucout << message.to_string() << std::endl;
		message.reply(status_codes::OK, message.to_string());

		json::value v = message.extract_json().get();
		utility::string_t jsonval = v.serialize();
		ucout << "MYJSON:" << jsonval << "\n";
		return;
	}

	void handle_POST(http_request message) {
		ucout << message.to_string() << std::endl;
		message.reply(status_codes::OK, message.to_string());

		json::value v = message.extract_json().get();
		utility::string_t jsonval = v.serialize();
		ucout << "MYJSON:" << jsonval << "\n";

		//auto http_get_vars = uri::split_query(message.request_uri().query());
		//for (auto it = http_get_vars.cbegin(); it != http_get_vars.cend(); ++it)
		//{
		//	ucout << it->first << " " << it->second << "\n";
		//}


		return;
	}

	~HttpHandler() {
		delete listener;
	}

};
