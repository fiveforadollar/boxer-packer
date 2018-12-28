// binpack.h : Include file for standard system include files,
// or project specific include files.

#pragma once

#include <iostream>
#include "pallet.h"
#include "box.h"

#define LENGTH_AXIS_ID 0
#define WIDTH_AXIS_ID 1
#define HEIGHT_AXIS_ID 2

/* 
	Adds a new, empty pallet of (P_LENGTH, P_WIDTH, P_HEIGHT) dimensions to a vector of open pallets
	@Params: none
	@Return: none
*/
void openNewPallet(); 

/* 
	Try to place box in container
	@Params: 
		item: 
	@Return: 
*/
bool placeItem(const Box item, const int containerNum, vector<double> pivot);

/*
	Checks for overlap of the positions of two boxes along 2 given axes
	@Params:
		box1: First box
		box2: Second box
		axisId1: First axis index into dimensions vector
		axisId2: Second axis index into dimensions vector
	@Return: boolean true if overlap exists
*/
bool overlap(Box* box1, Box* box2, const int axisId1, const int axisId2);

/*
	Checks for overlap of two boxes along all axes
	@Params:
		box1: First box
		box2: Second box
	@Return: boolean true if intersection exists
*/
bool intersect(Box* box1, Box* box2);