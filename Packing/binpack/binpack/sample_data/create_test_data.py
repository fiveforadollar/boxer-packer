''' 
Generates a new set of valid JSON data for input into the packing algorithm
'''
import random
import json

numBoxes = 50
length = {
    "min": 0.01,
    "max": 1.016
}

width = {
    "min": 0.01,
    "max": 1.2192
}

height = {
    "min": 0.01,
    "max": 1.3208
}

# Generate dummy box data
boxData = []
for i in range(numBoxes):
    newBox = {
        "length": round(random.uniform(length["min"], length["max"]), 2),
        "width": round(random.uniform(width["min"], width["max"]), 2),
        "height": round(random.uniform(height["min"], height["max"]), 2)
    }
    boxData.append(newBox)

# Write output data to file
testFileName = "testData.json"
with open(testFileName, "w") as testFile:
    json.dump(boxData, testFile)
