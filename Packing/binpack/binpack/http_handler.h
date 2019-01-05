#pragma once
#include <string.h>

class HttpHandler {
public:
	int port;
	std::string url; 

	HttpHandler() {
		port = 80;
		url = "127.0.0.1"; 
	}
	~HttpHandler() {}

	bool handle_post();
};
