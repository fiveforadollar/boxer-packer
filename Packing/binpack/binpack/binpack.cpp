#include "binpack.h"

/* Pallets in use */
std::vector<Pallet*> openPallets;

int axisIds[3] = {LENGTH_AXIS_ID, WIDTH_AXIS_ID, HEIGHT_AXIS_ID };


void openNewPallet() {
	openPallets.push_back(new Pallet());
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

	return overallX < (dimBox1[axisId1] + dimBox2[axisId1]) / 2.0 && overallY < (dimBox1[axisId2] + dimBox2[axisId2]) / 2.0;
}

bool intersect(Box* box1, Box* box2) {
	return (
		overlap(box1, box2, LENGTH_AXIS_ID, WIDTH_AXIS_ID) &&
		overlap(box1, box2, LENGTH_AXIS_ID, HEIGHT_AXIS_ID) &&
		overlap(box1, box2, WIDTH_AXIS_ID, HEIGHT_AXIS_ID));
}

void initiatePacking() {
	openNewPallet();
	std::vector<Box*> unpackedBoxes = readBoxesFromJson("my filepath");
	
	// DEBUG TESTING
	bool debug = true;
	if (debug) {
		Box* box1 = new Box(P_LENGTH - 1, P_WIDTH - 1, P_HEIGHT - 1);
		Box* box2 = new Box(P_HEIGHT - 1, P_LENGTH - 1, P_WIDTH - 1);
		unpackedBoxes.push_back(box1);
		unpackedBoxes.push_back(box2);
	}
	// END DEBUG

	while (unpackedBoxes.size() != 0) {
		std::cout << "Start one packing iteration..." << std::endl;
		std::cout << "Before packing, number of unpacked boxes:" << unpackedBoxes.size() << std::endl;
		std::cout << "Before packing, number of pallets:" << openPallets.size() << std::endl;
		for (int i = 0; i < openPallets.size(); i++) {
			std::cout << "\tPallet contains " << openPallets[i]->items.size() << "boxes" << std::endl;
		}
		
		//unpackedBoxes = runBestFit(unpackedBoxes);

		std::cout << "After packing, number of unpacked boxes:" << unpackedBoxes.size() << std::endl;
		std::cout << "After packing, number of pallets:" << openPallets.size() << std::endl;
		for (int i = 0; i < openPallets.size(); i++) {
			std::cout << "\tPallet contains " << openPallets[i]->items.size() << "boxes" << std::endl;
		}

	}
}

std::vector<Box*> readBoxesFromJson(std::string fp) {
	std::vector<Box*> myBoxes;
	// TO DO
	return myBoxes;
}

bool boxInBounds(Box *item, Pallet *pallet, std::vector<double> pivot) {
	return (
		pivot[LENGTH_AXIS_ID] + item->length < pallet->length &&
		pivot[WIDTH_AXIS_ID] + item->width < pallet->width &&
		pivot[HEIGHT_AXIS_ID] + item->height < pallet->height
	);
}

bool placeItem(Box *item, Pallet *pallet, std::vector<double> pivotPoint) {
	double pLength = pallet->length;
	double pWidth = pallet->width;
	double pHeight = pallet->height;

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
			if (intersect(currBox, item)) {
				intersectExists = true;
				break;
			}
		}

		// Valid placement of item
		if (!intersectExists) {
			item->position = pivotPoint;
			item->length = itemOrientation->length;
			item->width = itemOrientation->width;
			item->height = itemOrientation->height;
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

std::vector<Box *> runBestFit(std::vector<Box *> items) {
	std::vector<Box *> notPacked;

	while (items.size() > 0) {
		Box *toBePlacedItem = items.back();
		items.pop_back();

		// Check across all pallets 
		for (Pallet *currPallet : openPallets) {
			// Check all items in the pallet
			for (Box *currPlacedItem : currPallet->items) {
				bool foundPlacement = false;
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
						}
						case WIDTH_AXIS_ID: {
							pivotPoint = {
								currPlacedItem->position[LENGTH_AXIS_ID],
								currPlacedItem->position[WIDTH_AXIS_ID] + currPlacedItem->width,
								currPlacedItem->position[HEIGHT_AXIS_ID]
							};
						}
						case HEIGHT_AXIS_ID: {
							pivotPoint = {
								currPlacedItem->position[LENGTH_AXIS_ID],
								currPlacedItem->position[WIDTH_AXIS_ID],
								currPlacedItem->position[HEIGHT_AXIS_ID] + currPlacedItem->height
							};
						}
						default: {
							std::cout << "ERROR: Invalid Axis ID provided\n"; 
						}
					}

					// Successful placement of item
					if (placeItem(toBePlacedItem, currPallet, pivotPoint)) {
						foundPlacement = true;
						break;
					}
				}
				// Did not find a placement for the item
				if (!foundPlacement) {
					notPacked.push_back(toBePlacedItem);
				}
			}
		}
	}
	return notPacked;
}

int main()
{	
	Box myBox(1, 2, 3);
	std::vector<Box*> myBoxOs = myBox.getOrientations();
	for (auto x : myBoxOs) {
		std::cout << x->length << x->width << x->height << std::endl;
		std::cout << *x << std::endl;
	}

	std::cin.get();

	// Create intiial, empty pallet
	//initiatePacking();




	return 0;
}
