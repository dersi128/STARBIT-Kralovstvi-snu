extends RefCounted
const ENTRIES: Array = [
  {
    "id": "rain_cloud",
    "title": "Mráček · déšť na 5 sekund",
    "category": "Mraky",
    "scene": "res://scenes/worldkit/RainCloud.tscn",
    "thumb": "res://assets/characters/animations/mracek/mracek_icon.tres",
    "note": "Roztomilý mráček → rozčilení → 5 s deště → uklidnění. Déšť nechá Bitovi 20 % rychlosti. Rain Width / Height = šířka a dosah. Rain Duration = délka deště. Zkopíruj i z počátku Level_06."
  },
  {
    "id": "piece_GrassLeft",
    "title": "Travnatá zem · levý díl",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/GrassLeft.tscn",
    "thumb": "res://assets/environment/supplied/pieces/GrassLeft.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_GrassMiddle",
    "title": "Travnatá zem · střed",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/GrassMiddle.tscn",
    "thumb": "res://assets/environment/supplied/pieces/GrassMiddle.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_GrassMiddleB",
    "title": "Travnatá zem · střed B",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/GrassMiddleB.tscn",
    "thumb": "res://assets/environment/supplied/pieces/GrassMiddleB.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_GrassRight",
    "title": "Travnatá zem · pravý díl",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/GrassRight.tscn",
    "thumb": "res://assets/environment/supplied/pieces/GrassRight.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_StoneGrassLeft",
    "title": "Kámen · Travnatá zem · levý díl",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/StoneGrassLeft.tscn",
    "thumb": "res://assets/environment/supplied/pieces/StoneGrassLeft.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_StoneGrassMiddle",
    "title": "Kámen · Travnatá zem · střed",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/StoneGrassMiddle.tscn",
    "thumb": "res://assets/environment/supplied/pieces/StoneGrassMiddle.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_StoneGrassMiddleB",
    "title": "Kámen · Travnatá zem · střed · B",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/StoneGrassMiddleB.tscn",
    "thumb": "res://assets/environment/supplied/pieces/StoneGrassMiddleB.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_StoneGrassRight",
    "title": "Kámen · Travnatá zem · pravý díl",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/StoneGrassRight.tscn",
    "thumb": "res://assets/environment/supplied/pieces/StoneGrassRight.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandTiny",
    "title": "Ostrov · drobný",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandTiny.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandTiny.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandRound",
    "title": "Ostrov · kulatý",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandRound.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandRound.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandVines",
    "title": "Ostrov · liány",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandVines.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandVines.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandStar",
    "title": "Ostrov · hvězda",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandStar.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandStar.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandStone",
    "title": "Ostrov · Kámen",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandStone.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandStone.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandWide",
    "title": "Ostrov · široký",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandWide.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandWide.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandPoint",
    "title": "Ostrov · špičatý",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandPoint.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandPoint.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandLow",
    "title": "Ostrov · nízký",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandLow.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandLow.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandSmall",
    "title": "Ostrov · malý",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandSmall.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandSmall.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_StarBlock",
    "title": "hvězda · blok",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/StarBlock.tscn",
    "thumb": "res://assets/environment/supplied/pieces/StarBlock.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_StarBlockWide",
    "title": "hvězda · blok · široký",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/StarBlockWide.tscn",
    "thumb": "res://assets/environment/supplied/pieces/StarBlockWide.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_SlopeDown",
    "title": "Svah dolů",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/SlopeDown.tscn",
    "thumb": "res://assets/environment/supplied/pieces/SlopeDown.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_SlopeUp",
    "title": "Svah nahoru",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/SlopeUp.tscn",
    "thumb": "res://assets/environment/supplied/pieces/SlopeUp.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_CliffLeft",
    "title": "Útes · levý díl",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/CliffLeft.tscn",
    "thumb": "res://assets/environment/supplied/pieces/CliffLeft.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_CliffRight",
    "title": "Útes · pravý díl",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/CliffRight.tscn",
    "thumb": "res://assets/environment/supplied/pieces/CliffRight.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_CliffVines",
    "title": "Útes · liány",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/CliffVines.tscn",
    "thumb": "res://assets/environment/supplied/pieces/CliffVines.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_CliffEnd",
    "title": "Útes · konec",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/CliffEnd.tscn",
    "thumb": "res://assets/environment/supplied/pieces/CliffEnd.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_BridgeLeft",
    "title": "Most · levý díl",
    "category": "Mosty",
    "scene": "res://scenes/supplied/BridgeLeft.tscn",
    "thumb": "res://assets/environment/supplied/pieces/BridgeLeft.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_BridgeMiddle",
    "title": "Most · střed",
    "category": "Mosty",
    "scene": "res://scenes/supplied/BridgeMiddle.tscn",
    "thumb": "res://assets/environment/supplied/pieces/BridgeMiddle.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_BridgeRight",
    "title": "Most · pravý díl",
    "category": "Mosty",
    "scene": "res://scenes/supplied/BridgeRight.tscn",
    "thumb": "res://assets/environment/supplied/pieces/BridgeRight.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_BridgeSmall",
    "title": "Most · malý",
    "category": "Mosty",
    "scene": "res://scenes/supplied/BridgeSmall.tscn",
    "thumb": "res://assets/environment/supplied/pieces/BridgeSmall.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandPebbles",
    "title": "Ostrov · oblázky",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandPebbles.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandPebbles.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_IslandTall",
    "title": "Ostrov · vysoký",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/IslandTall.tscn",
    "thumb": "res://assets/environment/supplied/pieces/IslandTall.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_SignArrow",
    "title": "Cedule · šipka",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/SignArrow.tscn",
    "thumb": "res://assets/environment/supplied/pieces/SignArrow.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_SignDouble",
    "title": "Cedule · dvojitý",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/SignDouble.tscn",
    "thumb": "res://assets/environment/supplied/pieces/SignDouble.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_Banner",
    "title": "Prapor",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/Banner.tscn",
    "thumb": "res://assets/environment/supplied/pieces/Banner.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_FlagRope",
    "title": "Vlajky · provaz",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/FlagRope.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FlagRope.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_BannerStar",
    "title": "Prapor · hvězda",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/BannerStar.tscn",
    "thumb": "res://assets/environment/supplied/pieces/BannerStar.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_Fence",
    "title": "Plot",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/Fence.tscn",
    "thumb": "res://assets/environment/supplied/pieces/Fence.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_RopeFence",
    "title": "provaz · Plot",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/RopeFence.tscn",
    "thumb": "res://assets/environment/supplied/pieces/RopeFence.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_Bush",
    "title": "Keř",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/Bush.tscn",
    "thumb": "res://assets/environment/supplied/pieces/Bush.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_BushFlowers",
    "title": "Keř · květiny",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/BushFlowers.tscn",
    "thumb": "res://assets/environment/supplied/pieces/BushFlowers.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_LeavesWide",
    "title": "Listy · široký",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/LeavesWide.tscn",
    "thumb": "res://assets/environment/supplied/pieces/LeavesWide.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_LeavesSmall",
    "title": "Listy · malý",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/LeavesSmall.tscn",
    "thumb": "res://assets/environment/supplied/pieces/LeavesSmall.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_LeavesTall",
    "title": "Listy · vysoký",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/LeavesTall.tscn",
    "thumb": "res://assets/environment/supplied/pieces/LeavesTall.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_VinesShort",
    "title": "liány · krátký",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/VinesShort.tscn",
    "thumb": "res://assets/environment/supplied/pieces/VinesShort.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_VinesLong",
    "title": "liány · dlouhý",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/VinesLong.tscn",
    "thumb": "res://assets/environment/supplied/pieces/VinesLong.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_StoneColumn",
    "title": "Kámen · Sloup",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/StoneColumn.tscn",
    "thumb": "res://assets/environment/supplied/pieces/StoneColumn.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_BrokenColumn",
    "title": "Rozbitý · Sloup",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/BrokenColumn.tscn",
    "thumb": "res://assets/environment/supplied/pieces/BrokenColumn.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_Ruins",
    "title": "Ruiny",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/Ruins.tscn",
    "thumb": "res://assets/environment/supplied/pieces/Ruins.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_StoneSlab",
    "title": "Kámen · deska",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/StoneSlab.tscn",
    "thumb": "res://assets/environment/supplied/pieces/StoneSlab.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_FallenRocks",
    "title": "Spadlé · kameny",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/FallenRocks.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallenRocks.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_LanternPost",
    "title": "Lucerna · sloupek",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/LanternPost.tscn",
    "thumb": "res://assets/environment/supplied/pieces/LanternPost.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_LanternHook",
    "title": "Lucerna · závěs",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/LanternHook.tscn",
    "thumb": "res://assets/environment/supplied/pieces/LanternHook.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_MushroomRed",
    "title": "Houba · červená",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/MushroomRed.tscn",
    "thumb": "res://assets/environment/supplied/pieces/MushroomRed.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_MushroomSmall",
    "title": "Houba · malý",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/MushroomSmall.tscn",
    "thumb": "res://assets/environment/supplied/pieces/MushroomSmall.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_MushroomBlue",
    "title": "Houba · modrá",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/MushroomBlue.tscn",
    "thumb": "res://assets/environment/supplied/pieces/MushroomBlue.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_Barrel",
    "title": "Sud",
    "category": "Dekorace",
    "scene": "res://scenes/supplied/Barrel.tscn",
    "thumb": "res://assets/environment/supplied/pieces/Barrel.png",
    "note": "Průchozí dekorace bez kolize."
  },
  {
    "id": "piece_CloudWide",
    "title": "Mrak · široký",
    "category": "Mraky",
    "scene": "res://scenes/supplied/CloudWide.tscn",
    "thumb": "res://assets/environment/supplied/pieces/CloudWide.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_CloudLong",
    "title": "Mrak · dlouhý",
    "category": "Mraky",
    "scene": "res://scenes/supplied/CloudLong.tscn",
    "thumb": "res://assets/environment/supplied/pieces/CloudLong.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_CloudSmall",
    "title": "Mrak · malý",
    "category": "Mraky",
    "scene": "res://scenes/supplied/CloudSmall.tscn",
    "thumb": "res://assets/environment/supplied/pieces/CloudSmall.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_CloudPair",
    "title": "Mrak · dvojice",
    "category": "Mraky",
    "scene": "res://scenes/supplied/CloudPair.tscn",
    "thumb": "res://assets/environment/supplied/pieces/CloudPair.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_WaterfallWide",
    "title": "Vodopád · široký",
    "category": "Voda",
    "scene": "res://scenes/supplied/WaterfallWide.tscn",
    "thumb": "res://assets/environment/supplied/pieces/WaterfallWide.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_WaterfallMedium",
    "title": "Vodopád · střední",
    "category": "Voda",
    "scene": "res://scenes/supplied/WaterfallMedium.tscn",
    "thumb": "res://assets/environment/supplied/pieces/WaterfallMedium.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_WaterfallSlim",
    "title": "Vodopád · úzký",
    "category": "Voda",
    "scene": "res://scenes/supplied/WaterfallSlim.tscn",
    "thumb": "res://assets/environment/supplied/pieces/WaterfallSlim.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_WaterfallThin",
    "title": "Vodopád · tenký",
    "category": "Voda",
    "scene": "res://scenes/supplied/WaterfallThin.tscn",
    "thumb": "res://assets/environment/supplied/pieces/WaterfallThin.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_SplashWide",
    "title": "Cákanec · široký",
    "category": "Voda",
    "scene": "res://scenes/supplied/SplashWide.tscn",
    "thumb": "res://assets/environment/supplied/pieces/SplashWide.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_SplashSmall",
    "title": "Cákanec · malý",
    "category": "Voda",
    "scene": "res://scenes/supplied/SplashSmall.tscn",
    "thumb": "res://assets/environment/supplied/pieces/SplashSmall.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_Foam",
    "title": "Pěna",
    "category": "Voda",
    "scene": "res://scenes/supplied/Foam.tscn",
    "thumb": "res://assets/environment/supplied/pieces/Foam.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_RiverSurface",
    "title": "Řeka · hladina",
    "category": "Voda",
    "scene": "res://scenes/supplied/RiverSurface.tscn",
    "thumb": "res://assets/environment/supplied/pieces/RiverSurface.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_RiverLeft",
    "title": "Řeka · levý díl",
    "category": "Voda",
    "scene": "res://scenes/supplied/RiverLeft.tscn",
    "thumb": "res://assets/environment/supplied/pieces/RiverLeft.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_RiverMiddle",
    "title": "Řeka · střed",
    "category": "Voda",
    "scene": "res://scenes/supplied/RiverMiddle.tscn",
    "thumb": "res://assets/environment/supplied/pieces/RiverMiddle.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_RiverRight",
    "title": "Řeka · pravý díl",
    "category": "Voda",
    "scene": "res://scenes/supplied/RiverRight.tscn",
    "thumb": "res://assets/environment/supplied/pieces/RiverRight.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_FallsLongThin",
    "title": "Vodopád · dlouhý · tenký",
    "category": "Voda",
    "scene": "res://scenes/supplied/FallsLongThin.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsLongThin.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_FallsLongA",
    "title": "Vodopád · dlouhý · A",
    "category": "Voda",
    "scene": "res://scenes/supplied/FallsLongA.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsLongA.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_FallsLongWide",
    "title": "Vodopád · dlouhý · široký",
    "category": "Voda",
    "scene": "res://scenes/supplied/FallsLongWide.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsLongWide.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_FallsLongB",
    "title": "Vodopád · dlouhý · B",
    "category": "Voda",
    "scene": "res://scenes/supplied/FallsLongB.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsLongB.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_FallsLongLarge",
    "title": "Vodopád · dlouhý · Large",
    "category": "Voda",
    "scene": "res://scenes/supplied/FallsLongLarge.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsLongLarge.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_FallsBodyA",
    "title": "Vodopád · navazující pás · A",
    "category": "Voda",
    "scene": "res://scenes/supplied/FallsBodyA.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsBodyA.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_FallsBodyB",
    "title": "Vodopád · navazující pás · B",
    "category": "Voda",
    "scene": "res://scenes/supplied/FallsBodyB.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsBodyB.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_FallsBodyC",
    "title": "Vodopád · navazující pás · C",
    "category": "Voda",
    "scene": "res://scenes/supplied/FallsBodyC.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsBodyC.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_FallsMist",
    "title": "Vodopád · Tříšť",
    "category": "Voda",
    "scene": "res://scenes/supplied/FallsMist.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsMist.png",
    "note": "Animovaná dekorativní voda; bez plavání a bez kolize."
  },
  {
    "id": "piece_WaterIslandLeft",
    "title": "Vodní · Ostrov · levý díl",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/WaterIslandLeft.tscn",
    "thumb": "res://assets/environment/supplied/pieces/WaterIslandLeft.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_WaterIslandWide",
    "title": "Vodní · Ostrov · široký",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/WaterIslandWide.tscn",
    "thumb": "res://assets/environment/supplied/pieces/WaterIslandWide.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_WaterIslandRight",
    "title": "Vodní · Ostrov · pravý díl",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/WaterIslandRight.tscn",
    "thumb": "res://assets/environment/supplied/pieces/WaterIslandRight.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_WaterIslandSlim",
    "title": "Vodní · Ostrov · úzký",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/WaterIslandSlim.tscn",
    "thumb": "res://assets/environment/supplied/pieces/WaterIslandSlim.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_FallsIsland",
    "title": "Vodopád · Ostrov",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/FallsIsland.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsIsland.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_FallsTwinIsland",
    "title": "Vodopád · Dvojitý · Ostrov",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/FallsTwinIsland.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsTwinIsland.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_FallsWideIsland",
    "title": "Vodopád · široký · Ostrov",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/FallsWideIsland.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsWideIsland.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_FallsMossIsland",
    "title": "Vodopád · mech · Ostrov",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/FallsMossIsland.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsMossIsland.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_FallsStoneIsland",
    "title": "Vodopád · Kámen · Ostrov",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/FallsStoneIsland.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsStoneIsland.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_FallsRock",
    "title": "Vodopád · Skála",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/FallsRock.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsRock.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_FallsStarRock",
    "title": "Vodopád · hvězda · Skála",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/FallsStarRock.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsStarRock.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "piece_FallsSteps",
    "title": "Vodopád · schody",
    "category": "Plošiny",
    "scene": "res://scenes/supplied/FallsSteps.tscn",
    "thumb": "res://assets/environment/supplied/pieces/FallsSteps.png",
    "note": "Plošina s kolizí shora. Width / Height = rozměry, Travel = pohyb, Period = délka cyklu."
  },
  {
    "id": "push_crate",
    "title": "Bedna · posuvná",
    "category": "Herní prvky",
    "scene": "res://scenes/worldkit/PushCrate.tscn",
    "thumb": "res://assets/environment/supplied/crate.png",
    "note": "Bit ji tlačí chůzí. Polož na pevnou podlahu."
  },
  {
    "id": "crate",
    "title": "Bedna · pevná",
    "category": "Herní prvky",
    "scene": "res://scenes/worldkit/Crate.tscn",
    "thumb": "res://assets/environment/supplied/crate.png",
    "note": "Pevná bedna s kolizí."
  },
  {
    "id": "spring_pad",
    "title": "Pružina",
    "category": "Herní prvky",
    "scene": "res://scenes/worldkit/SpringPad.tscn",
    "thumb": "editor:SpringArm3D",
    "note": "Odrazí Bita. Nad pružinou ponech volný prostor."
  },
  {
    "id": "checkpoint",
    "title": "Checkpoint",
    "category": "Herní prvky",
    "scene": "res://scenes/checkpoint.tscn",
    "thumb": "res://assets/shared/pieces/flag.png",
    "note": "Místo návratu po pádu; umísti na bezpečnou plošinu."
  },
  {
    "id": "goal",
    "title": "Brána s portálem",
    "category": "Herní prvky",
    "scene": "res://scenes/goal.tscn",
    "thumb": "res://assets/shared/pieces/arch.png",
    "note": "Otevře se po sebrání hvězdy a uvolnění cesty bossem."
  },
  {
    "id": "star_key",
    "title": "Hvězda · klíč k bráně",
    "category": "Sbírání",
    "scene": "res://scenes/star_key.tscn",
    "thumb": "res://assets/environment/worldkit/star_key.tres",
    "note": "Povinná hvězda otevírající bránu."
  },
  {
    "id": "crystal",
    "title": "Diamant",
    "category": "Sbírání",
    "scene": "res://scenes/crystal.tscn",
    "thumb": "res://assets/environment/worldkit/crystal.tres",
    "note": "Dobrovolný sběratelný diamant."
  },
  {
    "id": "mole",
    "title": "Krteček · rádce",
    "category": "Postavy",
    "scene": "res://scenes/mole.tscn",
    "thumb": "res://assets/characters/animations/mole.tres",
    "note": "Text bubliny uprav v poli Message."
  },
  {
    "id": "fouk",
    "title": "Fouk · oprava",
    "category": "Postavy",
    "scene": "res://scenes/fouk.tscn",
    "thumb": "res://assets/shared/pieces/fouk.png",
    "note": "Oprava odemkne druhý skok; používej v levelu, kde ji chceš učit."
  },
  {
    "id": "jiskra",
    "title": "Jiskra",
    "category": "Postavy",
    "scene": "res://scenes/jiskra.tscn",
    "thumb": "res://assets/shared/pieces/jiskra.png",
    "note": "Připravená postava pro vlastní scény."
  },
  {
    "id": "rock_enemy",
    "title": "Kostíček · kamenný nepřítel",
    "category": "Nepřátelé",
    "scene": "res://scenes/Enemy_rock_enemy.tscn",
    "thumb": "res://assets/characters/animations/rock_enemy.tres",
    "note": "Patrol = délka hlídky, Speed = rychlost."
  },
  {
    "id": "cloud_enemy",
    "title": "Bublík · mráčkový nepřítel",
    "category": "Nepřátelé",
    "scene": "res://scenes/Enemy_cloud_enemy.tscn",
    "thumb": "res://assets/characters/animations/cloud_enemy.tres",
    "note": "Patrol = délka hlídky; nech místo pro svislé vznášení."
  },
  {
    "id": "stinko",
    "title": "Stínko",
    "category": "Nepřátelé",
    "scene": "res://scenes/Enemy_stinko.tscn",
    "thumb": "res://assets/characters/stinko/stinko.tres",
    "note": "Nový Stínko; v kampani je v levelech 7–10."
  },
  {
    "id": "boss",
    "title": "Brúčoun · boss",
    "category": "Nepřátelé",
    "scene": "res://scenes/Boss.tscn",
    "thumb": "res://assets/characters/animations/boss.tres",
    "note": "Boss se třemi životy. Umísti do arény a dolaď její hranice."
  },
  {
    "id": "bank_bridge",
    "title": "Most mezi břehy",
    "category": "Mosty",
    "scene": "res://scenes/worldkit/BankBridge.tscn",
    "thumb": "res://assets/environment/worldkit/WoodBridge.tres",
    "note": "End Offset určuje druhý konec lávky. Má kolizi."
  },
  {
    "id": "river_railing",
    "title": "Provazové zábradlí",
    "category": "Mosty",
    "scene": "res://scenes/worldkit/RiverRailing.tscn",
    "thumb": "res://assets/environment/supplied/pieces/RopeFence.png",
    "note": "Dekorace; End Offset nastav podle mostu."
  },
  {
    "id": "river_banks",
    "title": "Řeka mezi břehy",
    "category": "Voda",
    "scene": "res://scenes/worldkit/RiverBetweenBanks.tscn",
    "thumb": "res://assets/environment/supplied/pieces/RiverMiddle.png",
    "note": "Width a Depth vyplní prostor mezi břehy; voda je dekorace."
  },
  {
    "id": "moving_cloud",
    "title": "Pohyblivý mrak",
    "category": "Mraky",
    "scene": "res://scenes/worldkit/MovingCloud.tscn",
    "thumb": "res://assets/shared/pieces/cloud.png",
    "note": "Travel X/Y nastaví směr; period určuje délku pohybu."
  },
  {
    "id": "look_zone",
    "title": "Oblast výhledu kamery",
    "category": "Herní prvky",
    "scene": "res://scenes/CameraLookZone.tscn",
    "thumb": "editor:Camera2D",
    "note": "Neviditelná oblast pro nastavení pohledu kamery."
  },
  {
    "id": "stone_block",
    "title": "Pevný kamenný blok",
    "category": "Herní prvky",
    "scene": "res://scenes/worldkit/StoneBlock.tscn",
    "thumb": "res://assets/environment/worldkit/StoneBlock.tres",
    "note": "Pevná překážka s kolizí."
  }
]
