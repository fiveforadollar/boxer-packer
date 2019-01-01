#pragma once 

#include <vector>
#include <iostream>
#include "box.h"

/* Pallet dimensions in inches */
#define P_LENGTH 40.0
#define P_WIDTH 48.0
#define P_HEIGHT 52.0
/*******************************/

class Pallet {
public:
	static int idCounter;
	int id;
	double length;
	double width;
	double height;
	double volume;
	std::vector<Box*> items;

	Pallet() {
		length = P_LENGTH;
		width = P_WIDTH;
		height = P_HEIGHT;
		volume = length * width * height;
		id = idCounter++;
	}

	Pallet(double _length, double _width, double _height) {
		length = _length;
		width = _width;
		height = _height;
		volume = length * width * height;
		id = idCounter++;
	}

	~Pallet() {}
};

int Pallet::idCounter = 0;

std::ostream& operator<<(std::ostream& os, const Pallet& pallet)
{
	os << "Pallet " << pallet.id << " with dimensions (L,W,H): (" << pallet.length << "," << pallet.width << "," << pallet.height << ")\n";
	os << "	With " << pallet.items.size() << " item(s):" << std::endl;

	for (Box *item : pallet.items) {
		os << "	" << *item << std::endl;
	}

	return os;
}