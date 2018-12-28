#ifndef PALLET_H
#define PALLET_H

#include <vector>
#include "box.h"

class Pallet {
public:
	double length;
	double width;
	double height;
	double volume;
	//vector<Box> items;

	Pallet(double _length, double _width, double _height) {
		length = _length;
		width = _width;
		height = _height;
		volume = length * width * height;
	}
	~Pallet() {}
};

#endif