# shamey-choochoo

A free, open-source RedM script for trains

## Features
- Automated *OR* player-operated East train
- Automated St. Denis tram/trolley
- Support for two train jobs: "Conductor" (assistant) and "Engineer" (driver)
- Train ticket system, with NPCs both selling and taking the tickets
- Fuel system with shovel animation
- Players can check the train's "last known location"
- Configurable (stops, stations, prices, NPCs, payouts, animations)
- Organized & documented
- Performant

## Known Issues
The automated train and tram are known to go missing, with the NPC conductors sometimes freezing in the air or walking away. This is only for the automated ones, though; the train should never go missing when player-spawned/player-operated. The current state of CFX requires all trains to be spawned client-side, which creates large issues here with entity culling. I implemented a system to try to work around the culling, but it does not work well and time would be better spent reverse-engineering server-side trains. NOTE: There is an admin-only `/resetEastTrain` command as a workaround.

## Requirements
- VORP Framework
- [shamey-core](https://github.com/ShameyWinehouse/shamey-core) (for checking jobs)

## License & Support
This software was formerly proprietary to Rainbow Railroad Roleplay, but I am now releasing it free and open-source under GNU GPLv3. I cannot provide any support.