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
		//message.reply(status_codes::OK, message.to_string());

		utility::string_t relURI = message.relative_uri().to_string();
		std::string relURIss = utility::conversions::to_utf8string(relURI);

		if (relURIss == "/current") {

			std::string sqlCmd = "SELECT * FROM CURRENTBOX";
			std::vector<std::map<std::string, std::string>> listOfRows = performSqlCommandMultiRow(sqlCmd.c_str());

			std::string currentSetID;
			std::string currentBoxID;
			currentSetID = listOfRows[0]["SETID"];
			currentBoxID = listOfRows[0]["BOXID"];

			std::string retCurs = "{ \"currentSetID\" : "+ currentSetID + ", \"currentBoxID\" : " + currentBoxID + " }";
			std::cout << retCurs << std::endl;
			message.reply(status_codes::OK, utility::conversions::to_string_t(retCurs));
		}
		else if (relURIss == "/setboxready") {

			// get the current box
			std::string sqlCmd = "SELECT * FROM CURRENTBOX";
			std::vector<std::map<std::string, std::string>> listOfRows = performSqlCommandMultiRow(sqlCmd.c_str());

			std::string currentSetID;
			std::string currentBoxID;
			currentSetID = listOfRows[0]["SETID"];
			currentBoxID = listOfRows[0]["BOXID"];

			// set it to ready
			sqlCmd = "UPDATE BOXES SET ready = 1 WHERE (ID = " + currentBoxID + " and SETID = " + currentSetID + ")";
			performSqlCommand(sqlCmd.c_str());
			message.reply(status_codes::OK, utility::conversions::to_string_t(""));
		}

		//std::string sqlCmd = "SELECT * FROM BOXES";
		//std::vector<std::map<std::string, std::string>> listOfRows = performSqlCommandMultiRow(sqlCmd.c_str());

		//for (auto it = listOfRows.begin(); it != listOfRows.end(); it++) {
		//	std::cout << "" << std::endl;
		//	for (auto it1 = it->begin(); it1 != it->end(); ++it1) {
		//		std::cout << it1->first << " " << it1->second << std::endl;
		//	}
		//}

		//sqlCmd = "UPDATE BOXES set ready = 1 WHERE id = 1";
		//performSqlCommand(sqlCmd.c_str());

		return;
	}

	void handle_POST(http_request message) {
		ucout << message.to_string() << std::endl;
		//message.reply(status_codes::OK, message.to_string());

		json::value v = message.extract_json().get();
		utility::string_t jsonval = v.serialize();
		ucout << "MYJSON:" << jsonval << "\n";

		utility::string_t relURI = message.relative_uri().to_string();
		ucout << "RELURI:" << relURI << '\n';
		std::string relURIss = utility::conversions::to_utf8string(relURI);

		std::cout << "RELURIss:" << relURIss << std::endl;
		if (relURIss == "/boxready") {

			std::cout << "Asking if box is ready" << std::endl;

			std::string JSONstring = utility::conversions::to_utf8string(jsonval);

			std::cout << "JSONstring: " << JSONstring << std::endl;
			
			nlohmann::json j = nlohmann::json::parse(JSONstring);

			// Compare the JSON values to BOXES table
			int setID = j["setID"];
			int boxID = j["boxID"];
			std::cout << "Parsed JSON:" << setID << " and " << boxID << std::endl;

			std::string sqlCmd = "SELECT READY FROM BOXES WHERE (ID = " + std::to_string(boxID) + " and SETID = "+ std::to_string(setID) +")";
			std::vector<std::map<std::string, std::string>> listOfRows = performSqlCommandMultiRow(sqlCmd.c_str());

			std::string readyFlag;
			readyFlag = listOfRows[0]["READY"];

			std::string retCurs = "{ \"boxReady\" : false }";
			if (readyFlag == "1")
				retCurs = "{ \"boxReady\" : true }";
			std::cout << retCurs << std::endl;
			message.reply(status_codes::OK, utility::conversions::to_string_t(retCurs));
		}
		else if(relURIss == "/datacheck") {

			std::string JSONstring = utility::conversions::to_utf8string(jsonval);
			nlohmann::json j = nlohmann::json::parse(JSONstring);

			std::cout << j["device"] << std::endl;
			
			std::string jsonDevice = j["device"];

			std::vector<std::string> deviceFields;

			if (jsonDevice == "p1") {
				std::cout << "phone1" << std::endl;
				deviceFields.push_back("CAM1LEN");
				deviceFields.push_back("CAM1WIDTH");
			}
			else if (jsonDevice == "p2") {
				std::cout << "phone2" << std::endl;
				deviceFields.push_back("CAM2LEN");
				deviceFields.push_back("CAM2WIDTH");
			}
			else if (jsonDevice == "d1") {
				std::cout << "ard1" << std::endl;
				deviceFields.push_back("CAM1DIST");
			}
			else if (jsonDevice == "d2") {
				std::cout << "ard2" << std::endl;
				deviceFields.push_back("CAM2DIST");
			}

			// TODO: Compare the JSON values to BOXES table
			// get current box
			std::string sqlCmd = "SELECT * FROM CURRENTBOX";
			std::vector<std::map<std::string, std::string>> listOfRows = performSqlCommandMultiRow(sqlCmd.c_str());

			std::string currentSetID;
			std::string currentBoxID;
			currentSetID = listOfRows[0]["SETID"];
			currentBoxID = listOfRows[0]["BOXID"];

			// get current box's dimension data for that device
			sqlCmd = "SELECT * FROM BOXES WHERE (ID = " + currentBoxID + " and SETID = " + currentSetID + ")";
			listOfRows = performSqlCommandMultiRow(sqlCmd.c_str());

			bool isDataPop = true;
			for (auto it = deviceFields.begin(); it != deviceFields.end(); it++) {
				std::string colName = *it;
				std::string colData = listOfRows[0][*it];
				std::cout << "Checking device data:" << colName << " : " << colData << std::endl;
				if (colData == "NULL") {
					isDataPop = false;
				}
			}

			// if all not NULL, datapopulated = true
			std::string retCurs = "{ \"dataPopulated\" : false }";
			if (isDataPop)
				retCurs = "{ \"dataPopulated\" : true }";
			std::cout << retCurs << std::endl;
			message.reply(status_codes::OK, utility::conversions::to_string_t(retCurs));

			// TO DO: if entire row BOXES table is populated, increment current Box ID
			// update CURRENTBOX and add new row into BOXES
		}
		else if (relURIss == "/senddata") {

			std::string JSONstring = utility::conversions::to_utf8string(jsonval);
			nlohmann::json j = nlohmann::json::parse(JSONstring);

			// parse current device
			std::cout << j["device"] << std::endl;

			std::string jsonDevice = j["device"];
			float jsonData1;
			float jsonData2;
			std::string updateCmd;
			std::vector<std::string> deviceFields;

			// get current box
			std::string sqlCmd = "SELECT * FROM CURRENTBOX";
			std::vector<std::map<std::string, std::string>> curBox = performSqlCommandMultiRow(sqlCmd.c_str());

			std::string currentSetID;
			std::string currentBoxID;
			currentSetID = curBox[0]["SETID"];
			currentBoxID = curBox[0]["BOXID"];
			
			// parse json fields and create update command
			if (jsonDevice == "p1") {
				std::cout << "phone1" << std::endl;
				deviceFields.push_back("CAM1LEN");
				deviceFields.push_back("CAM1WIDTH");
				jsonData1 = j["CAM1LEN"];
				jsonData2 = j["CAM1WIDTH"];
				updateCmd = "UPDATE BOXES SET CAM1LEN = " + std::to_string(jsonData1) + ", CAM1WIDTH = " + std::to_string(jsonData2) +" WHERE (ID = " + currentBoxID + " and SETID = " + currentSetID + ")";

			}
			else if (jsonDevice == "p2") {
				std::cout << "phone2" << std::endl;
				deviceFields.push_back("CAM2LEN");
				deviceFields.push_back("CAM2WIDTH");
				jsonData1 = j["CAM2LEN"];
				jsonData2 = j["CAM2WIDTH"];
				updateCmd = "UPDATE BOXES SET CAM2LEN = " + std::to_string(jsonData1) + ", CAM2WIDTH = " + std::to_string(jsonData2) + " WHERE (ID = " + currentBoxID + " and SETID = " + currentSetID + ")";
			}
			else if (jsonDevice == "d1") {
				std::cout << "ard1" << std::endl;
				deviceFields.push_back("CAM1DIST");
				jsonData1 = j["CAM1DIST"];
				updateCmd = "UPDATE BOXES SET CAM1DIST = " + std::to_string(jsonData1) + " WHERE (ID = " + currentBoxID + " and SETID = " + currentSetID + ")";

			}
			else if (jsonDevice == "d2") {
				std::cout << "ard2" << std::endl;
				deviceFields.push_back("CAM2DIST");
				jsonData1 = j["CAM2DIST"];
				updateCmd = "UPDATE BOXES SET CAM2DIST = " + std::to_string(jsonData1) + " WHERE (ID = " + currentBoxID + " and SETID = " + currentSetID + ")";
			}
			

			// update current box's dimension data for that device
			performSqlCommand(updateCmd.c_str());

			// get current box's dimension data for that device
			sqlCmd = "SELECT * FROM BOXES WHERE (ID = " + currentBoxID + " and SETID = " + currentSetID + ")";
			std::vector<std::map<std::string, std::string>> listOfRows = performSqlCommandMultiRow(sqlCmd.c_str());

			bool isDataPop = true;
			for (auto it = deviceFields.begin(); it != deviceFields.end(); it++) {
				std::string colName = *it;
				std::string colData = listOfRows[0][*it];
				std::cout << "Checking device data:" << colName << " : " << colData << std::endl;
				if (colData == "NULL") {
					isDataPop = false;
				}
			}
			std::string retCurs = "{ \"dataSet\" : false }";
			if (isDataPop)
				retCurs = "{ \"dataSet\" : true }";
			std::cout << retCurs << std::endl;
			message.reply(status_codes::OK, utility::conversions::to_string_t(retCurs));
		}


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
