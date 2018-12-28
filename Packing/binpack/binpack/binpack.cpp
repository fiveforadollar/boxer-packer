﻿// binpack.cpp : Defines the entry point for the application.
//

#include "binpack.h"
#include "pallet.h"
#include "box.h"

using namespace std;

int main()
{
	Pallet myNewPallet(1, 2, 3);
	cout << "Length: " << myNewPallet.length << " Width: " << myNewPallet.width << " Height: " << myNewPallet.height << endl;
	cout << "Hello World." << endl;
	cout << "Press ENTER to exit." << endl;
	Box myBox(1, 2, 3);
	std::vector<Box*> myBoxOs = myBox.getOrientations();
	for (auto x : myBoxOs) {
		cout << x->length << x->width << x->height << endl;
	}
	cin.get();
	return 0;
}
