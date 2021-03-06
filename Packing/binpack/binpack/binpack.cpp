﻿#include "binpack.h"
#include "http_client.h"
#include "http_handler.h"

#define DEBUG 1
#define USE_FILE_INPUT 1
#define USE_HTTP_CLIENT 0
#define USE_HTTP_LISTENER 1
#define USE_MAIN_BINPACK 0

/******************* Globals ******************/

// Pallets in use
std::vector<Pallet*> openPallets;

int axisIds[3] = {
	LENGTH_AXIS_ID, 
	WIDTH_AXIS_ID, 
	HEIGHT_AXIS_ID 
};
 
/*********************************************/

/****************** Helpers ******************/

std::vector<Box*> initiatePacking() {
	std::vector<Box*> unpackedBoxes;
	
	if (USE_FILE_INPUT) {
		//unpackedBoxes = readBoxesFromJson("sample_data\\hard.json");
		unpackedBoxes = readBoxesFromJson("C:\\Users\\james\\OneDrive\\Desktop\\My_Stuff\\Senior (2018-2019)\\Courses\\Capstone\\boxer-packer\\Packing\\binpack\\binpack\\hard.json");
	}
	else {
		Box* box1 = new Box(P_LENGTH - 1, P_WIDTH - 1, P_HEIGHT - 1);
		Box* box2 = new Box(P_HEIGHT - 1, P_LENGTH - 1, P_WIDTH - 1);
		Box* box3 = new Box(1, 1, 1);
		unpackedBoxes.push_back(box1);
		unpackedBoxes.push_back(box2);
		unpackedBoxes.push_back(box3);
	}

	return unpackedBoxes;
}

std::vector<Box*> readBoxesFromJson(std::string fp) {
	std::vector<Box*> myBoxes;
	std::ifstream infile{ fp };
	nlohmann::json boxes;
	infile >> boxes;
	for (int i = 0; i < boxes.size(); i++) {
		Box * tempBox = new Box(boxes[i]["length"], boxes[i]["width"], boxes[i]["height"]);
		myBoxes.push_back(tempBox);
	}

	return myBoxes;
}

void openNewPallet() {
	if (DEBUG) {
		std::cout << "Creating new pallet (#" << openPallets.size() << ")\n";
	}
	openPallets.push_back(new Pallet());
}

bool intersect(Box* box1, Box* box2) {
	return (
		overlap(box1, box2, LENGTH_AXIS_ID, WIDTH_AXIS_ID) &&
		overlap(box1, box2, LENGTH_AXIS_ID, HEIGHT_AXIS_ID) &&
		overlap(box1, box2, WIDTH_AXIS_ID, HEIGHT_AXIS_ID));
}

bool overlap(Box* box1, Box* box2, const int axisId1, const int axisId2) {
	std::vector<double> dimBox1 = box1->getDimensions();
	std::vector<double> dimBox2 = box2->getDimensions();
	std::vector<double> posBox1 = box1->position;
	std::vector<double> posBox2 = box2->position;

	double midpointX1 = posBox1[axisId1] + dimBox1[axisId1] / 2.0;
	double midpointX2 = posBox2[axisId1] + dimBox2[axisId1] / 2.0;
	double midpointY1 = posBox1[axisId2] + dimBox1[axisId2] / 2.0;
	double midpointY2 = posBox2[axisId2] + dimBox2[axisId2] / 2.0;

	double overallX, overallY;

	if (midpointX1 > midpointX2)
		overallX = midpointX1 - midpointX2;
	else
		overallX = midpointX2 - midpointX1;

	if (midpointY1 > midpointY2)
		overallY = midpointY1 - midpointY2;
	else
		overallY = midpointY2 - midpointY1;

	return overallX < ((dimBox1[axisId1] + dimBox2[axisId1]) / 2.0) && overallY < ((dimBox1[axisId2] + dimBox2[axisId2]) / 2.0);
}

bool boxInBounds(Box *item, Pallet *pallet, std::vector<double> pivot) {
	return (
		pivot[LENGTH_AXIS_ID] + item->length <= pallet->length &&
		pivot[WIDTH_AXIS_ID] + item->width <= pallet->width &&
		pivot[HEIGHT_AXIS_ID] + item->height <= pallet->height
		);
}

void teardown() {
	for (Pallet *pallet : openPallets) {
		for (Box *box : pallet->items) {
			delete(box);
		}
		delete(pallet);
	}
}

/*********************************************/

/**************** First Fit ******************/

std::vector<Box *> runFirstFit(std::vector<Box *> items) {
	openNewPallet();

	std::vector<Box *> notPacked;

	/*  If there exists an empty pallet:
		1. It will be the last one in openPallets
		2. The next item should be placed in it at pivot point (0,0,0) */
	if (openPallets.back()->items.size() == 0) {
		Box *toBePlacedItem = items.back();
		items.pop_back();
		placeItem(toBePlacedItem, openPallets.back(), { 0, 0, 0 });
	}

	while (items.size() > 0) {
		Box *toBePlacedItem = items.back();
		items.pop_back();

		// Did not find a placement for the item
		if (!permutePlacements(toBePlacedItem)) {
			notPacked.push_back(toBePlacedItem);
		}
	}
	return notPacked;
}

bool permutePlacements(Box *toBePlacedItem) {
	for (Pallet *currPallet : openPallets) {
		// Check all items in the pallet
		for (Box *currPlacedItem : currPallet->items) {
			// Check all pivots for the current item
			for (int axisId : axisIds) {
				std::vector<double> pivotPoint;

				switch (axisId) {
				case LENGTH_AXIS_ID: {
					pivotPoint = {
						currPlacedItem->position[LENGTH_AXIS_ID] + currPlacedItem->length,
						currPlacedItem->position[WIDTH_AXIS_ID],
						currPlacedItem->position[HEIGHT_AXIS_ID]
					};
					break;
				}
				case WIDTH_AXIS_ID: {
					pivotPoint = {
						currPlacedItem->position[LENGTH_AXIS_ID],
						currPlacedItem->position[WIDTH_AXIS_ID] + currPlacedItem->width,
						currPlacedItem->position[HEIGHT_AXIS_ID]
					};
					break;
				}
				case HEIGHT_AXIS_ID: {
					pivotPoint = {
						currPlacedItem->position[LENGTH_AXIS_ID],
						currPlacedItem->position[WIDTH_AXIS_ID],
						currPlacedItem->position[HEIGHT_AXIS_ID] + currPlacedItem->height
					};
					break;
				}
				default: {
					std::cout << "ERROR: Invalid Axis ID provided\n";
				}
				}

				// Successful placement of item
				if (placeItem(toBePlacedItem, currPallet, pivotPoint)) {
					return true;
				}
			}
		}
	}
	return false;
}

bool placeItem(Box *item, Pallet *pallet, std::vector<double> pivotPoint) {
	double pLength = pallet->length;
	double pWidth = pallet->width;
	double pHeight = pallet->height;

	item->position = pivotPoint;

	bool foundPlacement = false;
	std::vector <Box*> itemOrientations = item->getOrientations();
	for (Box *itemOrientation : itemOrientations) {
		// Item does not fit in the pallet at the given pivot
		if (!boxInBounds(itemOrientation, pallet, pivotPoint)) {
			continue;
		}

		// Check if the box's placement would overlap with any other boxes in the pallet
		bool intersectExists = false;
		for (Box *currBox : pallet->items) {
			if (intersect(currBox, itemOrientation)) {
				intersectExists = true;
				break;
			}
		}

		// Check if placing box in current location would cause an overhang
		bool overhangExists = false;
		
		if (pivotPoint[HEIGHT_AXIS_ID] == 0) {
			// no overhang if we are placing on the floor of pallet
			bool overhangExists = false;
		}
		else {
			// get all boxes that create a "level floor" at that pivot
			std::vector<Box * > levelBoxes;

			for (Box *currBox : pallet->items) {
				double currBoxLevelHeight = currBox->position[HEIGHT_AXIS_ID] + currBox->height;
				if (currBoxLevelHeight == pivotPoint[HEIGHT_AXIS_ID])
					levelBoxes.push_back(currBox);
				//std::cout << "LevelHeight: " << currBoxLevelHeight << " | TestHeight:" << pivotPoint[HEIGHT_AXIS_ID] <<  std::endl;
			}

			// check if pivotPoint sits on top of a level floor
			bool corner0sitting = false;
			bool corner1sitting = false;
			bool corner2sitting = false;
			bool corner3sitting = false;

			double myXmin = pivotPoint[LENGTH_AXIS_ID];
			double myXmax = myXmin + itemOrientation->length;

			double myYmin = pivotPoint[WIDTH_AXIS_ID];
			double myYmax = myYmin + itemOrientation->width;

			for (int i = 0; i < levelBoxes.size(); i++) {
				Box *currBox = levelBoxes[i];
				double xmin = currBox->position[LENGTH_AXIS_ID];
				double xmax = xmin + currBox->length;

				double ymin = currBox->position[WIDTH_AXIS_ID];
				double ymax = ymin + currBox->width;

				// check along axes per corner
				
				// corner 0
				double myX = myXmin;
				double myY = myYmin;
				if (myX >= xmin && myX <= xmax && myY >= ymin && myY <= ymax) {
					corner0sitting = true;
				}

				// corner 1
				myX = myXmax;
				myY = myYmin;
				if (myX >= xmin && myX <= xmax && myY >= ymin && myY <= ymax) {
					corner1sitting = true;
				}

				// corner 2
				myX = myXmin;
				myY = myYmax;
				if (myX >= xmin && myX <= xmax && myY >= ymin && myY <= ymax) {
					corner2sitting = true;
				}

				// corner 3
				myX = myXmax;
				myY = myYmax;
				if (myX >= xmin && myX <= xmax && myY >= ymin && myY <= ymax) {
					corner3sitting = true;
				}

			}
			if (corner0sitting && corner1sitting && corner2sitting && corner3sitting)
				overhangExists = false;
			else
				overhangExists = true;
		}

		// Valid placement of item
		if (!intersectExists && !overhangExists) {
			item->position = pivotPoint;
			item->length = itemOrientation->length;
			item->width = itemOrientation->width;
			item->height = itemOrientation->height;

			if (DEBUG) {
				std::cout << "Placing:\n";
				std::cout << "	" << *item;
				std::cout << "in:\n";
				std::cout << "	" << *pallet;
			}

			pallet->items.push_back(item);

			foundPlacement = true;
			break;
		}
	}

	for (Box *itemOrientation : itemOrientations) {
		delete itemOrientation;
	}
	return foundPlacement;
}

/*********************************************/

/******************** Main *******************/

int main()
{	

	initializeDatabase();

	// Use a mock client to test the http listener
	if (USE_HTTP_CLIENT) {
		utility::string_t outputPath = U("C:\\Users\\james\\OneDrive\\Desktop\\My_Stuff\\Senior (2018-2019)\\Courses\\Capstone\\boxer-packer\\Packing\\binpack\\binpack\\mock_client_results.txt");
		HttpClient httpClient = HttpClient(U("http://100.64.229.45:8080"), outputPath);

		// Dummy JSON data to attach to POST request
		json::value postData;
		postData[L"length"] = json::value::string(L"2");
		postData[L"width"] = json::value::string(L"3");
		postData[L"height"] = json::value::string(L"4");

		httpClient.sendRequest("POST", U("application/json"), postData);
	}

	if (USE_HTTP_LISTENER) {
		HttpHandler *  h = new HttpHandler(U("http://192.168.0.110:"), U("8080"));
		h->open().wait();
		ucout << utility::string_t(U("Listening for requests at: ")) << h->listener->uri().to_string() << std::endl;
	}

	if (USE_MAIN_BINPACK) {

		std::vector<Box *> unpackedBoxes = initiatePacking();

		int iteration = 1;
		while (unpackedBoxes.size() != 0) {
			std::cout << "\nStarting iteration " << iteration << "..." << std::endl;
			std::cout << "Before packing, number of unpacked boxes: " << unpackedBoxes.size() << std::endl;
			std::cout << "Before packing, number of pallets: " << openPallets.size() << std::endl;
			for (int i = 0; i < openPallets.size(); i++) {
				std::cout << "\tPallet " << i << " contains " << openPallets[i]->items.size() << " boxes" << std::endl;
			}

			unpackedBoxes = runFirstFit(unpackedBoxes);
			++iteration;

			std::cout << "After packing, number of unpacked boxes: " << unpackedBoxes.size() << std::endl;
			std::cout << "After packing, number of pallets: " << openPallets.size() << std::endl;
			for (int i = 0; i < openPallets.size(); i++) {
				std::cout << "\tPallet " << i << " contains " << openPallets[i]->items.size() << " boxes" << std::endl;
			}
		}

		teardown();
	}

	std::cin.get();
	return 0;
}

/*********************************************/