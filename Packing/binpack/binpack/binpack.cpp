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

int main()
{	
	Box myBox(1, 2, 3);
	std::vector<Box*> myBoxOs = myBox.getOrientations();
	for (auto x : myBoxOs) {
		cout << x->length << x->width << x->height << endl;
	}

	cin.get();

	// Create intiial, empty pallet
	openNewPallet(); 




	return 0;
}
