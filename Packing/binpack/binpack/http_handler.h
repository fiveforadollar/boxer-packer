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
#include <ctime>

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
		else if (relURIss == "/sets") {

			std::string sqlCmd = "SELECT DISTINCT SETID FROM BOXES";

			auto jsonSetIDs = nlohmann::json::array();

			std::vector<std::map<std::string, std::string>> listOfRows = performSqlCommandMultiRow(sqlCmd.c_str());
			for (int it1 = 0; it1 < listOfRows.size(); it1++) {
				bool isFullRow = true;
				for (auto it = listOfRows[it1].begin(); it != listOfRows[it1].end(); it++) {
					std::string curSetID = it->second;
					std::string fName = "set" + curSetID + ".json";
					std::ifstream infile(fName);
					if (infile.good()) {
						std::ifstream i(fName);
						nlohmann::json jFile;
						nlohmann::json jOut;

						i >> jFile;
						std::string curDate = jFile["datetime"];
						int numBoxes = 0;
						for (auto& x : jFile["pallets"].items()) {
							numBoxes += x.value()["numBoxes"];
						}
						std::cout << curDate << std::endl;

						jOut["setID"] = stoi(curSetID);
						jOut["datetime"] = curDate;
						jOut["numBoxes"] = numBoxes;
						jsonSetIDs.push_back(jOut);
					}
				}
			}
			std::cout << jsonSetIDs.dump(4) << std::endl;
			message.reply(status_codes::OK, utility::conversions::to_string_t(jsonSetIDs.dump(4)));
		}
		else if (relURIss == "/setdone") {

			// get the current box
			std::string sqlCmd = "SELECT * FROM CURRENTBOX";
			std::vector<std::map<std::string, std::string>> listOfRows = performSqlCommandMultiRow(sqlCmd.c_str());

			std::string currentSetID;
			std::string currentBoxID;
			currentSetID = listOfRows[0]["SETID"];
			currentBoxID = listOfRows[0]["BOXID"];

			// increment both currentSetID and currentBoxID
			// update currentbox
			// create new row in boxes
			std::string updatedBoxID = std::to_string(std::stoi(currentBoxID) + 1);
			std::string updatedSetID = std::to_string(std::stoi(currentSetID) + 1);

			sqlCmd = "UPDATE CURRENTBOX SET BOXID = " + updatedBoxID + ", SETID = " + updatedSetID;
			performSqlCommandMultiRow(sqlCmd.c_str());

			sqlCmd = "INSERT INTO BOXES (ID, READY, SETID) VALUES (" + updatedBoxID + ",0," + updatedSetID + ");";
			performSqlCommandMultiRow(sqlCmd.c_str());

			// get the updated box (sanity check)
			sqlCmd = "SELECT * FROM CURRENTBOX";
			std::vector<std::map<std::string, std::string>> listOfNewRows = performSqlCommandMultiRow(sqlCmd.c_str());

			std::string  currentSetID2 = listOfNewRows[0]["SETID"];
			std::string  currentBoxID2 = listOfNewRows[0]["BOXID"];

			std::string retCurs = "{ \"currentSetID\" : " + currentSetID2 + ", \"currentBoxID\" : " + currentBoxID2 + " }";
			std::cout << retCurs << std::endl;

			//message.reply(status_codes::OK, utility::conversions::to_string_t(retCurs));

			// TO DO: perform bin packing
			std::string setToPack = currentSetID;
			sqlCmd = "SELECT * FROM BOXES WHERE (SETID = " + currentSetID + ")";
			std::vector<std::map<std::string, std::string>> boxDimensions = performSqlCommandMultiRow(sqlCmd.c_str());

			std::vector<Box *> unpackedBoxes;
			std::vector<double> sortedPalletDims{ P_HEIGHT, P_LENGTH, P_WIDTH };
			std::sort(sortedPalletDims.begin(), sortedPalletDims.end());

			for (int it1 = 0; it1 < boxDimensions.size(); it1++) {
				bool isFullRow = true;
				for (auto it = boxDimensions[it1].begin(); it != boxDimensions[it1].end(); it++) {
					std::string colName = it->first;
					std::string colData = it->second;
					std::cout << "Checking full row data:" << colName << " : " << colData << std::endl;
					if (colData == "NULL") {
						isFullRow = false; // TO DO: flip to false when done testing
					}
				}
				if (isFullRow) {
					// calculate box dimensions based on p1 p2 focal length numbers

					// cam1
					double cam1dist = stod(boxDimensions[it1]["CAM1DIST"]);
					double cam1len = stod(boxDimensions[it1]["CAM1LEN"]);
					double cam1width = stod(boxDimensions[it1]["CAM1WIDTH"]);

					double cam1focal = 63.0;
					double cam1pointsize = (1.0 / 6.0);

					double cam1len_real = (cam1dist - cam1focal) * (cam1len * cam1pointsize) / cam1focal;
					double cam1width_real = (cam1dist - cam1focal) * (cam1width * cam1pointsize) / cam1focal;

					// cam2
					double cam2dist = stod(boxDimensions[it1]["CAM2DIST"]);
					double cam2len = stod(boxDimensions[it1]["CAM2LEN"]);
					double cam2width = stod(boxDimensions[it1]["CAM2WIDTH"]);

					double cam2focal = 70.2;
					double cam2pointsize = (1.0 / 6.0);

					double cam2len_real = (cam2dist - cam2focal) * (cam2len * cam2pointsize) / cam2focal;
					double cam2width_real = (cam2dist - cam2focal) * (cam2width * cam2pointsize) / cam2focal;
					
					int dbID = stoi(boxDimensions[it1]["ID"]);

					double boxLength = cam1len_real;
					double boxWidth = cam2len_real;
					double boxHeight = (cam1width_real + cam2width_real) / 2.0;

					// convert mm to m
					boxLength = boxLength /1000.0;
					boxWidth = boxWidth / 1000.0;
					boxHeight = boxHeight / 1000.0;


					bool notOversize = true;
					std::vector<double> sortedDims{ boxLength, boxWidth, boxHeight };
					std::sort(sortedDims.begin(), sortedDims.end());

					if (sortedDims[0] > sortedPalletDims[0] || sortedDims[1] > sortedPalletDims[1] || sortedDims[2] > sortedPalletDims[2])
						notOversize = false;

					if (notOversize) {
						// create new box object and add to unpacked Boxes
						Box* box = new Box(boxLength, boxWidth, boxHeight, dbID);
						unpackedBoxes.push_back(box);
					}
					else {
						std::cout << "Oversized box detected with dbID: " << dbID << std::endl;
					}

				}
			}

			// Do the packing:
			//unpackedBoxes = readBoxesFromJson("C:\\Users\\WLaptop\\testData.json");

			// TO DO: remove this
			//Box* box = new Box(P_LENGTH/2, P_WIDTH/2, P_HEIGHT*0.9, 1);
			//Box* box2 = new Box(P_LENGTH/2, P_WIDTH/2, P_HEIGHT*0.9, 2);
			//Box* box3 = new Box(P_LENGTH/2, P_WIDTH/2, P_HEIGHT*0.9, 3);
			//Box* box4 = new Box(P_LENGTH/2, P_WIDTH/2, P_HEIGHT*0.9, 4);
			//Box* box5 = new Box(P_LENGTH, P_WIDTH, P_HEIGHT*0.09, 4);

			//unpackedBoxes.push_back(box);
			//unpackedBoxes.push_back(box2);
			//unpackedBoxes.push_back(box3);
			//unpackedBoxes.push_back(box4);
			//unpackedBoxes.push_back(box5);


			// sort unpackedBoxes by volume
			std::sort(unpackedBoxes.begin(), unpackedBoxes.end(), comparePtrToBox);
			//std::reverse(unpackedBoxes.begin(), unpackedBoxes.end());

			// Perform packing
			int iteration = 1;
			while (unpackedBoxes.size() != 0) {
				std::cout << "\nStarting iteration " << iteration << "..." << std::endl;
				std::cout << "Before packing, number of unpacked boxes: " << unpackedBoxes.size() << std::endl;
				std::cout << "Before packing, number of pallets: " << openPallets.size() << std::endl;
				for (int i = 0; i < openPallets.size(); i++) {
					std::cout << "\tPallet " << i << " contains " << openPallets[i]->items.size() << " boxes" << std::endl;
				}

				unpackedBoxes = runFirstFit(unpackedBoxes);
				std::sort(unpackedBoxes.begin(), unpackedBoxes.end(), comparePtrToBox);
				++iteration;
			}

			std::cout << "After packing, number of unpacked boxes: " << unpackedBoxes.size() << std::endl;
			std::cout << "After packing, number of pallets: " << openPallets.size() << std::endl;

			nlohmann::json jsonObject;
			jsonObject["setID"] = stoi(setToPack);
			auto jsonPallets = nlohmann::json::array();

			// Spit out results inside openPallets to JSON and store it somewhere
			for (int i = 0; i < openPallets.size(); i++) {
				std::cout << "\tPallet " << i << " contains " << openPallets[i]->items.size() << " boxes" << std::endl;

				nlohmann::json jPallet;
				jPallet["id"] = openPallets[i]->id;
				jPallet["numBoxes"] = openPallets[i]->items.size();
				auto palletItems = nlohmann::json::array();

				for (int j = 0; j < openPallets[i]->items.size(); j++) {
					std::cout << '\t' << *openPallets[i]->items.at(j);
					nlohmann::json jBox;
					jBox["id"] = openPallets[i]->items.at(j)->id;
					jBox["length"] = openPallets[i]->items.at(j)->length;
					jBox["width"] = openPallets[i]->items.at(j)->width;
					jBox["height"] = openPallets[i]->items.at(j)->height;
					jBox["position"] = { openPallets[i]->items.at(j)->position[0], openPallets[i]->items.at(j)->position[1], openPallets[i]->items.at(j)->position[2] };

					palletItems.push_back(jBox);
				}

				jPallet["items"] = palletItems;
				jsonPallets.push_back(jPallet);

			}
			jsonObject["pallets"] = jsonPallets;

			time_t now;
			time(&now);
			char buf[sizeof "2011-10-08T07:07:09Z"];
			strftime(buf, sizeof buf, "%FT%TZ", gmtime(&now));

			jsonObject["datetime"] = std::string(buf);

			std::string jsonString = jsonObject.dump(4);
			std::cout << "JSON:" << jsonString << std::endl;
			message.reply(status_codes::OK, utility::conversions::to_string_t(jsonString));

			// write to file with setID name
			std::string fileName = "set" + setToPack + ".json";
			std::ofstream o(fileName);
			o << std::setw(4) << jsonObject << std::endl;

			// Teardown the pallets and boxes
			teardown();
			openPallets.clear();
			Box::resetCounter();
			std::cout << "After teardown, num pallets: " << openPallets.size() << std::endl;
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
		else if (relURIss == "/getset") {

			std::string JSONstring = utility::conversions::to_utf8string(jsonval);
			std::cout << "JSONstring: " << JSONstring << std::endl;

			nlohmann::json j = nlohmann::json::parse(JSONstring);

			// Read in the json file
			int setID = j["setID"];
			std::cout << "Parsed JSON:" << setID << std::endl;

			std::string fName = "set" + std::to_string(setID) + ".json";
			std::ifstream i(fName);
			nlohmann::json jOut;
			i >> jOut;

			std::string retCurs = jOut.dump(4);
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

			// Compare the JSON values to BOXES table
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


			// if entire row BOXES table is populated, increment current Box ID
			// update CURRENTBOX and add new row into BOXES
			bool isDataFullPop = true;
			for (auto it = listOfRows[0].begin(); it != listOfRows[0].end(); it++) {
				std::string colName = it->first;
				std::string colData = it->second;
				std::cout << "Checking full row data:" << colName << " : " << colData << std::endl;
				if (colData == "NULL") {
					isDataFullPop = false;
				}
			}

			if (isDataFullPop) {
				std::cout << "Row is full, add a new box and update currentBoxID" << std::endl;
				
				std::string updatedBoxID = std::to_string(std::stoi(currentBoxID) + 1);
				std::string sqlCmd = "UPDATE CURRENTBOX SET BOXID = " + updatedBoxID;
				performSqlCommandMultiRow(sqlCmd.c_str());

				sqlCmd = "INSERT INTO BOXES (ID, READY, SETID) VALUES (" + updatedBoxID + ",0," + currentSetID + ");";
				performSqlCommandMultiRow(sqlCmd.c_str());
			}
			else {
				std::cout << "Row is not full, keep accepting data" << std::endl;
			}
		}
		else if (relURIss == "/checkrejected") {

			std::string JSONstring = utility::conversions::to_utf8string(jsonval);

			std::cout << "JSONstring: " << JSONstring << std::endl;

			nlohmann::json j = nlohmann::json::parse(JSONstring);

			// Compare the JSON values to BOXES table
			int currentSetID = j["setID"];
			int currentBoxID = j["boxID"];
			std::cout << "Parsed JSON:" << currentSetID << " and " << currentBoxID << std::endl;

			std::string sqlCmd = "SELECT * FROM BOXES WHERE (SETID = " + std::to_string(currentSetID) + " AND ID = "+ std::to_string(currentBoxID) + ")";
			std::vector<std::map<std::string, std::string>> boxDimensions = performSqlCommandMultiRow(sqlCmd.c_str());

			std::vector<double> sortedPalletDims{ P_HEIGHT, P_LENGTH, P_WIDTH };
			std::sort(sortedPalletDims.begin(), sortedPalletDims.end());

			for (int it1 = 0; it1 < boxDimensions.size(); it1++) {
				bool isFullRow = true;
				for (auto it = boxDimensions[it1].begin(); it != boxDimensions[it1].end(); it++) {
					std::string colName = it->first;
					std::string colData = it->second;
					std::cout << "Checking full row data:" << colName << " : " << colData << std::endl;
					if (colData == "NULL") {
						isFullRow = false; // TO DO: flip to false when done testing
					}
				}
				if (isFullRow) {
					// calculate box dimensions based on p1 p2 focal length numbers

					// cam1
					double cam1dist = stod(boxDimensions[it1]["CAM1DIST"]);
					double cam1len = stod(boxDimensions[it1]["CAM1LEN"]);
					double cam1width = stod(boxDimensions[it1]["CAM1WIDTH"]);

					double cam1focal = 63.0;
					double cam1pointsize = (1.0 / 6.0);

					double cam1len_real = (cam1dist - cam1focal) * (cam1len * cam1pointsize) / cam1focal;
					double cam1width_real = (cam1dist - cam1focal) * (cam1width * cam1pointsize) / cam1focal;

					// cam2
					double cam2dist = stod(boxDimensions[it1]["CAM2DIST"]);
					double cam2len = stod(boxDimensions[it1]["CAM2LEN"]);
					double cam2width = stod(boxDimensions[it1]["CAM2WIDTH"]);

					double cam2focal = 70.2;
					double cam2pointsize = (1.0 / 6.0);

					double cam2len_real = (cam2dist - cam2focal) * (cam2len * cam2pointsize) / cam2focal;
					double cam2width_real = (cam2dist - cam2focal) * (cam2width * cam2pointsize) / cam2focal;

					int dbID = stoi(boxDimensions[it1]["ID"]);

					double boxLength = cam1len_real;
					double boxWidth = cam2len_real;
					double boxHeight = (cam1width_real + cam2width_real) / 2.0;

					// convert mm to m
					boxLength = boxLength / 1000.0;
					boxWidth = boxWidth / 1000.0;
					boxHeight = boxHeight / 1000.0;

					std::cout << "Box with dimensions (meters): " << boxLength << " x " << boxWidth << " x " << boxHeight << std::endl;
					std::cout << "cam1width real: " << cam1width_real << std::endl;
					std::cout << "cam2width real: " << cam2width_real << std::endl;
					
					bool notOversize = true;
					std::vector<double> sortedDims{ boxLength, boxWidth, boxHeight };
					std::sort(sortedDims.begin(), sortedDims.end());

					if (sortedDims[0] > sortedPalletDims[0] || sortedDims[1] > sortedPalletDims[1] || sortedDims[2] > sortedPalletDims[2])
						notOversize = false;

					std::string retCurs = "{ \"rejected\" : true }";
					if (notOversize){
						retCurs = "{ \"rejected\" : false }";
						std::cout << "Not rejected, Box with ID: " << currentBoxID << std::endl;
					}
					else {
						std::cout << "Rejected, Box with ID: " << currentBoxID << std::endl;
					}
					std::cout << retCurs << std::endl;
					message.reply(status_codes::OK, utility::conversions::to_string_t(retCurs));

				}
			}

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
