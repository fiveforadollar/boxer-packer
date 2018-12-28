#pragma once 

#include <vector>

class Box {
public:
	double length;
	double width;
	double height;
	double volume;
	std::vector<double> position;

	Box(double _length, double _width, double _height) {
		length = _length;
		width = _width;
		height = _height;
		volume = length * width * height;
	}

	std::vector <double> getDimensions() {
		std::vector<double> myDims{ this->length, this->width, this->height };
		return myDims;
	}

	std::vector <Box*> getOrientations() {
		Box* lwh = new Box(this->length, this->width, this->height);
		Box* lhw = new Box(this->length, this->height, this->width);
		Box* whl = new Box(this->width, this->height, this->length);
		Box* wlh = new Box(this->width, this->length, this->height);
		Box* hwl = new Box(this->height, this->width, this->length);
		Box* hlw = new Box(this->height, this->length, this->width);

		std::vector<Box*> myOrientations{ lwh, lhw, whl, wlh, hwl, hlw };
		return myOrientations;
	}
};