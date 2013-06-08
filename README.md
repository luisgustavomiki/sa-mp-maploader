sa-mp-maploader
===============

A SA-MP version of MTA .map

The MapLoader is a tool that uses the XML Plugin and provides you the ability to load .map files from a 'maps' folder in you SA-MP server. However, you cannot just load one of those MTA .map files. You will need to convert it.
See the example code below:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mapset name="Construções" desc="Prédios em LS modificados">
	<map name="Etc" author="Luís Gustavo Miki">
		<remove id="noPhoneBooths" model="1216" x="1721.6720" y="-1721.2890" z="13.2266" radius="10000.0" />
        	<remove id="noSprunkMachines" model="955" x="1928.7340" y="-1772.4450" z="12.9453" radius="10000.0" />
		<object id="atm-object 1-1616" model="1616" x="734.1673" y="-1785.8500" z="15.7247" rx="0.0000" ry="0.0000" rz="149.0000" distance="300" />
        	<object id="atm-object 2-1616" model="1616" x="964.2168" y="-1419.8360" z="15.6215" rx="0.0000" ry="0.0000" rz="0.0000" distance="300" />
        	<object id="atm-object 3-1616" model="1616" x="514.1494" y="-1641.7330" z="21.0164" rx="0.0000" ry="0.0000" rz="180.0000" distance="300" />
        	<object id="atm-object 4-2921" model="2921" x="477.1119" y="-1478.1130" z="21.4574" rx="0.0000" ry="0.0000" rz="180.0000" distance="300" />

	</map>
	<map name="Polícia Civil 1ºDP" author="Luís Gustavo Miki">
		<object id="predio" model="6100" x="1247.3000488" y="-1568.6999512" z="36.7999992" rx="0.000" ry="0.000" rz="90.000" virtualworld="0" interior="0">
			<material index="4" model="13724" txdname="docg01_lahills" texturename="ab_tile2" />
		</object>
		<object id="entradaestacionamento" model="8947" x="1276.0999756" y="-1572.9000244" z="9.3999996" rx="0.000" ry="0.000" rz="90.000" virtualworld="0" interior="0" />
		<object id="object(warehouse_door2b)(1)" model="3037" x="1265.9000244" y="-1572.500" z="14.500" rx="0.000" ry="0.000" rz="0.000" virtualworld="0" interior="0" />
		<object id="object(bar_barrier16)(1)" model="995" x="1203.500" y="-1571.3000488" z="13.302" rx="90.000" ry="180.000" rz="270.000" virtualworld="0" interior="0"/>
		<object id="object(bar_barrier16)(2)" model="995" x="1203.500" y="-1576.9000244" z="13.302" rx="90.000" ry="179.9945068" rz="270.000" virtualworld="0" interior="0" />
	</map>
	<map name="Polícia Civil 1ºDP - Interior Garagem" author="Luís Gustavo Miki">
		<object id="object 1-3095" model="3095" x="-1627.6000" y="688.5000" z="7.2000" rx="90.0000" ry="0.0000" rz="0.0000" virtualworld="5" interior="-1" distance="300.0000" />
		<object id="object 2-3095" model="3095" x="-1636.6000" y="688.5000" z="7.2000" rx="90.0000" ry="0.0000" rz="0.0000" virtualworld="5" interior="-1" distance="300.0000" />
		<object id="object 3-2949" model="2949" x="-1622.1000" y="693.0000" z="6.2000" rx="0.0000" ry="0.0000" rz="0.0000" virtualworld="5" interior="-1" distance="300.0000" />
		<object id="object 4-3095" model="3095" x="-1622.1000" y="689.5000" z="7.2000" rx="90.0000" ry="180.0000" rz="269.9998" virtualworld="5" interior="-1" distance="300.0000" />
	</map>
	<map name="Polícia Civil 1ºDP - Interior" author="Luís Gustavo Miki">
		<object id="object 1-19379" model="19379" x="1512.7900" y="1822.7200" z="9.7500" rx="0.0000" ry="90.0000" rz="0.0000" virtualworld="-1" interior="1" distance="300.0000" />
	</map>
</mapset>
```
As you can see, it supports a set of SA-MP object features.
Each file is loaded and referenced by a listing.xml file that must be placed on ./maps folder. It should look like this:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<maplisting>
	<mapset name="Construções" path="env\buildings.xml" />
	<mapset name="Barreiras" path="env\barriers.xml" />
	<mapset name="Metro" path="env\metro.xml" />
	<mapset name="Common Int" path="int\common.xml" />
	<mapset name="mint" path="int\mint.map" />
</maplisting>
```

And it should be enough to create your own map!
https://github.com/luisgustavomiki/samp-xml/ - SA-MP XML Plugin, needed to load the XML Files
*** - MapManager, needed to convert to MapLoader format.