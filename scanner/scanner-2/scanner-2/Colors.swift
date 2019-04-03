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
            FlatYellow(),
            FlatSkyBlue(),
            FlatOrange(),
            FlatNavyBlue(),
            FlatBlack(),
            FlatMagenta(),
            FlatTeal(),
            FlatGreen(),
            FlatMint(),
            FlatWhite(),
            FlatGray(),
            FlatForestGreen(),
            FlatPurple(),
            FlatBrown(),
            FlatPlum(),
            FlatSand(),
            FlatWatermelon(),
            FlatLime(),
            FlatPink(),
            FlatMaroon(),
            FlatCoffee(),
            FlatPowderBlue(),
            FlatBlue(),
            FlatRedDark(),
            FlatOrangeDark(),
            FlatYellowDark(),
            FlatSandDark(),
            FlatNavyBlueDark(),
            FlatBlackDark(),
            FlatMagentaDark(),
            FlatTealDark(),
            FlatSkyBlueDark(),
            FlatGreenDark(),
            FlatMintDark(),
            FlatWhiteDark(),
            FlatGrayDark(),
            FlatForestGreenDark(),
            FlatPurpleDark(),
            FlatBrownDark(),
            FlatPlumDark(),
            FlatWatermelonDark(),
            FlatLimeDark(),
            FlatPinkDark(),
            FlatMaroonDark(),
            FlatCoffeeDark(),
            FlatPowderBlueDark(),
            FlatBlackDark()
        ]
    }
}
