// binpack.h : Include file for standard system include files,
// or project specific include files.

#pragma once

#include <iostream>
#include "pallet.h"
#include "box.h"

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

