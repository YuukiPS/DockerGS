#!/bin/bash
mkdir -p resources && cd resources
GSDATA="https://github.com/Dimbreath/GenshinData"
git clone $GSDATA
git clone https://github.com/radioegor146/gi-bin-output
#git clone https://github.com/Grasscutters/Grasscutter-Protos
#mkdir -p proto     && cp -rf Grasscutter-Protos/proto/* proto
mkdir -p BinOutput && cp -rf gi-bin-output/2.2/Data/_BinOutput/*    BinOutput
                          cp -rf gi-bin-output/2.5.52/Data/_BinOutput/* BinOutput
mkdir -p TextMap &&        cp -rf GenshinData/TextMap/*             TextMap
mkdir -p Subtitle &&       cp -rf GenshinData/Subtitle/*            Subtitle
mkdir -p Readable &&       cp -rf GenshinData/Readable/*            Readable
mkdir -p ExcelBinOutput && cp -rf GenshinData/ExcelBinOutput/*      ExcelBinOutput
                               cp -rf GenshinData/BinOutput/*       BinOutput
id_main_stats="104c21c6530885e450975b13830639e9ca649799"
id_sub_stats="a92b5842daa911c095f47ef235b2bcd4b388d65a"
wget --backups=1 $GSDATA/raw/$id_main_stats/ExcelBinOutput/ReliquaryMainPropExcelConfigData.json -P ExcelBinOutput/
wget --backups=1 $GSDATA/raw/$id_sub_stats/ExcelBinOutput/ReliquaryAffixExcelConfigData.json     -P ExcelBinOutput/
sed -i 's/BPAMNILGFPK/AvatarId/' ExcelBinOutput/AvatarCostumeExcelConfigData.json
sed -i 's/OBACDKHOCAM/CostumeId/' ExcelBinOutput/AvatarCostumeExcelConfigData.json
rm -R -f gi-bin-output Grasscutter-Protos GenshinData
ls