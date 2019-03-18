#pragma once 

#include <vector>
#include <iostream>

class Box {
public:
	static int idCounter;
	int id;
	double length;
	double width;
	double height;
	double volume;
	std::vector<double> position;
	int dbID;

	Box(double _length, double _width, double _height) {
		length = _length;
		width = _width;
		height = _height;
		volume = length * width * height;
		id = idCounter++;
	}

	Box(double _length, double _width, double _height, int _dbID) {
		length = _length;
		width = _width;
		height = _height;
		volume = length * width * height;
		id = idCounter++;
		dbID = _dbID;
	}

	Box(double _length, double _width, double _height, std::vector<double> _position) {
		length = _length;
		width = _width;
		height = _height;
		volume = length * width * height;
		position = _position;
		id = idCounter;
	}

	std::vector <double> getDimensions() {
		std::vector<double> myDims{ this->length, this->width, this->height };
		return myDims;
	}

	std::vector <Box*> getOrientations() {
		Box* lwh = new Box(this->length, this->width, this->height, this->position);
		Box* lhw = new Box(this->length, this->height, this->width, this->position);
		Box* whl = new Box(this->width, this->height, this->length, this->position);
		Box* wlh = new Box(this->width, this->length, this->height, this->position);
		Box* hwl = new Box(this->height, this->width, this->length, this->position);
		Box* hlw = new Box(this->height, this->length, this->width, this->position);

		std::vector<Box*> myOrientations{ lwh, lhw, whl, wlh, hwl, hlw };
		return myOrientations;
	}

	static void resetCounter() {
		idCounter = 1;
	}

	friend std::ostream& operator<<(std::ostream& os, const Box& box);
};

int Box::idCounter = 1;

std::ostream& operator<<(std::ostream& os, const Box& box)
{
	os << "Box " << box.id << " | DBID: " << box.dbID << " | dimensions (L,W,H): (" << box.length << "," << box.width << "," << box.height << ")";
	if (box.position.size())
		os << " at position: " << "(" << box.position[0] << "," << box.position[1] << "," << box.position[2] << ")";
	os << std::endl;
	return os;
}
