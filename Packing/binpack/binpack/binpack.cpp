#include "binpack.h"

using namespace std;

// Pallets in use
vector<Pallet*> openPallets;

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

int main()
{	
	Box myBox(1, 2, 3);
	std::vector<Box*> myBoxOs = myBox.getOrientations();
	for (auto x : myBoxOs) {
		cout << x->length << x->width << x->height << endl;
		cout << *x << endl;
	}

	cin.get();

	// Create intiial, empty pallet
	//initiatePacking();




	return 0;
}
