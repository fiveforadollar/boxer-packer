#include "binpack.h"

using namespace std;

// Pallets in use
vector<Pallet*> openPallets;

void openNewPallet() {
	openPallets.push_back(new Pallet());
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
