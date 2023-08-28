#!/bin/sh

rm out_sas*
rm OUTPUT_RRTM
### SPECTRAL CASES ###
echo '---SEPCTRAL CASES ---'
echo 'spc1'
cp input_sas_spc1 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc1

echo 'spc2'
cp input_sas_spc2 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc2

echo 'spc3'
cp input_sas_spc3 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc3

echo 'spc4'
cp input_sas_spc4 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc4

echo 'spc5'
cp input_sas_spc5 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc5

echo 'spc6'
cp input_sas_spc6 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc6

echo 'spc7'
cp input_sas_spc7 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc7

echo 'spc8'
cp input_sas_spc8 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc8

echo 'spc9'
cp input_sas_spc9 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc9

echo 'spc10'
cp input_sas_spc10 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc10


#### BROADBAND CASES ###
echo '---BROADBAND CASES ---'

echo 'brd1'
cp input_sas_brd1 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd1

echo 'brd2'
cp input_sas_brd2 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd2

echo 'brd3'
cp input_sas_brd3 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd3

echo 'brd4'
cp input_sas_brd4 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd4

echo 'brd5'
cp input_sas_brd5 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd5

echo 'brd6'
cp input_sas_brd6 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd6

echo 'brd7'
cp input_sas_brd7 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd7

echo 'brd8'
cp input_sas_brd8 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd8

echo 'brd9'
cp input_sas_brd9 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd9

echo 'brd10'
cp input_sas_brd10 INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd10


