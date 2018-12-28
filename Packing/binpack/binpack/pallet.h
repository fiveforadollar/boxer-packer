#pragma once 

#include <vector>
#include "box.h"

/* Pallet dimensions in inches */
#define P_LENGTH 40.0
#define P_WIDTH 48.0
#define P_HEIGHT 52.0
/*******************************/

class Pallet {
public:
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
	}

	Pallet(double _length, double _width, double _height) {
		length = _length;
		width = _width;
		height = _height;
		volume = length * width * height;
	}

	~Pallet() {}
};
