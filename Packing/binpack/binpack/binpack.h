#pragma once

#include <iostream>
#include <string>
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
		item: Box object to be placed
		palletNum: Pallet's index within the global vector of open pallets
		pivot: Location vector of form <length, width, height> at which the item will be placed
	@Return: bool indicating if placement was successful
*/
bool placeItem(Box *item, Pallet *pallet, std::vector<double> pivot);

/*
	Check if box can fit in the pallet given a pivot point
	@Params:
		item: Box object to be placed
		palletNum: Pallet's index within the global vector of open pallets
		pivot: Location vector of form <length, width, height> at which the item will be placed
	@Return: bool indicating if the box will fit in the pallet at the given pivot
*/
bool boxInBounds(Box *item, Pallet *pallet, std::vector<double> pivot);

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

/*
	Set up pallets and initial boxes
	@Params:= none
	@Return: none
*/
void initiatePacking();

/*
	Read box dimensions from JSON file
	@Params:
		fp: Filepath to JSON file of box dimensions
	@Return: vector of Box pointers
*/
std::vector<Box*> readBoxesFromJson(std::string fp);

/* 
	Attempt to find placements for each box 
	@Params:
		items: Vector of Box pointers for items to be placed
	@Return: Vector of Box pointers for items that were unable to be placed
*/	
std::vector<Box *> runBestFit(std::vector<Box *> items);

/*
	Free all dynamically allocated memory
	@Params: None
	@Return: None
*/
void teardown();