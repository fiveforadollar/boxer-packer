//
//  Colors.swift
//  Visualization
//
//  Created by James Jin on 2019-03-19.
//  Copyright © 2019 boxer-packer. All rights reserved.
//
// Hack way to get a list of all flat colors available in the Chameleon Framework
// Currently, I am not aware of a way to get these programatically...
// Can change this list to permit/prohibit use of certain colors

import ChameleonFramework

class Colors {
    static func getAllColors() -> Array<UIColor> {
        return [
            FlatRed(),
            FlatRedDark(),
            FlatOrange(),
            FlatOrangeDark(),
            FlatYellow(),
            FlatYellowDark(),
            FlatSand(),
            FlatSandDark(),
            FlatNavyBlue(),
            FlatNavyBlueDark(),
            FlatBlack(),
            FlatBlackDark(),
            FlatMagenta(),
            FlatMagentaDark(),
            FlatTeal(),
            FlatTealDark(),
            FlatSkyBlue(),
            FlatSkyBlueDark(),
            FlatGreen(),
            FlatGreenDark(),
            FlatMint(),
            FlatMintDark(),
            FlatWhite(),
            FlatWhiteDark(),
            FlatGray(),
            FlatGrayDark(),
            FlatForestGreen(),
            FlatForestGreenDark(),
            FlatPurple(),
            FlatPurpleDark(),
            FlatBrown(),
            FlatBrownDark(),
            FlatPlum(),
            FlatPlumDark(),
            FlatWatermelon(),
            FlatWatermelonDark(),
            FlatLime(),
            FlatLimeDark(),
            FlatPink(),
            FlatPinkDark(),
            FlatMaroon(),
            FlatMaroonDark(),
            FlatCoffee(),
            FlatCoffeeDark(),
            FlatPowderBlue(),
            FlatPowderBlueDark(),
            FlatBlue(),
            FlatBlackDark()
        ]
    }
}
